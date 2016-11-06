//
//  Genre.swift
//  Ookami
//
//  Created by Maka on 5/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

public class Genre: Object {
    
    public dynamic var id = -1
    public dynamic var slug = ""
    public dynamic var name = ""
    public dynamic var genreDescription = ""
    
    override public static func primaryKey() -> String {
        return "id"
    }
    
    override public static func ignoredProperties() -> [String] {
        return []
    }
}

extension Genre: GettableObject { public typealias T = Genre }
extension Genre: JSONParsable {

    /// Construct an `Genre` object from JSON Data
    ///
    /// - Parameter json: The JSON Data
    /// - Returns: A genre if JSON data was valid
    public static func parse(json: JSON) -> Genre? {
        guard json["type"].stringValue == "genres" else {
            return nil
        }
        
        let attributes = json["attributes"]
        let genre = Genre()
        genre.id = json["id"].intValue
        genre.slug = attributes["slug"].stringValue
        genre.name = attributes["name"].stringValue
        genre.genreDescription = attributes["description"].stringValue
        
        return genre
    }
    
}
