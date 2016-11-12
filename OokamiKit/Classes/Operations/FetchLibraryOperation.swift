//
//  FetchLibraryOperation.swift
//  Ookami
//
//  Created by Maka on 9/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

public enum FetchLibraryOperationError: Error {
    case error(String)
    case failedToFetchPage(offset: Int, error: Error?)
    case badJSONRecieved
}

/// Operation to fetch the entries in a library for a given status
public class FetchLibraryOperation: AsynchronousOperation {
    
    var queue: OperationQueue = {
        let q = OperationQueue()
        //Make it serial
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    let request: LibraryGETRequest
    
    /// The completion block which is called at the end
    typealias FetchedObjects = [String: [Any]]
    typealias FetchCompleteBlock = (FetchedObjects?, FetchLibraryOperationError?) -> Void

    var fetchedObjects: FetchedObjects = [:]
    let fetchComplete: FetchCompleteBlock
    
    /// The network client
    let client: NetworkClientProtocol
    
    /// Whether the operation errored when fetching a page
    var didError: Bool = false
    
    /// Create a library fetch operation that will fetch all pages in a library.
    ///
    /// Note that this will use a new copy of the request passed in.
    ///
    /// - Parameter request: The request
    /// - Parameter client: The network client to use for executing the request
    /// - Parameter completion: The completion block.
    ///                         Passes back a dictionary of type `[String: [Any]]?` which contains the ids of the parsed objects, where the key is the object type
    ///                         Passes an error instead if failed to fetch
    init(request: LibraryGETRequest, client: NetworkClientProtocol, completion: @escaping FetchCompleteBlock) {
        self.request = request.copy() as! LibraryGETRequest
        self.fetchComplete = completion
        self.client = client
    }
    
    /// Fetch the current page
    func fetchCurrentPage() {
        //Check that we haven't been cancelled
        if self.isCancelled {
            self.completeOperation()
            return
        }
        
        let nRequest = request.build()
        
        //Operation to recursively fetch pages
        let checkPage = BlockOperation {
            self.request.nextPage()
            self.fetchCurrentPage()
        }
        
        //Operation to complete this fetch, this is in a block because we will need to add it after the parsing operation
        let operationCompletedBlock = operationCompleted()
        
        let operation = NetworkOperation(request: nRequest, client: client) { json, error in
            
            //Check for page errors
            guard error == nil else {
                self.didError = true
                
                /*
                 We can get away with not exiting early here and instead continue to fetch the rest of the pages.
                 The problem with that is that we must find the max offset from the first page call, or else we would be stuck in an infinite recursive loop
                 */
                self.fetchComplete(nil, .failedToFetchPage(offset: self.request.page.offset, error: error))
                self.cancel()
                self.completeOperation()
                return
            }
            
            //Check if we have the json
            guard let json = json else {
                self.fetchComplete(nil, .badJSONRecieved)
                self.cancel()
                self.completeOperation()
                return
            }
            
            //Parse the response
            let pOperation = self.parsingOperation(forJSON: json)
            self.queue.addOperation(pOperation)
            
            //Check if we can fetch next page or not
            let links = json["links"]
            if links.type == .dictionary && links["next"].exists() {
                
                //Get the next page
                checkPage.addDependency(pOperation)
                self.queue.addOperation(checkPage)
            } else {
                
                //There is no next page, so we finish the operation
                operationCompletedBlock.addDependency(pOperation)
                self.queue.addOperation(operationCompletedBlock)
            }
        }
        
        //Add the operation to the queue
        queue.addOperation(operation)
    }
    
    /// Get the block operation for completing the operation.
    /// This gets called when there are no more pages to fetch
    ///
    /// - Returns: The block operation called when
    func operationCompleted() -> BlockOperation {
        return BlockOperation {
            if !self.isCancelled {
                self.fetchComplete(self.fetchedObjects, nil)
            }
            self.completeOperation()
        }
    }
    
    /// Return the parsing operation for given json
    ///
    /// - Parameter json: The json object
    func parsingOperation(forJSON json: JSON) -> ParsingOperation {
        return ParsingOperation(json: json, realm: RealmProvider.realm) { parsed, badObjects in
            //Add the parsed objects id
            if parsed != nil {
                self.add(toFetchedObjects: parsed!)
            }
            
            if let count = badObjects?.count, count > 0{
                print("Some JSON didn't parse properley!")
            }
        }
    }
    
    
    /// Add objects from another dictionary to the fetched objects
    ///
    /// - Parameter objects: The objects to add
    func add(toFetchedObjects objects: FetchedObjects) {
        for (key, ids) in objects {
            if self.fetchedObjects.keys.contains(key) {
                ids.forEach { self.fetchedObjects[key]!.append($0) }
            } else {
                self.fetchedObjects[key] = ids
            }
        }
    }
    
    override public func main() {
        fetchCurrentPage()
    }
    
    override public func cancel() {
        queue.cancelAllOperations()
        super.cancel()
        queue.addOperation(operationCompleted())
    }
}
