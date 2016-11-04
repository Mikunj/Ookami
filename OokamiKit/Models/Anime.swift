//
//  Anime.swift
//  Ookami
//
//  Created by Maka on 4/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

//TODO: Hookup genres, castings, installments etc..

import Foundation
import RealmSwift
import SwiftyJSON

class AnimeTitle: Object {
    dynamic var id = ""
    dynamic var value = ""
}

class Anime: Object {
    
    dynamic var id = -1
    dynamic var slug = ""
    dynamic var synopsis = ""
    dynamic var averageRating: Float = 0.0
    dynamic var startDate: Date?
    dynamic var endDate: Date?
    dynamic var episodeCount = -1 //-1 means we don't know the episode count for this anime
    dynamic var episodeLength = -1
    dynamic var showType = ""
    dynamic var youtubeVideoId = ""
    dynamic var ageRating = ""
    dynamic var ageRatingGuide = ""
    dynamic var posterImage = ""
    dynamic var coverImage = ""
    
    let titles = List<AnimeTitle>()
    dynamic var canonicalTitle = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return []
    }
    
}

extension Anime {
    
    /// Get an anime with the given id.
    ///
    /// - Parameter id: The anime id
    ///   - realm: The realm to check. If left nil then it will use the default realm.
    /// - Returns: An anime object if it exists with given id
    class func get(withId id: Int, realm: Realm? = nil) -> Anime? {
        var r = realm
        if r == nil { r = try! Realm() }
        return r!.object(ofType: Anime.self, forPrimaryKey: id)
    }
    
    /// Construct an `Anime` object from JSON Data
    ///
    /// - Parameter json: The JSON Data
    /// - Returns: An anime if JSON data was valid
    class func parse(json: JSON) -> Anime? {
        guard json["type"].stringValue == "anime" else {
            return nil
        }
        
        let attributes = json["attributes"]
        let anime = Anime()
        anime.id = json["id"].intValue
        anime.slug = attributes["slug"].stringValue
        anime.synopsis = attributes["synopsis"].stringValue
        anime.canonicalTitle = attributes["canonicalTitle"].stringValue
        anime.averageRating = attributes["averageRating"].floatValue
        anime.startDate = Date.from(string: attributes["startDate"].stringValue)
        anime.endDate = Date.from(string: attributes["endDate"].stringValue)
        anime.episodeCount = attributes["episodeCount"].int ?? -1
        anime.episodeLength = attributes["episodeLength"].int ?? -1
        anime.showType = attributes["showType"].stringValue
        anime.youtubeVideoId = attributes["youtubeVideoId"].stringValue
        anime.ageRating = attributes["ageRating"].stringValue
        anime.ageRatingGuide = attributes["ageRatingGuide"].stringValue
        anime.posterImage = attributes["posterImage"]["original"].stringValue
        anime.coverImage = attributes["coverImage"]["original"].stringValue
        
        //Add titles
        let attributeTitles = attributes["titles"]
        for (key, value): (String, JSON) in attributeTitles {
            let title = AnimeTitle()
            title.id = key
            title.value = value.stringValue
            anime.titles.append(title)
        }
        
        return anime
    }
}