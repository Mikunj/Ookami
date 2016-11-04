//
//  User.swift
//  Ookami
//
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class User: Object {
    dynamic var id = -1
    dynamic var about = ""
    dynamic var bio = ""
    dynamic var location = ""
    dynamic var website = ""
    dynamic var waifuOrHusbando = ""
    dynamic var followersCount = 0
    dynamic var followingCount = 0
    dynamic var createdAt: Date = Date()
    dynamic var updatedAt: Date = Date()
    dynamic var lifeSpentOnAnime = 0
    dynamic var birthday = ""
    dynamic var gender = ""
    dynamic var avatarImage = ""
    dynamic var coverImage = ""
    
    /**
     Since we can't store an array of strings easily in realm, we just add a relationship with a RealmString object and use that for getting/setting an array of strings.
     */
    dynamic var name = ""
    let _backingPastNames = List<RealmString>()
    var pastNames: [String] {
        get {
            return _backingPastNames.map { $0.value }
        }
        set {
            _backingPastNames.removeAll()
            _backingPastNames.append(objectsIn: newValue.map { RealmString(value: [$0]) })
        }
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["pastNames"]
    }
}

extension User {
    
    /// Get a user with a given id
    ///
    /// - Parameters:
    ///   - id: The user id
    /// - Returns: A user if they exist with the given id in the realm
    class func get(withId id: Int) -> User? {
        let r = RealmProvider.realm()
        return r.object(ofType: User.self, forPrimaryKey: id)
    }
    
    /// Construct a `User` object from JSON Data
    ///
    /// - Parameter json: The JSON data
    /// - Returns: A User if the JSON data was valid
    class func parse(json: JSON) -> User? {
        guard json["type"].stringValue == "users" else {
            return nil
        }
        
        let attributes = json["attributes"]
        let user = User()
        user.id = json["id"].intValue
        user.name = attributes["name"].stringValue
        user.about = attributes["about"].stringValue
        user.bio = attributes["bio"].stringValue
        user.location = attributes["location"].stringValue
        user.website = attributes["website"].stringValue
        user.waifuOrHusbando = attributes["waifuOrHusbando"].stringValue
        user.followersCount = attributes["followersCount"].intValue
        user.followingCount = attributes["followingCount"].intValue
        user.lifeSpentOnAnime = attributes["lifeSpentOnAnime"].intValue
        user.createdAt = Date.from(string: attributes["createdAt"].stringValue) ?? Date()
        user.updatedAt = Date.from(string: attributes["updatedAt"].stringValue) ?? Date()
        
        //TODO: This may actually return a date, at the current time of writing this it returns null
        user.birthday = attributes["birthday"].stringValue
        user.gender = attributes["gender"].stringValue
        user.avatarImage = attributes["avatar"]["original"].stringValue
        user.coverImage = attributes["coverImage"]["original"].stringValue
        
        //Parse past names
        let pastNamesJSON = attributes["pastNames"]
        var names: [String] = []
        
        for (_, subJSON): (String, JSON) in pastNamesJSON {
            names.append(subJSON.stringValue)
        }
        user.pastNames = names;
        
        
        return user
    }
    
}

