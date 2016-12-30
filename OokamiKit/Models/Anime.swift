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
 
 WARNING: If you do decide to change the animeId or key in OokamiKit then the compoundKey will be invalid!
 The key and value can only be modified internally (in OokamiKit) thus preventing the problem where apps using this framework modify the values accidentally
 */
public class AnimeTitle: Object {
    //The anime this title belongs to
    public internal(set) dynamic var animeId = -1 {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    //the language key, E.g en or en_jp
    public internal(set) dynamic var key = "" {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    //The title for the given key
    public internal(set) dynamic var value = ""
        
    dynamic var compoundKey: String = "0-"
    func compoundKeyValue() -> String {
        return "\(animeId)-\(key)"
    }
    
    override public static func primaryKey() -> String {
        return "compoundKey"
    }
}

public class Anime: Object, Cacheable {
    
    public dynamic var id = -1
    public dynamic var slug = ""
    public dynamic var synopsis = ""
    public dynamic var averageRating = 0.0
    public dynamic var startDate: Date?
    public dynamic var endDate: Date?
    public dynamic var episodeCount = -1 //-1 means we don't know the episode count for this anime
    public dynamic var episodeLength = -1
    public dynamic var showType = ""
    public dynamic var youtubeVideoId = ""
    public dynamic var ageRating = ""
    public dynamic var ageRatingGuide = ""
    public dynamic var posterImage = ""
    public dynamic var coverImage = ""
    
    public let titles = List<AnimeTitle>()
    public dynamic var canonicalTitle = ""
    
    /**
     When parsing anime, if a `Genre` cannot be found then it is created with just the `id` set. This is to ensure that the relationship occurs, but we cannot determine the rest of the genre data from the anime JSON itself
     */
    public let genres = List<Genre>()
    
    override public static func primaryKey() -> String {
        return "id"
    }
    
    override public static func ignoredProperties() -> [String] {
        return []
    }
    
    /// MARK:- Cacheable
    public dynamic var localLastUpdate: Date?
    
}

extension Anime {
    func canClearFromCache() -> Bool {
        //Don't delete if anime is part of current user library
        let hasAnime = UserHelper.currentUserHas(media: .anime, id: id)
        return !hasAnime
    }
    
    func willClearFromCache() {
        //Delete anime titles
        Database().delete(titles)
    }
}

//MARK:- Gettable
extension Anime: GettableObject { public typealias T = Anime }

//MARK:- Parsable
extension Anime: JSONParsable {
    
    public static var typeString: String { return "anime" }
    
    /// Construct an `Anime` object from JSON Data
    ///
    /// - Parameter json: The JSON Data
    /// - Returns: An anime if JSON data was valid
    public static func parse(json: JSON) -> Anime? {
        guard json["type"].stringValue == Anime.typeString else {
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
        for (key, value) in attributeTitles {
            let title = AnimeTitle()
            title.animeId = anime.id
            title.key = key
            title.value = value.stringValue
            anime.titles.append(title)
        }
        
        //Add genres
        //We first check if the genre with given id exists. If not then we make one with just the id set.
        let genres = json["relationships"]["genres"]["data"]
        for genre in genres.arrayValue {
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
