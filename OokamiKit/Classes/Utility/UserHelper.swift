//
//  UserHelper.swift
//  Ookami
//
//  Created by Maka on 28/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation

///A bunch of helper functions for user
class UserHelper {
    
    static var authenticator: Authenticator = Ookami.shared.authenticator
    static var database: Database = Database()
    
    private init() {}
    
    /// Check whether the current user has the `media` with `id` in their library
    ///
    /// - Parameters:
    ///   - media: The media type
    ///   - id: The id of the media
    /// - Returns: Whether the media is present in the user's library
    static func currentUserHas(media: Media.MediaType, id: Int) -> Bool {
        guard let currentID = authenticator.currentUserID else {
            return false
        }
        
        let entries = LibraryEntry.all().filter("userID = %d AND media.id = %d AND media.rawType = %@", currentID, id,  media.rawValue)
        return entries.count > 0
    }
}
