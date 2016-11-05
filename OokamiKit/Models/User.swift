//
//  User.swift
//  Ookami
//
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class UserPastName: Object {
    //The user this name belongs to
    dynamic var userId = -1 {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    //the past name
    dynamic var name = "" {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    dynamic var compoundKey: String = "0-"
    func compoundKeyValue() -> String {
        return "\(userId)-\(name)"
    }
    
    override static func primaryKey() -> String {
        return "compoundKey"
    }

}

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
    
    dynamic var name = ""
    let pastNames = List<UserPastName>()
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return []
    }
}

extension User: GettableObject { typealias T = User }
extension User: JSONParsable {
    
    /// Construct a `User` object from JSON Data
    ///
    /// - Parameter json: The JSON data
    /// - Returns: A User if the JSON data was valid
    static func parse(json: JSON) -> User? {
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
        for (_, name): (String, JSON) in pastNamesJSON {
            let pastName = UserPastName()
            pastName.userId = user.id
            pastName.name = name.stringValue
            user.pastNames.append(pastName)
        }
        
        return user
    }
    
}

