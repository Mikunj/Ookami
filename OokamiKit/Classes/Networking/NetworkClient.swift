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

extension NetworkClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(let string):
            return string
        case .authenticationError(let string):
            return string
        case .urlEncodingError:
            return "Failed to encode URL"
        }
    }
}

public class NetworkClient: NetworkClientProtocol {
    
    public internal(set) var baseURL: String
    let heim: Heimdallr
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
        
        //Set the user agent on the manager
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "x"
        self.sessionManager.session.configuration.httpAdditionalHeaders = ["User-Agent": "Ookami-\(version)"]
    }
    
    /// Execute a request.
    /// This encodes the request using JSONEncoding and will only return JSON objects or an Error
    ///
    /// - Parameters:
    ///   - request: The request
    ///   - completion: The callback block. Passes JSON and error
    public func execute(request: NetworkRequestProtocol, completion: @escaping (JSON?, Error?) -> Void) {
        var urlString: String!
        
        //Determine url from the url type
        switch request.urlType {
        case .absolute:
            urlString = request.url
            break
        case .relative:
            urlString = "\(baseURL)\(request.url)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil, NetworkClientError.error("Failed to construct URL"))
            return
        }
        
        do {
            let encoding: ParameterEncoding = request.method == .get ? URLEncoding.default : JSONEncoding.default
            let urlRequest = try URLRequest(url: url, method: request.method, headers: request.headers)
            var encodedURLRequest =  try! encoding.encode(urlRequest, with: request.parameters)
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
                
                //Try and extract the error from the JSON
                if let data = response.data ,
                    let stringData = String(data: data, encoding: .utf8),
                    let errorString = JSON(parseJSON: stringData)["errors"][0]["detail"].string {
                    completion(nil, NetworkClientError.error(errorString.capitalized))
                }
                
                //If we failed then pass back the Alamofire error
                completion(nil, error)
                break
            }
        }
    }
}
