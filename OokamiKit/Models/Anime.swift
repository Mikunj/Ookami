//
//  Anime.swift
//  Ookami
//
//  Created by Maka on 4/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

//TODO: Hookup castings, installments etc..

import Foundation
import RealmSwift
import SwiftyJSON

/**
 The reason we can safely assign compoundKey via didSet (note realm will not call didSet or willSet after object has been written to database) is because the animeId and the key of the AnimeTitle will not change after it has first been added.
 
 WARNING: If you do decide to change the animeId or key then the compoundKey will be invalid!
 */
class AnimeTitle: Object {
    //The anime this title belongs to
    dynamic var animeId = -1 {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    //the language key, E.g en or en_jp
    dynamic var key = "" {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    //The title for the given key
    dynamic var value = ""
        
    dynamic var compoundKey: String = "0-"
    func compoundKeyValue() -> String {
        return "\(animeId)-\(key)"
    }
    
    override static func primaryKey() -> String {
        return "compoundKey"
    }
}

class Anime: Object {
    
    dynamic var id = -1
    dynamic var slug = ""
    dynamic var synopsis = ""
    dynamic var averageRating = 0.0
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
    
    /**
     When parsing anime, if a `Genre` cannot be found then it is created with just the `id` set. This is to ensure that the relationship occurs, but we cannot determine the rest of the genre data from the anime JSON itself
     */
    let genres = List<Genre>()
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return []
    }
    
}

extension Anime: GettableObject { typealias T = Anime }
extension Anime: JSONParsable {
    
    /// Construct an `Anime` object from JSON Data
    ///
    /// - Parameter json: The JSON Data
    /// - Returns: An anime if JSON data was valid
    static func parse(json: JSON) -> Anime? {
        guard json["type"].stringValue == "anime" else {
            return nil
        }
        
        let attributes = json["attributes"]
        let anime = Anime()
        anime.id = json["id"].intValue
        anime.slug = attributes["slug"].stringValue
        anime.synopsis = attributes["synopsis"].stringValue
        anime.canonicalTitle = attributes["canonicalTitle"].stringValue
        anime.averageRating = attributes["averageRating"].doubleValue
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
            title.animeId = anime.id
            title.key = key
            title.value = value.stringValue
            anime.titles.append(title)
        }
        
        //Add genres
        //We first check if the genre with given id exists. If not then we make one with just the id set.
        let genres = json["relationships"]["genres"]["data"]
        for (_, genre): (String, JSON) in genres {
            let id = genre["id"].intValue
            var genreObject = Genre.get(withId: id)
            if genreObject == nil {
                genreObject = Genre()
                genreObject!.id = id
            }
            
            anime.genres.append(genreObject!)
        }
        
        return anime
    }
}
