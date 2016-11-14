//
//  NetworkRequestProtocol.swift
//  Ookami
//
//  Created by Maka on 6/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Alamofire

//The type of url specified in the request
public enum NetworkRequestURLType {
    case relative
    case absolute
}

public protocol NetworkRequestProtocol {
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
    var needsAuth: Bool { get }
    var url: String { get }
    var urlType: NetworkRequestURLType { get }
}
