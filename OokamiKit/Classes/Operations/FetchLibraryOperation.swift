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
    public typealias FetchedObjects = [String: [Any]]
    public typealias FetchCompleteBlock = (FetchedObjects?, FetchLibraryOperationError?) -> Void

    var fetchedObjects: FetchedObjects = [:]
    let fetchComplete: FetchCompleteBlock
    
    /// The network client
    let client: NetworkClientProtocol
    
    /// Whether the operation errored when fetching a page
    var didError: Bool = false
    
    //The max offset that we can go up to
    var maxOffset: Int? = nil
    
    /// Create a library fetch operation that will fetch all pages in a library.
    ///
    /// Note that this will use a new copy of the request passed in.
    ///
    /// - Parameter request: The request
    /// - Parameter client: The network client to use for executing the request
    /// - Parameter completion: The completion block.
    ///                         Passes back a dictionary of type `[String: [Any]]?` which contains the ids of the parsed objects, where the key is the object type
    ///                         Passes an error instead if failed to fetch
    public init(request: LibraryGETRequest, client: NetworkClientProtocol, completion: @escaping FetchCompleteBlock) {
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
            self.request.nextPage(maxOffset: self.maxOffset)
            self.fetchCurrentPage()
        }
        
        //Print out debug info, TODO: make this for debugging only, should not show in release
        if let statusIndex = request.getFilters()["status"] {
            let index = statusIndex as! Int
            let status: LibraryEntryStatus = LibraryEntryStatus.all[index - 1]
            print("Fetching page offset \(request.page.offset) for \(status.rawValue)")
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
            
            let links = json["links"]
            if links.type == .dictionary {
                //Get the max offset from the 'last' value in links
                if links["last"].exists() {
                    if self.maxOffset == nil {
                        self.maxOffset = self.getOffset(from: links["last"].stringValue)
                        if self.maxOffset != nil {
                            self.maxOffset! += 1
                        }
                    }
                }
                
                //Check if we can fetch next page or not
                if links["next"].exists() {
                    
                    //Get the next page
                    checkPage.addDependency(pOperation)
                    self.queue.addOperation(checkPage)
                } else {
                    
                    //There is no next page, so we finish the operation
                    operationCompletedBlock.addDependency(pOperation)
                    self.queue.addOperation(operationCompletedBlock)
                }
            }
        }
        
        //Add the operation to the queue
        queue.addOperation(operation)
    }
    
    ///Extract the offset from the given link
    func getOffset(from link: String) -> Int? {
        let regex = "offset%5D=(\\d+)"
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let linkString = link as NSString
            let results = regex.matches(in: link, range: NSRange(location: 0, length: linkString.length))
            
            guard results.count > 0 else {
                return nil
            }
            
            let values = results.map { linkString.substring(with: $0.rangeAt(1)) }
            return values.count == 1 ? Int(values.first!) : nil
        } catch {
            print("Error with regex pattern in FetchLibraryOperation.getOffset()")
            return nil
        }
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
