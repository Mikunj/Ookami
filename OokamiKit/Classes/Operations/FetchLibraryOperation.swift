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

/// Operation to fetch all the entries in a library for a given status
public class FetchLibraryOperation: AsynchronousOperation {
    
    //The request
    let request: KitsuLibraryRequest
    
    /// The completion block which is called at the end
    public typealias FetchCompleteBlock = (Error?) -> Void
    public typealias OnFetchBlock = ([Object]) -> Void

    //Block which gets called everytime we get a page
    let onFetch: OnFetchBlock
    
    //Block that gets called when fetch is finished
    let fetchComplete: FetchCompleteBlock
    
    /// The network client
    let client: NetworkClientProtocol
    
    //The library we're going to use for fetching
    var library: PaginatedLibrary? = nil
    
    
    /// Create a library fetch operation that will fetch all pages in a library.
    ///
    /// Note that this will use a new copy of the request passed in.
    ///
    /// - Parameters:
    ///     - request: The library request
    ///     - client: The network client to use for executing the request
    ///     - onFetch: A callback which gets called everytime entries are fetched, and return entries aswell as related objects. This can be called multiple times.
    ///     - completion: The completion block which passes an error if failed to fetch
    public init(request: KitsuLibraryRequest, client: NetworkClientProtocol, onFetch: @escaping OnFetchBlock, completion: @escaping FetchCompleteBlock) {
        self.request = request.copy() as! KitsuLibraryRequest
        self.fetchComplete = completion
        self.onFetch = onFetch
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
            library = PaginatedLibrary(request: request, client: client) { objects, error, _ in
     
                //Check for completion
                guard error == nil else {
                    
                    //Check if we have reached the max page
                    if error! == PaginationError.noNextPage {
                        self.fetchComplete(nil)
                    } else {
                        self.fetchComplete(error)
                    }
                    self.completeOperation()
                    return
                }
                
                //Pass back the objects
                if let parsed = objects {
                    self.onFetch(parsed)
                }
                
                //Get the next page
                self.fetchNextPage()
            }
            
            library?.start()
        } else {
            library?.next()
        }
    
    }
    
    override public func main() {
        fetchNextPage()
    }
}
