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
    public var relativeURL: String
}
