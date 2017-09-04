//
//  MediaRelationship.swift
//  Ookami
//
//  Created by Maka on 30/8/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

public class MediaRelationship: Object, Cacheable {
    
    public dynamic var id = -1
    public dynamic var role = ""
    public dynamic var sourceId = -1
    public dynamic var sourceType = ""
    public dynamic var destinationId = -1
    public dynamic var destinationType = ""
    
    override public static func primaryKey() -> String {
        return "id"
    }
    
    override public static func ignoredProperties() -> [String] {
        return []
    }
    
    /// MARK:- Cacheable
    public dynamic var localLastUpdate: Date?
}

extension MediaRelationship {
    
    /// The destination anime of the relationship
    public var anime: Anime? {
        guard destinationType == Media.MediaType.anime.rawValue else {
            return nil
        }
        
        return Anime.get(withId: destinationId)
    }
    
    /// The destination manga of the relationship
    public var manga: Manga? {
        guard destinationType == Media.MediaType.manga.rawValue else {
            return nil
        }
        
        return Manga.get(withId: destinationId)
    }
}

extension MediaRelationship: GettableObject {
    
    public typealias T = MediaRelationship
    
    /// Get all the `MediaRelationship` objects that belong to the given media source.
    ///
    /// - Parameters:
    ///   - id: The media id
    ///   - type: The media type
    /// - Returns: A realm result of MediaRelationships
    public static func belongsTo(sourceId id: Int, type: Media.MediaType) -> Results<MediaRelationship> {
        return MediaRelationship.all().filter("sourceId == %d AND sourceType ==[c] %@", id, type.rawValue)
    }
    
    /// Get all the `MediaRelationship` objects that belong to the given media destination.
    ///
    /// - Parameters:
    ///   - id: The media id
    ///   - type: The media type
    /// - Returns: A realm result of MediaRelationships
    public static func belongsTo(destinationId id: Int, type: Media.MediaType) -> Results<MediaRelationship> {
        return MediaRelationship.all().filter("destinationId == %d AND destinationType ==[c] %@", id, type.rawValue)
    }
}

extension MediaRelationship: JSONParsable {
    
    public static var typeString: String { return "mediaRelationships" }
    
    /// Construct an `MediaRelationship` object from JSON Data
    ///
    /// - Parameter json: The JSON Data
    /// - Returns: A media relationship if JSON data was valid
    public static func parse(json: JSON) -> MediaRelationship? {
        guard json["type"].stringValue == MediaRelationship.typeString else {
            return nil
        }
        
        let destination = json["relationships"]["destination"]["data"]
        let source = json["relationships"]["source"]["data"]
        
        //Check if we have destination and source data
        guard destination.exists() && source.exists() else {
                return nil
        }
        
        let attributes = json["attributes"]
        
        let relationship = MediaRelationship()
        relationship.id = json["id"].intValue
        relationship.role = attributes["role"].stringValue
        relationship.sourceId = source["id"].intValue
        relationship.sourceType = source["type"].stringValue
        relationship.destinationId = destination["id"].intValue
        relationship.destinationType = destination["type"].stringValue
        
        return relationship
    }
    
}
