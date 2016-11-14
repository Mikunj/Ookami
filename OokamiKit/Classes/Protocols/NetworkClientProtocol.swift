//
//  NetworkClientProtocol.swift
//  Ookami
//
//  Created by Maka on 6/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol NetworkClientProtocol {
    
    /// The base url of the api
    var baseURL: String { get }
    
    /// Execute a network request
    ///
    /// - Parameters:
    ///   - request: The network request
    ///   - completion: The callback closure. Passes JSON data and error.
    func execute(request: NetworkRequestProtocol, completion: @escaping (JSON?, Error?) -> Void)
}
