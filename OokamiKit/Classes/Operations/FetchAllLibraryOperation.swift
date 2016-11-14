//
//  FetchAllLibraryOperation.swift
//  Ookami
//
//  Created by Maka on 12/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/// Operation to fetch all the the entries in a specific library
/// This will also delete any library entries that were not recieved (if everything succeeds)
public class FetchAllLibraryOperation: AsynchronousOperation {
    
    public typealias StatusDictionary = [LibraryEntryStatus: Bool]
    
    var queue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 5
        return q
    }()
    
    //The results of the statuses, True if it succeeded else False
    var results: StatusDictionary = {
        var dict: StatusDictionary = [:]
        LibraryEntryStatus.all.forEach { dict[$0] = false }
        return dict
    }()
    
    public let url: String
    public let userID: Int
    public let client: NetworkClientProtocol
    let fetchCompletion: (StatusDictionary) -> Void
    let type: LibraryRequestMedia
    
    var ids: [String: [Any]] = [:]
    
    
    /// Create a library operation to fetch all of the users library for a given type
    ///
    /// - Parameters:
    ///   - relativeURL: The api url for library get
    ///   - userID: The user id to fetch the library for
    ///   - type: The type of library to fetch
    ///   - client: The network client to execute request on
    ///   - completion: The completion callback which passes a dictionary of Status and bool values indicating if a certain status was fully fetched or not
    public init(relativeURL: String, userID: Int, type: LibraryRequestMedia, client: NetworkClientProtocol, completion: @escaping (StatusDictionary) -> Void) {
        self.url = relativeURL
        self.userID = userID
        self.client = client
        self.fetchCompletion = completion
        self.type = type
        
    }
    
    /// Combine parsed ids into our id value
    func combine(parsedIds: [String: [Any]]) {
        for (key, oIds) in parsedIds {
            if self.ids.keys.contains(key) {
                oIds.forEach { self.ids[key]!.append($0) }
            } else {
                self.ids[key] = oIds
            }
        }
    }
    
    /// Get the delere operation with the given entry ids
    func deleteOperation(withEntryIds ids: [Int]) -> DeleteEntryOperation {
        return DeleteEntryOperation(userID: userID, type: .anime, ids: ids, mode: .notInArray, realm: RealmProvider.realm)
    }
    
    /// Get the block operation which checks whether we can delete
    func deleteBlockOperation() -> BlockOperation {
        return BlockOperation {
            var failed = false
            self.results.forEach { status, success in
                if !success {
                    failed = true
                    return
                }
            }
            
            //Make sure we didn't fail before executing the deletion method
            guard !failed else {
                self.fetchCompletion(self.results)
                self.completeOperation()
                return
            }
            
            let dOperation = self.deleteOperation(withEntryIds: self.ids[LibraryEntry.typeString] as! [Int])
            dOperation.completionBlock = {
                self.fetchCompletion(self.results)
                self.completeOperation()
                return
            }
            self.queue.addOperation(dOperation)
        }
    }
    
    override public func main() {
        let deleteBlock = deleteBlockOperation()
        var operations: [Operation] = [deleteBlock]
        
        //Go through each of the statuses and make the operations
        LibraryEntryStatus.all.forEach { status in
            let request = LibraryGETRequest(userID: userID, relativeURL: url)
            request.filter([.media(type: type), .status(status)])
            request.include([.genres, .user])
            let operation = FetchLibraryOperation(request: request, client: client) { objects, error in
                guard error == nil else {
                    print("Failed to fetch library: " + (error?.localizedDescription)!)
                    return
                }
                
                guard let ids = objects else {
                    return
                }
                
                self.combine(parsedIds: ids)
                self.results[status] = true
                print("Fetched \(status.rawValue) for id: \(self.userID)")
            }
            
            deleteBlock.addDependency(operation)
            operations.append(operation)
        }
        
        //Start the operations
        queue.addOperations(operations, waitUntilFinished: false)
    }
    
    override public func cancel() {
        queue.cancelAllOperations()
        super.cancel()
        queue.addOperation {
            self.completeOperation()
        }
    }
}
