//
//  Authenticator.swift
//  Ookami
//
//  Created by Maka on 23/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Heimdallr

/// Class for handling authentication to the kitsu servers
/// We use this instead of directly calling authenticate on a `Heimdallr` instance because we still have to do extra stuff after we authenticate the user.
/// Putting it in a class makes it simpler and easier to manage if we need to add extra things
public class KitsuAuthenticator {
    
    /// The heimdallr class used for OAuth2 authentication
    let heimdallr: Heimdallr
    
    /// The key used to store the username in user defaults
    let usernameKey = "kitsu_loggedin_user"
    
    //The user api
    var api = UserAPI()
    
    /// The name of the user that is logged in, nil if not logged in
    public internal(set) var currentUser: String? {
        get {
            return UserDefaults.standard.string(forKey: self.usernameKey)
        }
        
        set(name) {
            if name != nil {
                UserDefaults.standard.set(name, forKey: self.usernameKey)
            } else {
                UserDefaults.standard.removeObject(forKey: self.usernameKey)
            }
        }
    }
    
    /// Create an authenticator
    ///
    /// - Parameter heimdallr: The heimdallr instance configured properley for authentication.
    public init(heimdallr: Heimdallr) {
        self.heimdallr = heimdallr
    }
    
    /// Authenticate a user
    ///
    /// - Parameters:
    ///   - username: The username
    ///   - password: The password
    ///   - completion: Completion block which passes an error if it occured
    public func authenticate(username: String, password: String, completion: @escaping (Error?) -> Void) {
        heimdallr.requestAccessToken(username: username, password: password) { result in
            switch result {
                case .success:
                    
                    //Temporarily store the username passed in as the logged in username, but after fetching the user info it should be updated
                    //Reason is that the user may also use the email inplace of the username, thus we wouldn't have the correct user slug/name
                    self.currentUser = username
                    
                    self.api.getSelf { user, error in
                        guard let user = user else {
                            return
                        }
                        self.currentUser = user.name
                    }
                    
                    //TODO: Fetch user info here, things like profile info, library, etc
                    //will need to make sure that username is not an email?
                    completion(nil)
                    
                    break
                case .failure(let e):
                    completion(e)
                    break
            }
        }
    }
    
    /// Logout the current user
    public func logout() {
        heimdallr.clearAccessToken()
        currentUser = nil
    }
    
    /// Check if a user is logged in/
    /// Note: This will only return true if we have a token, not if we have stored the username
    ///
    /// - Returns: True or false if user is logged in
    public func isLoggedIn() -> Bool {
        return heimdallr.hasAccessToken
    }
    
}
