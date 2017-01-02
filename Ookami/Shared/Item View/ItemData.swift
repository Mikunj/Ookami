//
//  ItemData.swift
//  Ookami
//
//  Created by Maka on 1/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

//TODO: Add more properties

struct ItemData: Equatable {
    var name: String?
    var countString: String?
    var posterImage: String?
    var coverImage: String?
    
    static func ==(lhs: ItemData, rhs: ItemData) -> Bool {
        return lhs.name == rhs.name &&
            lhs.countString == rhs.countString &&
            lhs.posterImage == rhs.posterImage &&
            lhs.coverImage == rhs.coverImage
    }
}
