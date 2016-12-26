//
//  PaginatedLibrary.swift
//  Ookami
//
//  Created by Maka on 13/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
 The reason we have a paginated library class is because users won't look at ALL of another users library if you think about it.
 
 Say a user `A` looks at user `B`'s completed library which has 1000 entries. `A` won't bother looking through all 1000 entries of `B`, thus we can save time and data usage by adding in pagination, which is already supported by the api. This makes it so user `A` can still look at user `B`'s completed library, but if they wish to view more we just fetch the next page from the server for them.
 
 However we still need to be able to fetch a full users library regardless of pagination, thus the FetchLibraryOperation still exists. This is needed for the current user using the app. We need to reliably be able to sync between the website and the app (e.g if user deletes entry on website, then it should be deleted in app) and the only way to do that is to fetch the users whole library.
*/

/// Struct for holding the pagination link state
public struct PaginatedLibraryLinks {
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

public enum PaginatedLibraryError : Error {
    case invalidJSONRecieved
    case noNextPage
    case noPreviousPage
    case noFirstPage
    case noLastPage
}

/// Class for fetching a user's library paginated from the server.
///
/// How this works is that it will first fetch entries through the request passed in.
/// There after it will use the links provided from the response to preform the rest of the fetches.
/// If at any point a request fails, then the current link state will not be overriden.
///
/// E.g nextLink = 5, library.next() -> fails, nextLink will still be 5, thus calling next again will try perform the request again
public class PaginatedLibrary {
    
    /// The completion block type, return the ids of the fetched entries on the current page, or an Error if something went wrong
    public typealias PaginatedLibraryCompletion = ([Int]?, Error?) -> Void
    
    /// The queue for executing the pagination requests on
    var queue: OperationQueue = {
        let q = OperationQueue()
        //Make it serial
        q.maxConcurrentOperationCount = 1
        return q
    }()
    
    /// The library get requests passed in
    let originalRequest: LibraryGETRequest
    public var request: LibraryGETRequest {
        return originalRequest.copy() as! LibraryGETRequest
    }
    
    /// The client to execute request on
    let client: NetworkClientProtocol
    
    /// The completion block which gets called everytime a request was successful
    let completion: PaginatedLibraryCompletion
    
    /// The links for pagination
    public internal(set) var links: PaginatedLibraryLinks = PaginatedLibraryLinks()
    
    /// Create a paginated library.
    /// call `start()` to begin the fetch
    ///
    /// - Parameters:
    ///   - request: The library get request
    ///   - client: The client to execute request on
    ///   - completion: The completion block, return the ids of the fetched entries on the current page, or an Error if something went wrong
    ///                 This gets called everytime a page of entries is recieved.
    ///                 This can be through calls such as `next()`, `prev()` etc ...
    public init(request: LibraryGETRequest, client: NetworkClientProtocol, completion: @escaping PaginatedLibraryCompletion) {
        self.originalRequest = request.copy() as! LibraryGETRequest
        self.client = client
        self.completion = completion
    }

    //MARK: - Requesting
    
    /// Perform a request on the client
    ///
    /// - Parameter request: The network request
    func perform(request: NetworkRequest) {
        let operation = NetworkOperation(request: request, client: client) { [weak self] json, error in
            guard let strongSelf = self else { return }
            
            //Check for errors
            guard error == nil else {
                strongSelf.completion(nil, error)
                return
            }
            
            //Check we have the JSON
            guard json != nil else {
                strongSelf.completion(nil, PaginatedLibraryError.invalidJSONRecieved)
                return
            }
            
            //Update the links
            strongSelf.updateLinks(fromJSON: json!)
            
            //Parse the response
            let pOperation = strongSelf.parsingOperation(forJSON: json!)
            strongSelf.queue.addOperation(pOperation)
        }
        queue.addOperation(operation)
    }
    
    /// Return the parsing operation for given json
    ///
    /// - Parameter json: The json object
    func parsingOperation(forJSON json: JSON) -> ParsingOperation {
        return ParsingOperation(json: json, realm: RealmProvider().realm) { [weak self] parsed, badObjects in
            guard let strongSelf = self else { return }
            
            //We either parsed entries, or we didn't parse any.
            let entries = parsed?[LibraryEntry.typeString] as! [Int]? ?? []
            strongSelf.completion(entries, nil)
            
            //Some other messages
            if let count = badObjects?.count, count > 0 {
                print("Paginated Library: Some JSON didn't parse properley!")
            }
        }
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
    func performRequest(for link: String?, nilError: PaginatedLibraryError) {
        guard links.hasAnyLinks() else {
            start()
            return
        }
        
        guard link != nil else {
            completion(nil, nilError)
            return
        }
        
        perform(request: request(for: link!))
    }

    /// Send out the original request
    public func start() {
        let nRequest = request.build()
        perform(request: nRequest)
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
