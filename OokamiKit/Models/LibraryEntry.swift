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

enum LibraryEntryStatus: String {
    case current
    case planned
    case completed
    case onHold = "on_hold"
    case dropped
    
    static let all:[LibraryEntryStatus] = [.current, .planned, .completed, .onHold, .dropped]
}

/*
 We don't need a compound key here are LibraryEntry - Media is a 1-to-1 relationship.
 If this does change in the future then a compound key will be needed
 */
class Media: Object {
    dynamic var entryId = -1
    dynamic var id = -1
    dynamic var type = ""
    
    override static func primaryKey() -> String {
        return "entryId"
    }
}

class LibraryEntry: Object {
    
    dynamic var id = -1
    dynamic var progress = 0
    dynamic var reconsuming = false
    dynamic var reconsumeCount = 0
    dynamic var notes = ""
    dynamic var isPrivate = false
    dynamic var rating = 0.0
    dynamic var updatedAt: Date = Date()
    dynamic var media: Media? = nil
    
    /**
     For `LibraryEntry` it is more convinient to add a getter and setter to the 'status' property so that we can modify it easily that way due to enums
     */
    dynamic var rawStatus = ""
    var status: LibraryEntryStatus? {
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
    dynamic var needsSync = false
    dynamic var userId = -1
    var user: User? {
        return User.get(withId: userId)
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["user"]
    }
}

extension LibraryEntry: GettableObject { typealias T = LibraryEntry }
extension LibraryEntry: JSONParsable {
    
    /// Construct an `LibraryEntry` object from JSON Data
    ///
    /// - Parameter json: The JSON Data
    /// - Returns: A LibraryEntry if JSON data was valid
    static func parse(json: JSON) -> LibraryEntry? {
        guard json["type"].stringValue == "libraryEntries" else {
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
        entry.userId = user["id"].intValue
        
        return entry
    }
}
