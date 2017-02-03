//
//  LibraryEntry.swift
//  Ookami
//
//  Created by Maka on 5/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

/*
 We don't need a compound key here are LibraryEntry - Media is a 1-to-1 relationship.
 If this does change in the future then a compound key will be needed
 We also don't need to restrict it to internal(set) because there is no compound key
 */
public class Media: Object, GettableObject {
    
    public typealias T = Media
    
    public enum MediaType: String {
        case anime
        case manga
    }
    
    public dynamic var entryID = -1
    public dynamic var id = -1
    public dynamic var rawType = ""
    public var type: MediaType? {
        return MediaType(rawValue: rawType)
    }
    
    override public static func primaryKey() -> String {
        return "entryID"
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["type"]
    }
    
}

public class LibraryEntry: Object, Cacheable {
    
    public enum Status: String {
        case current
        case planned
        case completed
        case onHold = "on_hold"
        case dropped
        
        public static let all: [Status] = [.current, .planned, .completed, .onHold, .dropped]
        
        ///Get the string representation of the status for a given media
        public func toString(forMedia type: Media.MediaType?) -> String {
            switch self {
            case .current:
                if type == nil {
                    return "Current"
                }
                return type == .anime ? "Currently Watching": "Currently Reading"
                
            case .planned:
                if type == nil {
                    return "Planning"
                }
                return type == .anime ? "Plan to Watch": "Plan to Read"
                
            case .completed:
                return "Completed"
                
            case .onHold:
                return "On Hold"
                
            case .dropped:
                return "Dropped"
            }
        }
    }
    
    public dynamic var id = -1
    public dynamic var progress = 0
    public dynamic var reconsuming = false
    public dynamic var reconsumeCount = 0
    public dynamic var notes = ""
    public dynamic var isPrivate = false
    public dynamic var rating = 0.0
    public dynamic var updatedAt: Date = Date()
    public dynamic var media: Media? = nil
    
    /**
     For `LibraryEntry` it is more convinient to add a getter and setter to the 'status' property so that we can modify it easily that way due to enums
     */
    dynamic var rawStatus = ""
    public var status: Status? {
        get {
            return Status(rawValue: rawStatus)
        }
        set {
            if let newStatus = newValue {
                rawStatus = newStatus.rawValue
            }
        }
    }
    
    //Other properties not present in the JSON
    public dynamic var needsSync = false
    public dynamic var userID = -1
    public var user: User? {
        return User.get(withId: userID)
    }
    
    override public static func primaryKey() -> String {
        return "id"
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["user", "status", "currentUser"]
    }
    
    override public func canBeStored() -> Bool {
        // We only want to store entries if:
        // - We don't have it in the database, or
        // - The updatedAt time for the current entry is more recent than the one in the database
        // The above constraints allow offline syncing, aswell as the case where entry needs to be synced but the server has a more recent one.
        
        guard let dbEntry = LibraryEntry.get(withId: self.id) else {
            return true
        }
        
        return self.updatedAt >= dbEntry.updatedAt
    }
    
    //MARK:- Cacheable
    public dynamic var localLastUpdate: Date?
    var currentUser: CurrentUser = CurrentUser()
    
}

extension LibraryEntry {
    
    func canClearFromCache() -> Bool {
        let id = currentUser.userID
        
        ///Don't delete entry if it's part of the current users library
        return id == nil ? true : userID != id
    }
    
    func willClearFromCache() {
        //Delete Media here
        if let media = media {
            Database().delete(media)
        }
    }
}

//MARK:- Gettable
extension LibraryEntry: GettableObject {
    public typealias T = LibraryEntry
    
    /// Get library entries that belongs to a given user, of a specific type and of a specific status
    ///
    /// - Parameters:
    ///   - id: The user id
    ///   - type: The type of the entries
    ///   - status: The status of the entry
    /// - Returns: A realm result of LibraryEntries
    public static func belongsTo(user id: Int, type: Media.MediaType? = nil, status: Status? = nil) -> Results<LibraryEntry> {
        let r = Database().realm
        
        var objects = r.objects(LibraryEntry.self).filter("userID = %d", id)
        
        //Filter media type
        if let type = type {
            objects = objects.filter("media.rawType = %@", type.rawValue)
        }
        
        //Filter status
        if let status = status {
            objects = objects.filter("rawStatus = %@", status.rawValue)
        }
        
        return objects
    }
}

