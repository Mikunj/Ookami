//
//  Ookami.swift
//  Ookami
//
//  Created by Maka on 23/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Heimdallr
import Keys

/// The main class which holds the top level objects
public class Ookami {
    
    /// Shared instance to use
    public static let shared: Ookami = {
        return Ookami()
    }()
    
    //The client credentials
    public var credentials: OAuthClientCredentials = {
        let keys = OokamiKeys()
        return OAuthClientCredentials(id: keys.kitsuClientKey, secret: keys.kitsuClientSecret)
    }()
    
    //Heimdallr client
    public lazy var heimdallr: Heimdallr = {
        let store = OokamiTokenStore()
        
        let tokenURL = URL(string: Constants.URL.authToken)! 
        let heim = Heimdallr(tokenURL: tokenURL, credentials: self.credentials, accessTokenStore: store)
        return heim
    }()
    
    //Networking client
    public lazy var networkClient: NetworkClient = {
        let client = NetworkClient(baseURL: Constants.URL.api, heimdallr: self.heimdallr)
        return client
    }()
    
    //The main operation queue of the application
    public lazy var queue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 5
        return q
    }()
    
}
