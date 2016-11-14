//
//  NetworkRequest.swift
//  Ookami
//
//  Created by Maka on 6/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Alamofire

public struct NetworkRequest: NetworkRequestProtocol {
    public var method: HTTPMethod
    public var parameters: Parameters?
    public var headers: HTTPHeaders?
    public var needsAuth: Bool
    public var url: String
    public internal(set) var urlType: NetworkRequestURLType
    
    /// Create a network request
    ///
    /// - Parameters:
    ///   - relativeURL: The relative url of the request. E.g /anime/1, /users/1
    ///   - method: The HTTP method
    ///   - parameters: The parameters of the request
    ///   - headers: The headers to use for the request
    ///   - needsAuth: Whether this request needs a user to be authenticated
    public init(relativeURL: String, method: HTTPMethod, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, needsAuth: Bool = false) {
        self.url = relativeURL
        self.urlType = .relative
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.needsAuth = needsAuth
    }
    
    /// Create a network request
    ///
    /// - Parameters:
    ///   - absoluteURL: The absolute url of the request. E.g https://kitsu.io/anime/1
    ///   - method: The HTTP method
    ///   - parameters: The parameters of the request
    ///   - headers: The headers to use for the request
    ///   - needsAuth: Whether this request needs a user to be authenticated
    public init(absoluteURL: String, method: HTTPMethod, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, needsAuth: Bool = false) {
        self.url = absoluteURL
        self.urlType = .absolute
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.needsAuth = needsAuth
    }
}
