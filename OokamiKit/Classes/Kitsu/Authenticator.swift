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
public class Authenticator {
    
    /// The heimdallr class used for OAuth2 authentication
    let heimdallr: Heimdallr
    
    /// The key used to store the username in user defaults
    let userIDKey: String
    
    //The user api
    lazy var userService: UserService = {
        var service = UserService()
        service.authenticator = self
        return service
    }()
    
    //The library api
    lazy var libraryService: LibraryService = {
        var service = LibraryService()
        service.authenticator = self
        return service
    }()
    
    /// The id of the user that is logged in, nil if not logged in
    public internal(set) var currentUserID: Int? {
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
    public var currentUser: User? {
        guard let id = currentUserID else {
            return nil
        }
        return User.get(withId: id)
    }
    
    /// Create an authenticator
    ///
    /// - Parameter heimdallr: The heimdallr instance configured properley for authentication.
    /// - Parameter userIDKey: The key used for storing the userID
    public init(heimdallr: Heimdallr = Ookami.shared.heimdallr, userIDKey: String = "kitsu_loggedin_user") {
        self.heimdallr = heimdallr
        self.userIDKey = userIDKey
    }
    
    /// Update the information for the current logged in user
    ///
    /// - Parameter completion: The completion block which gets called when user info has been updated
    public func updateInfo(completion: @escaping (Error?) -> Void) {
        userService.getSelf { [weak self] user, error in
            guard let user = user else {
                completion(error)
                return
            }
            self?.currentUserID = user.id
            self?.libraryService.getAll(userID: user.id, type: .anime) { _ in }
            self?.libraryService.getAll(userID: user.id, type: .manga) { _ in }
            completion(nil)
        }
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
                
                // We only want to call the completion block after we are certain we have the correct user info
                // updateInfo will pass back an error if it failed so we can directly pass it onto the completion block
                self.updateInfo() { error in
                    completion(error)
                }
                
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
        currentUserID = nil
    }
    
    /// Check if a user is logged in/
    /// Note: This will only return true if we have a token, not if we have stored the username
    ///
    /// - Returns: True or false if user is logged in
    public func isLoggedIn() -> Bool {
        return heimdallr.hasAccessToken
    }
    
}
