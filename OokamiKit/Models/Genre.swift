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

class Genre: Object {
    
    dynamic var id = -1
    dynamic var slug = ""
    dynamic var name = ""
    dynamic var genreDescription = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return []
    }
}

extension Genre: GettableObject { typealias T = Genre }
extension Genre {

    /// Construct an `Genre` object from JSON Data
    ///
    /// - Parameter json: The JSON Data
    /// - Returns: A genre if JSON data was valid
    class func parse(json: JSON) -> Genre? {
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
