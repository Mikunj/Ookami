//
//  UserHelper.swift
//  Ookami
//
//  Created by Maka on 28/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation

///A bunch of helper functions for user
public class UserHelper {
    
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
        let entries = LibraryEntry.belongsTo(user: id, type: type).filter("NOT id in %@", array)
        
        database.delete(entries)
    }
    
    /// Check whether the current user has the `media` with `id` in their library
    ///
    /// - Parameters:
    ///   - media: The media type
    ///   - id: The id of the media
    /// - Returns: Whether the media is present in the user's library
    static func currentUserHas(media: Media.MediaType, id: Int) -> Bool {
        return entry(forMedia: media, id: id) != nil
    }
    
    /// Get the entry with a given `type` and `id` that belongs to the current user
    ///
    /// - Parameters:
    ///   - type: The media type
    ///   - id: The id of the media
    /// - Returns: The library entry if current user has it, or nil if no entry is found with the given media type and id
    public static func entry(forMedia type: Media.MediaType, id: Int) -> LibraryEntry? {
        guard let currentID = currentUser.userID else {
            return nil
        }
        
        let entries = LibraryEntry.belongsTo(user: currentID, type: type).filter("media.id = %d", id)
        return entries.first
    }
}
