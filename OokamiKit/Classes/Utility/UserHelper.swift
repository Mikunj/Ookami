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
    
    static var currentUser: CurrentUser = CurrentUser()
    static var database: Database = Database()
    
    private init() {}
    
    /// Delete entries from the given users library, if the id is not in the array.
    ///
    /// - Parameters:
    ///   - array: The array of entry ids that should not be deleted.
    ///   - type: The type of entries to check.
    ///   - id: The user id to check library of.
    @discardableResult static func deleteEntries(notIn array: [Int], type: Media.MediaType, forUser id: Int) {
        let entries = LibraryEntry.belongsTo(user: id)
            .filter("media.rawType = %@", type.rawValue)
            .filter("NOT id in %@", array)
        
        database.delete(entries)
    }
    
    /// Check whether the current user has the `media` with `id` in their library
    ///
    /// - Parameters:
    ///   - media: The media type
    ///   - id: The id of the media
    /// - Returns: Whether the media is present in the user's library
    static func currentUserHas(media: Media.MediaType, id: Int) -> Bool {
        guard let currentID = currentUser.userID else {
            return false
        }
        
        let entries = LibraryEntry.belongsTo(user: currentID).filter("media.id = %d AND media.rawType = %@", id,  media.rawValue)
        return entries.count > 0
    }
}
