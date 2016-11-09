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

public enum LibraryEntryStatus: String {
    case current
    case planned
    case completed
    case onHold = "on_hold"
    case dropped
    
    public static let all: [LibraryEntryStatus] = [.current, .planned, .completed, .onHold, .dropped]
}


/*
 We don't need a compound key here are LibraryEntry - Media is a 1-to-1 relationship.
 If this does change in the future then a compound key will be needed
 We also don't need to restrict it to internal(set) because there is no compound key
 */
public class Media: Object {
    
    public enum MediaType: String {
        case anime
        case manga
    }
    
    public dynamic var entryId = -1
    public dynamic var id = -1
    public dynamic var rawType = ""
    public var type: MediaType? {
        return MediaType(rawValue: rawType)
    }
    
    override public static func primaryKey() -> String {
        return "entryId"
    }
    
    override public static func ignoredProperties() -> [String] {
        return ["type"]
    }
    
}

public class LibraryEntry: Object {
    
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
    public var status: LibraryEntryStatus? {
        get {
            return LibraryEntryStatus(rawValue: rawStatus)
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
        return ["user", "status"]
    }
}

extension LibraryEntry: GettableObject { public typealias T = LibraryEntry }
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
        
        //Add which media this entry belongs to
        let media = relationships["media"]["data"]
        if media.exists() {
            let type = media["type"].stringValue
            let id = media["id"].intValue
            entry.media = Media(value: [entry.id, id, type])
        }
        
        //Set which user this entry belongs to
        let user = relationships["user"]["data"]
        entry.userID = user["id"].intValue
        
        return entry
    }
}
