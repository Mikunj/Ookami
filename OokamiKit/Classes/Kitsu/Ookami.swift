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
    
    //Heimdallr client
    public lazy var heimdallr: Heimdallr = {
        let keys = OokamiKeys()
        let credentials = OAuthClientCredentials(id: keys.kitsuClientKey(), secret: keys.kitsuClientSecret())
        
        let tokenURL = URL(string: Ookami.Constants.URL.authToken)!
        let heim = Heimdallr(tokenURL: tokenURL, credentials: credentials)
        return heim
    }()
    
    //Networking client
    public lazy var networkClient: NetworkClient = {
        let client = NetworkClient(baseURL: Ookami.Constants.URL.api, heimdallr: self.heimdallr)
        return client
    }()
    
    //Authentication
    public lazy var authenticator: KitsuAuthenticator = {
        let authenticator = KitsuAuthenticator(heimdallr: self.heimdallr)
        return authenticator
    }()
    
}

//MARK: Constants
extension Ookami {
    
    /// Constants for the app
    struct Constants {
        
        private init() {}
        
        /// Urls that we use
        struct URL {
            static let kitsu = "http://staging.kitsu.io"
            static let api = "\(kitsu)/api/edge"
            static let authToken = "\(kitsu)/api/oauth/token"
        }
        
        
    }
}
