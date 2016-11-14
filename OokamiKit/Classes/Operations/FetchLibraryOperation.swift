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

/// Operation to fetch the entries in a library for a given status
public class FetchLibraryOperation: AsynchronousOperation {
    
    //The request
    let request: LibraryGETRequest
    
    /// The completion block which is called at the end
    public typealias FetchCompleteBlock = ([Int]?, Error?) -> Void

    var fetchedIds: [Int] = []
    let fetchComplete: FetchCompleteBlock
    
    /// The network client
    let client: NetworkClientProtocol
    
    //The library we're going to use for fetching
    var library: PaginatedLibrary? = nil
    
    
    /// Create a library fetch operation that will fetch all pages in a library.
    ///
    /// Note that this will use a new copy of the request passed in.
    ///
    /// - Parameter request: The request
    /// - Parameter client: The network client to use for executing the request
    /// - Parameter completion: The completion block.
    ///                         Passes back a an array of fetched library entry ids
    ///                         Passes an error instead if failed to fetch
    public init(request: LibraryGETRequest, client: NetworkClientProtocol, completion: @escaping FetchCompleteBlock) {
        self.request = request.copy() as! LibraryGETRequest
        self.fetchComplete = completion
        self.client = client
    }
    
    /// Fetch the current page
    func fetchNextPage() {
        //Check that we haven't been cancelled
        if self.isCancelled {
            self.completeOperation()
            return
        }
        
        //Setup the library
        if library == nil {
            library = PaginatedLibrary(request: request, client: client) { [weak self] ids, error in
                guard let strongSelf = self else { return }
                
                //Check for completion
                guard error == nil  else {
                    
                    //Check if we have reached the max page
                    if error! == PaginatedLibraryError.noNextPage {
                        strongSelf.fetchComplete(strongSelf.fetchedIds, nil)
                    } else {
                        //We can pass in the already fetched ids here if we want to, something to keep in mind
                        strongSelf.fetchComplete(nil, error)
                    }
                    strongSelf.completeOperation()
                    return
                }
                
                //Add the entries
                if let entryIds = ids {
                    strongSelf.fetchedIds.append(contentsOf: entryIds)
                }
                
                //Get the next page
                strongSelf.fetchNextPage()
            }
            
            library?.start()
        } else {
            library?.next()
        }
    
    }
    
    /// Get the block operation for completing the operation.
    /// This gets called when there are no more pages to fetch
    ///
    /// - Returns: The block operation called when
    func operationCompleted() -> BlockOperation {
        return BlockOperation {
            if !self.isCancelled {
                self.fetchComplete(self.fetchedIds, nil)
            }
            self.completeOperation()
        }
    }
    
    override public func main() {
        fetchNextPage()
    }
}
