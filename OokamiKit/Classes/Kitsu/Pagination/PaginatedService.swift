//
//  PaginatedService.swift
//  Ookami
//
//  Created by Maka on 7/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

///A class which handles pagination and the requests
///
/// How this works is that it will first fetch objects through the request passed in.
/// There after it will use the links provided from the response to preform the rest of the fetches.
/// If at any point a request fails, then the current link state will not be overriden.
///
/// E.g nextLink = 5, base.next() -> fails, nextLink will still be 5, thus calling next again will try perform the request again
public class PaginatedService {
    
    ///A bool to track whether we called the original request, using `start()`
    ///This is specifically used as to not cause an infinite loop when calling the functions such as `next()` and `prev()` etc
    var calledOriginalRequest: Bool = false
    
    /// The completion block type, return the the fetched objects on the current page, or an Error if something went wrong, and a bool to indicate if it's the original request
    public typealias PaginatedBaseCompletion = ([Object]?, Error?, Bool) -> Void
    
    /// The JSON Parser
    public var parser: Parser = Parser()
    
    /// The queue for executing the pagination requests on
    var queue: OperationQueue = {
        let q = OperationQueue()
        //Make it serial
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    /// The get request that gets passed in
    let originalRequest: KitsuPagedRequest
    public var request: KitsuPagedRequest {
        return originalRequest.copy() as! KitsuPagedRequest
    }
    
    /// The current operation that is on going
    var currentOperation: Operation? = nil
    
    /// The client to execute request on
    let client: NetworkClientProtocol
    
    /// The completion block which gets called everytime a request was successful
    let completion: PaginatedBaseCompletion
    
    /// The links for pagination
    public internal(set) var links: Links = Links()
    
    /// Create a paginated class.
    /// call `start()` to begin the fetch
    ///
    /// - Parameters:
    ///   - request: The paged kitsu request
    ///   - client: The client to execute request on
    ///   - completion: The completion block, returns the fetched entries and related objects on the current page, or an Error if something went wrong.
    ///                 This gets called everytime a page of entries is recieved.
    ///                 This can be through calls such as `next()`, `prev()` etc ...
    public init(request: KitsuPagedRequest, client: NetworkClientProtocol, completion: @escaping PaginatedBaseCompletion) {
        self.originalRequest = request.copy() as! KitsuPagedRequest
        self.client = client
        self.completion = completion
    }
    
    //MARK: - Requesting
    
    /// Perform a request on the client
    ///
    /// - Parameter request: The network request
    /// - Parameter isOriginal: Whether the request is the original request
    func perform(request: NetworkRequest, isOriginal: Bool = false) {
        
        //Check if we have an operation on going
        if currentOperation != nil {
            return
        }
        
        currentOperation = NetworkOperation(request: request, client: client) { json, error in
            
            //Check for errors
            guard error == nil else {
                self.completion(nil, error, isOriginal)
                return
            }
            
            //Check we have the JSON
            guard json != nil else {
                self.completion(nil, PaginationError.invalidJSONRecieved, isOriginal)
                return
            }
            
            //Set the bool to indicate we have called the original request
            if isOriginal {
                self.calledOriginalRequest = true
            }
            
            //Update the links
            self.updateLinks(fromJSON: json!)
            
            //Parse the response
            self.parser.parse(json: json!) { parsed in
                self.currentOperation = nil
                self.completion(parsed, nil, isOriginal)
            }
            
        }
        queue.addOperation(currentOperation!)
    }
    
    /// Update the link state from the recieved json.
    /// - Important: If no link dictionary is found in the json then it sets all the links to nil
    ///
    /// - Parameter json: The json object
    func updateLinks(fromJSON json: JSON) {
        let links = json["links"]
        if links.exists() && links.type == .dictionary {
            self.links.first = links["first"].string
            self.links.next = links["next"].string
            self.links.previous = links["prev"].string
            self.links.last = links["last"].string
        } else {
            self.links.first = nil
            self.links.next = nil
            self.links.previous = nil
            self.links.last = nil
        }
    }
    
    //MARK: - Methods
    
    /// Get the network request for an absolute link
    ///
    /// - Parameter link: The absolute link
    /// - Returns: The request for the link
    func request(for link: String) -> NetworkRequest {
        //When we get the link, it should automatically have the baseURL tacked onto it, so we can get away with passing the full url to it
        return NetworkRequest(absoluteURL: link, method: .get)
    }
    
    
    /// Perform a request for a given link
    ///
    /// - Parameters:
    ///   - link: The link
    ///   - nilError: The error to pass if link was nil
    func performRequest(for link: String?, nilError: PaginationError) {
        //If we haven't called the original request then call it.
        //This is to stop an infinite recursion from occurring which can happen if a client keeps calling functions such as `next()` and `prev()`
        guard calledOriginalRequest else {
            start()
            return
        }
        
        //At this point we know that `start()` has been called.
        //However if we still don't have any links then that must mean the links were not in the response.
        //We also check that if it does have links, that the current passed in link is valid.
        guard links.hasAnyLinks(), link != nil else {
            self.completion(nil, nilError, false)
            return
        }
        
        perform(request: request(for: link!))
    }
    
    /// Cancel the current operation
    public func cancel() {
        currentOperation?.cancel()
        currentOperation = nil
    }
    
    /// Send out the original request
    public func start() {
        let nRequest = request.build()
        perform(request: nRequest, isOriginal: true)
    }
    
    /// Get the next page
    public func next() {
        performRequest(for: links.next, nilError: .noNextPage)
    }
    
    /// Get the previous page
    public func prev() {
        performRequest(for: links.previous, nilError: .noPreviousPage)
    }
    
    /// Get the first page
    public func first() {
        performRequest(for: links.first, nilError: .noFirstPage)
    }
    
    /// Get the last page
    public func last() {
        performRequest(for: links.last, nilError: .noLastPage)
    }
    
}

//MARK:- Structs
extension PaginatedService {
    
    /// Struct for holding the pagination link state
    public struct Links {
        public var first: String?
        public var next: String?
        public var previous: String?
        public var last: String?
        
        /// Check whether there is any link that is not nil
        ///
        /// - Returns: Whether there is a link that is not nil
        public func hasAnyLinks() -> Bool {
            return first != nil || next != nil || previous != nil || last != nil
        }
    }
}

//MARK:- Error
public enum PaginationError : Error {
    case invalidJSONRecieved
    case noNextPage
    case noPreviousPage
    case noFirstPage
    case noLastPage
}