//MARK:- Parsable
extension LibraryEntry: JSONParsable {
    
    public static var typeString: String { return "libraryEntries" }
    
    /// Construct an `LibraryEntry` object from JSON Data
    ///
    /// - Parameter json: The JSON Data
    /// - Returns: A LibraryEntry if JSON data was valid
    public static func parse(json: JSON) -> LibraryEntry? {
        guard json["type"].stringValue == LibraryEntry.typeString else {
            return nil
        }
        
        let attributes = json["attributes"]
        let entry = LibraryEntry()
        entry.id = json["id"].intValue
        entry.rawStatus = attributes["status"].stringValue
        entry.progress = attributes["progress"].intValue
        entry.reconsuming = attributes["reconsuming"].bool ?? false
        entry.reconsumeCount = attributes["reconsumeCount"].intValue
        entry.notes = attributes["notes"].stringValue
        entry.isPrivate = attributes["private"].bool ?? false
        entry.rating = attributes["rating"].doubleValue
        entry.updatedAt = Date.from(string: attributes["updatedAt"].stringValue) ?? Date()
        
        let relationships = json["relationships"]
        
        //Check if we already have a media, if not then make a new one
        if let mediaObject = Media.get(withId: entry.id) {
            //Use an unmanaged object so we don't get realm clashes
            entry.media = Media(value: mediaObject)
        } else {
            //Check if we have a media relationship
            for type in ["anime", "manga", "drama"] {
                let media = relationships[type]["data"]
                if media.exists() {
                    let type = media["type"].stringValue
                    let id = media["id"].intValue
                    entry.media = Media(value: [entry.id, id, type])
                }
            }
        }
        
        //Set which user this entry belongs to
        let user = relationships["user"]["data"]
        entry.userID = user["id"].intValue
        
        return entry
    }
}

//MARK:- JSON
extension LibraryEntry {
    /// Convert the entry to JSON data
    ///
    /// - Returns: The JSON data containing attributes only.
    public func toJSON() -> JSON {
        
        var attributes: [String: Any] = [:]
        attributes["progress"] = progress
        attributes["reconsuming"] = reconsuming
        attributes["reconsumeCount"] = reconsumeCount
        attributes["private"] = isPrivate
        attributes["notes"] = notes
        attributes["status"] = rawStatus
        
        let rating: Any = self.rating > 0 ? self.rating : NSNull()
        attributes["rating"] = rating
        
        var params: [String: Any] = [:]
        params["id"] = id
        params["type"] = LibraryEntry.typeString
        params["attributes"] = attributes
        
        return JSON(["data": params])
    }
}

//MARK:- Media
extension LibraryEntry {
    public var anime: Anime? {
        guard let media = media, media.type == .anime else {
            return nil
        }
        
        return Anime.get(withId: media.id)
    }
    
    public var manga: Manga? {
        guard let media = media, media.type == .manga else {
            return nil
        }
        
        return Manga.get(withId: media.id)
    }
}

//MARK:- Equatable
extension LibraryEntry {
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? LibraryEntry else {
            return false
        }
        
        return self.id == other.id &&
            self.progress == other.progress &&
            self.rawStatus == other.rawStatus &&
            self.reconsuming == other.reconsuming &&
            self.reconsumeCount == other.reconsumeCount &&
            self.notes == other.notes &&
            self.isPrivate == other.isPrivate &&
            self.rating == other.rating
    }
}

//MARK:- Updating
extension LibraryEntry {
    
    /// Get the maximum progress of the entry.
    ///
    /// - Returns: The maximum progress or nil if there is none
    public func maxProgress() -> Int? {
        //Max progress count
        var maxCount: Int? = nil
        
        if let media = self.media, let type = media.type {
            switch type {
            case .anime:
                maxCount = self.anime?.episodeCount
                
            case .manga:
                maxCount = self.manga?.chapterCount
            }
        }
        
        //If we get -1 then we don't have a max count for the media
        return maxCount == nil || maxCount! < 0 ? nil : maxCount
    }
}

