//
//  BaseService.swift
//  Ookami
//
//  Created by Maka on 24/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation

public class BaseService {
    
    public enum ServiceError: Error {
        case error(description: String)
        case notAuthenticated
    }
    
    ///The database to use
    public var database: Database = Database()
    
    ///The authenticator to use.
    public weak var authenticator: Authenticator?
    
    //The operation queue to use
    public internal(set) var queue: OperationQueue
    
    //The network client
    public internal(set) var client: NetworkClient
    
    /// Create a api class
    ///
    /// - Parameters:
    ///   - queue: The operation queue
    ///   - client: The network client
    public init(queue: OperationQueue = Ookami.shared.queue, client: NetworkClient = Ookami.shared.networkClient) {
        self.queue = queue
        self.client = client
    }
}
