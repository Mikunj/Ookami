//
//  OokamiTokenStore.swift
//  Ookami
//
//  Created by Maka on 23/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Heimdallr

/// A custom token store class for Heimdallr as the default KeychainStore implementation was not working
public class OokamiTokenStore: OAuthAccessTokenStore {
    
    let defaults = UserDefaults.standard
    
    //Keys constants
    struct Keys {
        private init() {}
        static let accessToken = "access_token"
        static let tokenType = "token_type"
        static let expiresAt = "expires_at"
        static let refreshToken = "refresh_token"
    }
    
    public init() {
    }
    
    public func clearStoredToken() {
        defaults.removeObject(forKey: Keys.accessToken)
        defaults.removeObject(forKey: Keys.tokenType)
        defaults.removeObject(forKey: Keys.expiresAt)
        defaults.removeObject(forKey: Keys.refreshToken)
    }
    
    public func storeAccessToken(_ accessToken: OAuthAccessToken?) {
        guard let accessToken = accessToken else {
            clearStoredToken()
            return
        }
        
        defaults.set(accessToken.accessToken, forKey: Keys.accessToken)
        defaults.set(accessToken.tokenType, forKey: Keys.tokenType)
        defaults.set(accessToken.expiresAt?.timeIntervalSince1970.description, forKey: Keys.expiresAt)
        defaults.set(accessToken.refreshToken, forKey: Keys.refreshToken)
    }
    
    public func retrieveAccessToken() -> OAuthAccessToken? {
        let accessToken = defaults.value(forKey: Keys.accessToken) as! String?
        let tokenType = defaults.value(forKey: Keys.tokenType) as! String?
        let refreshToken = defaults.value(forKey: Keys.refreshToken) as! String?
        let e = defaults.value(forKey: Keys.expiresAt) as! String?
        let expiresAt = e.flatMap { description in
            Double(description).flatMap { timeInterval in
                return Date(timeIntervalSince1970: timeInterval)
            }
        }
        
        if let accessToken = accessToken, let tokenType = tokenType {
            return OAuthAccessToken(accessToken: accessToken, tokenType: tokenType, expiresAt: expiresAt, refreshToken: refreshToken)
        }
        
        return nil
    }

}
