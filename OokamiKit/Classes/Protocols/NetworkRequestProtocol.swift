//
//  NetworkRequestProtocol.swift
//  Ookami
//
//  Created by Maka on 6/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Alamofire

public protocol NetworkRequestProtocol {
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
    var needsAuth: Bool { get }
    var relativeURL: String { get }
}
