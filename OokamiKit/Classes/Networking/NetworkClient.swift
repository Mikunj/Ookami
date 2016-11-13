//
//  NetworkClient.swift
//  Ookami
//
//  Created by Maka on 6/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Heimdallr
import Alamofire
import SwiftyJSON

public enum NetworkClientError: Error {
    case error(String)
    case authenticationError(String)
    case urlEncodingError
}

public class NetworkClient: NetworkClientProtocol {
    let heim: Heimdallr
    let baseURL: String
    let sessionManager: SessionManager
    
    /// Create a network client
    ///
    /// - Parameters:
    ///   - baseURL: The base URL to use for the client
    ///   - heimdallr: The Heimdallr instance used for OAuth2 authentication
    ///   - sessionManager: The Alamofire session manager
    public init(baseURL: String, heimdallr: Heimdallr, sessionManager: SessionManager = SessionManager.default) {
        self.heim = heimdallr
        self.baseURL = baseURL
        self.sessionManager = sessionManager
    }
    
    /// Execute a request.
    /// This encodes the request using JSONEncoding and will only return JSON objects or an Error
    ///
    /// - Parameters:
    ///   - request: The request
    ///   - completion: The callback block. Passes JSON and error
    public func execute(request: NetworkRequestProtocol, completion: @escaping (JSON?, Error?) -> Void) {
        let urlString = "\(baseURL)\(request.relativeURL)"
        guard let url = URL(string: urlString) else {
            completion(nil, NetworkClientError.error("Failed to construct URL"))
            return
        }
        
        do {
            let urlRequest = try URLRequest(url: url, method: request.method, headers: request.headers)
            var encodedURLRequest =  try! URLEncoding.default.encode(urlRequest, with: request.parameters)
            encodedURLRequest.setValue("application/vnd.api+json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            encodedURLRequest.setValue("application/vnd.api+json", forHTTPHeaderField: "Accept")
            
            //check for authentication
            if request.needsAuth {
                heim.authenticateRequest(encodedURLRequest) { result in
                    switch result {
                    case .success(let signedRequest):
                        self.run(request: signedRequest, completion: completion)
                        break
                    case .failure(let error):
                        completion(nil, NetworkClientError.authenticationError(error.localizedDescription))
                        break
                    }
                }
            } else {
                run(request: encodedURLRequest, completion: completion)
            }
            
        } catch {
            completion(nil, NetworkClientError.urlEncodingError)
        }
    }
    
    /// Start the request
    ///
    /// - Parameters:
    ///   - request: The URL request
    ///   - completion: The callback block
    private func run(request: URLRequest, completion: @escaping (JSON?, Error?) -> ()) {
        self.sessionManager.request(request).validate().responseJSON { response in
            switch response.result {
                case .success(let data):
                    completion(JSON(data), nil)
                    break
                case .failure(let error):
                    completion(nil, error)
                    break
            }
        }
    }
}
