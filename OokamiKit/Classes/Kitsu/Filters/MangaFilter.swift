//
//  MangaFilter.swift
//  Ookami
//
//  Created by Maka on 7/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

//A class for representing Manga filters
public class MangaFilter: MediaFilter {
    
    //The subtypes to filter
    public var subtypes: [Manga.SubType] = []
    
    public override func construct() -> [String : Any] {
        var dict = super.construct()
        
        //Subtype
        if subtypes.count > 0 {
            dict["subtype"] = subtypes.map { $0.rawValue }
        }
        
        return dict
    }
}
