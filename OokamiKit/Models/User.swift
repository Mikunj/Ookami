//
//  User.swift
//  Ookami
//
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

public class UserPastName: Object {
    //The user this name belongs to
    public internal(set) dynamic var userId = -1 {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    //the past name
    public internal(set) dynamic var name = "" {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    dynamic var compoundKey: String = "0-"
    func compoundKeyValue() -> String {
        return "\(userId)-\(name)"
    }
    
    override public static func primaryKey() -> String {
        return "compoundKey"
    }

}

public class User: Object {
    public dynamic var id = -1
    public dynamic var about = ""
    public dynamic var bio = ""
    public dynamic var location = ""
    public dynamic var website = ""
    public dynamic var waifuOrHusbando = ""
    public dynamic var followersCount = 0
    public dynamic var followingCount = 0
    public dynamic var createdAt: Date = Date()
    public dynamic var updatedAt: Date = Date()
    public dynamic var lifeSpentOnAnime = 0
    public dynamic var birthday = ""
    public dynamic var gender = ""
    public dynamic var avatarImage = ""
    public dynamic var coverImage = ""
    
    public dynamic var name = ""
    public let pastNames = List<UserPastName>()
    
    override public static func primaryKey() -> String {
        return "id"
    }
    
    override public static func ignoredProperties() -> [String] {
        return []
    }
}

extension User: GettableObject { public typealias T = User }
extension User: JSONParsable {
    
    public static var typeString: String { return "users" }
    
    /// Construct a `User` object from JSON Data
    ///
    /// - Parameter json: The JSON data
    /// - Returns: A User if the JSON data was valid
    public static func parse(json: JSON) -> User? {
        guard json["type"].stringValue == User.typeString else {
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

