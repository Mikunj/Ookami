//
//  Media+Genre.swift
//  Ookami
//
//  Created by Maka on 20/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

//A model to link Media and Genre together
public class MediaGenre: Object {
    //The media this genre belongs to
    public internal(set) dynamic var mediaID = -1 {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    //The type of media this belongs to
    public internal(set) dynamic var mediaType = "" {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    //The genre id that this links to
    public internal(set) dynamic var genreID = -1 {
        didSet { compoundKey = self.compoundKeyValue() }
    }
    
    dynamic var compoundKey: String = "0-"
    func compoundKeyValue() -> String {
        return "\(mediaID)-\(mediaType)-\(genreID)"
    }
    
    override public static func primaryKey() -> String {
        return "compoundKey"
    }

    /// The genre object that the MediaGenre is linked to
    public var genre: Genre? {
        return Genre.get(withId: genreID)
    }
}
