//
//  KitsuRequest.swift
//  Ookami
//
//  Created by Maka on 28/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Alamofire

//Note: We can probably use this for other request types other than GET.

/// A class for building GET netowrk requests
public class KitsuRequest {
    
    public let url: String
    public let headers: HTTPHeaders?
    public let needsAuth: Bool
    
    //Request specific variables
    public internal(set) var includes: [String] = []
    public internal(set) var filters: [String: Any] = [:]
    
    //TODO: Allow sorting on multiple attributes
    //refer-to: http://docs.kitsu17.apiary.io/#introduction/json-api/sorting
    public internal(set) var sort: String?
    
    /// Create a kitsu GET request
    ///
    /// - Parameters:
    ///   - url: The relative url endpoint of the request
    ///   - headers: Any headers to include with the request
    ///   - needsAuth: Whether the request needs authentication
    public init(relativeURL url: String, headers: HTTPHeaders? = nil, needsAuth: Bool = false) {
        self.url = url
        self.headers = headers
        self.needsAuth = needsAuth
    }
    
    /// Build the network request
    ///
    /// - Returns: The network request
    public func build() -> NetworkRequest {
        return NetworkRequest(relativeURL: url, method: .get, parameters: parameters(), headers: headers, needsAuth: needsAuth)
    }
    
    /// Get the parameter dictionary
    ///
    /// - Returns: The parameters dictionary for this request
    func parameters() -> Parameters {
        var params: Parameters = [:]
        params["include"] = includes.joined(separator: ",")
        params["filter"] = filters
        
        if let sort = sort {
            params["sort"] = sort
        }
        
        //params["page"] = ["offset": page.offset, "limit": page.limit]
        return params
    }
    
    /// Add a filter to the request
    ///
    /// - Parameters:
    ///   - key: The filter key
    ///   - value: The filter value
    public func filter(key: String, value: Any) {
        filters[key] = value
    }
    
    /// Add include values to the request
    ///
    /// - Parameter values: The values to put in include
    public func include(_ values: String...) {
        includes.append(contentsOf: values)
    }
    
    /// Add sort to the request
    ///
    /// - Parameters:
    ///   - by: The value to sort by
    ///   - ascending: Whether to sort in ascending order or descending order.
    public func sort(by: String?, ascending: Bool = true) {
        guard let value = by else {
            sort = nil
            return
        }
        
        let modifier = ascending ? "" : "-"
        self.sort = "\(modifier)\(value)"
    }
    
    /// Create a copy of the request
    ///
    /// TODO: Find a better way to implement this because currently everytime you subclass, you have to reimplement this function in that subclass
    ///
    /// - Returns: The copied request
    public func copy() -> KitsuRequest {
        let request = KitsuRequest(relativeURL: url, headers: headers, needsAuth: needsAuth)
        request.includes = includes
        request.filters = filters
        request.sort = sort
        return request
    }
}
