//
//  Manga.swift
//  Ookami
//
//  Created by Maka on 30/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

//TODO: Maybe add abbreviated titles?
public class Manga: Object, Cacheable {
    
    public dynamic var id = -1
    public dynamic var slug = ""
    public dynamic var synopsis = ""
    public dynamic var averageRating = 0.0
    public dynamic var startDate: Date?
    public dynamic var endDate: Date?
    public dynamic var mangaType: String = ""
    public dynamic var chapterCount: Int = -1 //-1 means we don't know the count
    public dynamic var volumeCount: Int = -1
    public dynamic var posterImage = ""
    public dynamic var coverImage = ""
    
    public let titles = List<MediaTitle>()
    public dynamic var canonicalTitle = ""
    
    /**
     When parsing manga, if a `Genre` cannot be found then it is created with just the `id` set. This is to ensure that the relationship occurs, but we cannot determine the rest of the genre data from the manga JSON itself
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

extension Manga {
    func canClearFromCache() -> Bool {
        //Don't delete if manga is part of current user library
        let hasManga = UserHelper.currentUserHas(media: .manga, id: id)
        return !hasManga
    }
    
    func willClearFromCache() {
        //Delete manga titles
        Database().delete(titles)
    }
}

//MARK:- Gettable
extension Manga: GettableObject { public typealias T = Manga }

//MARK:- Parsable
extension Manga: JSONParsable {
    
    public static var typeString: String { return "manga" }
    
    /// Construct an `Manga` object from JSON Data
    ///
    /// - Parameter json: The JSON Data
    /// - Returns: A manga if JSON data was valid
    public static func parse(json: JSON) -> Manga? {
        guard json["type"].stringValue == Manga.typeString else {
            return nil
        }
        
        let attributes = json["attributes"]
        let manga = Manga()
        manga.id = json["id"].intValue
        manga.slug = attributes["slug"].stringValue
        manga.synopsis = attributes["synopsis"].stringValue
        manga.canonicalTitle = attributes["canonicalTitle"].stringValue
        manga.averageRating = attributes["averageRating"].doubleValue
        manga.startDate = Date.from(string: attributes["startDate"].stringValue)
        manga.endDate = Date.from(string: attributes["endDate"].stringValue)
        manga.chapterCount = attributes["chapterCount"].int ?? -1
        manga.volumeCount = attributes["volumeCount"].int ?? -1
        manga.mangaType = attributes["mangaType"].stringValue
        manga.posterImage = attributes["posterImage"]["original"].stringValue
        manga.coverImage = attributes["coverImage"]["original"].stringValue
        
        //Add titles
        let attributeTitles = attributes["titles"]
        for (key, value) in attributeTitles {
            let title = MediaTitle()
            title.mediaID = manga.id
            title.mediaType = Media.MediaType.manga.rawValue
            title.key = key
            title.value = value.stringValue
            manga.titles.append(title)
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
            
            manga.genres.append(genreObject!)
        }
        
        return manga
    }
}

