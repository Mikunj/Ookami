//
//  CurrentUser.swift
//  Ookami
//
//  Created by Maka on 1/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import Heimdallr

//A class that is used to store current user data.
public class CurrentUser {
    
    /// The heimdallr class used for OAuth2 authentication
    let heimdallr: Heimdallr
    
    /// The key used to store the username in user defaults
    let userIDKey: String

    /// The id of the user that is logged in, nil if not logged in
    public internal(set) var userID: Int? {
        get {
            return UserDefaults.standard.object(forKey: self.userIDKey) as? Int
        }
        
        set(id) {
            if id != nil {
                UserDefaults.standard.set(id, forKey: self.userIDKey)
            } else {
                UserDefaults.standard.removeObject(forKey: self.userIDKey)
            }
        }
    }
    
    //The user object of the currently logged in user, nil if not logged in
    public var user: User? {
        guard let id = userID else {
            return nil
        }
        return User.get(withId: id)
    }
    
    /// Create a class for storing user data
    ///
    /// - Parameters:
    ///   - heimdallr: The heimdallr instance which is used for `logout` and `isLoggedIn`
    ///   - userIDKey: A string key which is used for storing the user id.
    public init(heimdallr: Heimdallr = Ookami.shared.heimdallr, userIDKey: String = "kitsu_loggedin_user") {
        self.heimdallr = heimdallr
        self.userIDKey = userIDKey
    }

    /// Logout the current user
    public func logout() {
        heimdallr.clearAccessToken()
        userID = nil
    }
    
    /// Check if a user is logged in
    /// Note: This will only return true if we have a token, not if we have stored the user id
    ///
    /// - Returns: True or false if user is logged in
    public func isLoggedIn() -> Bool {
        return heimdallr.hasAccessToken
    }
}
