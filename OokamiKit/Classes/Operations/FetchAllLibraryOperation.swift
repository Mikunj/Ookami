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
    
    public typealias FetchCompletion = ([StatusError]) -> Void
    public typealias StatusError = (LibraryEntry.Status, Error)
    
    var queue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 5
        return q
    }()
    
    /// An array containing tuples with indicate whether a status failed, includes the error in the tuple
    var failed: [StatusError] = []
    
    /// The endpoint url for fetching library entries
    public let url: String
    
    /// The id of the user to fetch the library for
    public let userID: Int
    
    /// The client to use for executing requests
    public let client: NetworkClientProtocol
    
    /// The completion block
    let fetchCompletion: FetchCompletion
    
    /// The type of library being fetched
    let type: Media.MediaType
    
    /// The entry ids recieved from fetching. Used later for deleting unwanted entries
    var ids: [Int] = []
    
    
    /// Create a library operation to fetch all of the users library for a given type
    ///
    /// - Parameters:
    ///   - relativeURL: The api url for library get
    ///   - userID: The user id to fetch the library for
    ///   - type: The type of library to fetch
    ///   - client: The network client to execute request on
    ///   - completion: The completion callback which passes an array of tuples of kind `(LibraryEntry.Status, Error)` which are set when a status failed to fetch
    public init(relativeURL: String, userID: Int, type: Media.MediaType, client: NetworkClientProtocol, completion: @escaping FetchCompletion) {
        self.url = relativeURL
        self.userID = userID
        self.client = client
        self.fetchCompletion = completion
        self.type = type
        
    }
    
    /// Get the delete operation with the given entry ids
    func deleteOperation(withEntryIds ids: [Int]) -> DeleteEntryOperation {
        return DeleteEntryOperation(userID: userID, type: type, ids: ids, mode: .notInArray, realm: RealmProvider.realm)
    }
    
    /// Get the block operation which checks whether we can delete
    func deleteBlockOperation() -> BlockOperation {
        return BlockOperation {
            
            //Make sure we didn't fail before executing the deletion method
            guard self.failed.isEmpty else {
                self.fetchCompletion(self.failed)
                self.completeOperation()
                return
            }
            
            //Start the delete operation
            let dOperation = self.deleteOperation(withEntryIds: self.ids)
            dOperation.completionBlock = {
                self.fetchCompletion(self.failed)
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
        LibraryEntry.Status.all.forEach { status in
            let request = LibraryGETRequest(userID: userID, relativeURL: url)
            request.filter([.media(type: type), .status(status)])
            request.include([.genres, .user])
            
            let operation = FetchLibraryOperation(request: request, client: client) { objects, error in
                guard error == nil else {
                    self.failed.append((status, error!))
                    print("Failed to fetch \(status.rawValue) library: " + (error?.localizedDescription)!)
                    return
                }
                
                guard let entryIds = objects else {
                    return
                }
                
                self.ids.append(contentsOf: entryIds)
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
