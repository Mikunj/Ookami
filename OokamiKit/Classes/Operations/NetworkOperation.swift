//
//  NetworkOperation.swift
//  Ookami
//
//  Created by Maka on 7/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A Operation for executing a request on a client
public class NetworkOperation: AsynchronousOperation {
    
    public let request: NetworkRequestProtocol
    public let client: NetworkClientProtocol
    public let networkCompletion: (JSON?, Error?) -> Void
    
    init(request: NetworkRequestProtocol, client: NetworkClientProtocol, completion: @escaping (JSON?, Error?) -> Void) {
        self.request = request
        self.client = client
        self.networkCompletion = completion
    }
    
    override public func main() {
        client.execute(request: request) { data, error in
            if !self.isCancelled {
                self.networkCompletion(data, error)
            }
            self.completeOperation()
        }
    }
}
