//
//  AuthenticationService.swift
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
public class AuthenticationService: BaseService {
    
    //The user service
    var userService: UserService = UserService()
    
    //The library service
    var libraryService: LibraryService = LibraryService()
    
    /// Update the information for the current logged in user.
    ///
    /// - Parameter completion: The completion block which gets called when user info has been updated.
    public func updateInfo(completion: @escaping (Error?) -> Void) {
        userService.getSelf { user, error in
            guard let user = user else {
                completion(error)
                return
            }
            self.currentUser.userID = user.id
            self.libraryService.getAll(userID: user.id, type: .anime) { _ in }
            self.libraryService.getAll(userID: user.id, type: .manga) { _ in }
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
        currentUser.heimdallr.requestAccessToken(username: username, password: password) { result in
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
}
