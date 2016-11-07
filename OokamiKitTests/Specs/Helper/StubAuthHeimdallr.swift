//
//  StubAuthHeimdallr.swift
//  Ookami
//
//  Created by Maka on 7/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Heimdallr
import Result

/// A Heimdallr subclass which stubs authenticateRequest function
class StubAuthHeimdallr: Heimdallr {
    
    typealias VoidClosure = () -> Void
    
    var stubError: NSError?
    var authBlock: VoidClosure?
    
    init(stubError: NSError? = nil, authenticationBlock: VoidClosure? = nil) {
        super.init(tokenURL: URL(string: "http://kitsu.io")!)
        self.stubError = stubError
        self.authBlock = authenticationBlock
    }
    
    //A stub authenticate request that return a stub error or the request if stubError is not set
    //Also calls the callback block
    override func authenticateRequest(_ request: URLRequest, completion: @escaping (Result<URLRequest, NSError>) -> Void) {
        
        authBlock?()
        
        if stubError != nil {
            completion(.failure(stubError!))
        } else {
            completion(.success(request))
        }
    }
}
