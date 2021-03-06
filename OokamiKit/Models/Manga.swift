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
    public dynamic var ageRating: String = ""
    public dynamic var ageRatingGuide: String = ""
    public dynamic var serialization: String = ""
    public dynamic var nsfw = false
    public dynamic var posterImage = ""
    public dynamic var coverImage = ""
    
    public dynamic var popularityRank: Int = -1
    public dynamic var ratingRank: Int = -1
    
    public dynamic var chapterCount: Int = -1 //-1 means we don't know the count
    public dynamic var volumeCount: Int = -1
    
    ///Get the string representation of the chapter count
    ///Format: [chapter count] chapter(s)
    public var chapterCountString: String {
        let chapterText = chapterCount > 0 ? String(chapterCount) : "?"
        let chapterSuffix = chapterCount == 1 ? "chapter" : "chapters"
        return "\(chapterText) \(chapterSuffix)"
    }
    
    ///Get the string representation of the volume count
    ///Format: [volume count] volume(s)
    public var volumeCountString: String {
        let volumeText = volumeCount > 0 ? String(volumeCount) : "?"
        let volumeSuffix = volumeCount == 1 ? "volume" : "volumes"
        return "\(volumeText) \(volumeSuffix)"
    }
    
    public let titles = List<MediaTitle>()
    public dynamic var canonicalTitle = ""
    
    //The manga type we use to represent with an enum
    public dynamic var subtypeRaw: String = ""
    public var subtype: SubType? {
        return SubType(rawValue: subtypeRaw)
    }
    
    //We use MediaGenre object for linking the manga and genre to avoid direct relationships
    public let mediaGenres = List<MediaGenre>()
    public var genres: [Genre] {
        return mediaGenres.flatMap { $0.genre }
    }
    
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
        
        //Delete media genres
        Database().delete(mediaGenres)
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
        manga.subtypeRaw = attributes["subtype"].stringValue
        manga.ageRating = attributes["ageRating"].stringValue
        manga.ageRatingGuide = attributes["ageRatingGuide"].stringValue
        manga.serialization = attributes["serialization"].stringValue
        manga.popularityRank = attributes["popularityRank"].int ?? -1
        manga.ratingRank = attributes["ratingRank"].int ?? -1
        manga.nsfw = attributes["nsfw"].boolValue
        
        //Poster & Cover
        let posterSize = UIDevice.current.userInterfaceIdiom == .pad ? "medium" : "small"
        manga.posterImage = attributes["posterImage"][posterSize].stringValue
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
            let mediaGenre = MediaGenre()
            mediaGenre.mediaID = manga.id
            mediaGenre.mediaType = Media.MediaType.manga.rawValue
            mediaGenre.genreID = id
            manga.mediaGenres.append(mediaGenre)
        }
        
        return manga
    }
}

extension Manga {
    /// Check whether a manga is finished
    ///
    /// - Returns: True if manga is finished, false if not
    public func isFinished() -> Bool {
        let current = Date()
        let endDate = self.endDate
        
        //Manga is finished if we have an end date and it is before the current date
        return (endDate != nil && endDate! < current)
    }
}

extension Manga {
    public enum SubType: String {
        case manga
        case novel
        case manhua
        case oneshot
        case doujin
        
        public static let all: [SubType] = [.manga, .novel, .manhua, .doujin, .oneshot]
    }
}

