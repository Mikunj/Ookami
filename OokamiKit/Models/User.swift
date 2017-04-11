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
    public internal(set) dynamic var userID = -1 {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    //the past name
    public internal(set) dynamic var name = "" {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    dynamic var compoundKey: String = "0-"
    func compoundKeyValue() -> String {
        return "\(userID)-\(name)"
    }
    
    override public static func primaryKey() -> String {
        return "compoundKey"
    }

}

public class User: Object, Cacheable {
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
    
    //Rating
    public dynamic var ratingSystemRaw = ""
    public var ratingSystem: RatingSystem? {
        return RatingSystem(rawValue: ratingSystemRaw)
    }
    
    public dynamic var name = ""
    public let pastNames = List<UserPastName>()
    
    override public static func primaryKey() -> String {
        return "id"
    }
    
    override public static func ignoredProperties() -> [String] {
        return []
    }
    
    /// MARK:- Cacheable
    public dynamic var localLastUpdate: Date?
    var currentUser: CurrentUser = CurrentUser()
    
}

extension User {
    func canClearFromCache() -> Bool {
        //Don't delete if this is the current user
        return id != currentUser.userID
    }
    
    func willClearFromCache() {
        //Delete the past names and LastFetched
        Database().delete(pastNames)
        
        if let fetched = LastFetched.get(withId: id) {
            Database().delete(fetched)
        }
    }
}

//MARK:- Gettable
extension User: GettableObject { public typealias T = User }

//MARK:- Parsable
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
        user.birthday = attributes["birthday"].stringValue
        user.gender = attributes["gender"].stringValue
        user.avatarImage = attributes["avatar"]["original"].stringValue
        user.coverImage = attributes["coverImage"]["original"].stringValue
        user.ratingSystemRaw = attributes["ratingSystem"].stringValue
        
        //Parse past names
        let pastNamesJSON = attributes["pastNames"]        
        for name in pastNamesJSON.arrayValue {
            let pastName = UserPastName()
            pastName.userID = user.id
            pastName.name = name.stringValue
            user.pastNames.append(pastName)
        }
        
        return user
    }
    
}

//MARK:- Enums
extension User {
    public enum RatingSystem: String {
        case advanced //1 - 10
        case simple
        case regular //0.5 - 5
        
        public static let all: [RatingSystem] = [.simple, .regular, .advanced]
    }
}

