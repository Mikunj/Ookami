//
//  ItemData.swift
//  Ookami
//
//  Created by Maka on 1/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

//Protocol to adhere to for transforming to ItemData
protocol ItemDataTransformable {
    func toItemData() -> ItemData
}

//An item data struct
struct ItemData: Equatable {
    var name: String?
    var details: String?
    var moreDetails: String?
    var posterImage: String?
    var coverImage: String?
    
    static func ==(lhs: ItemData, rhs: ItemData) -> Bool {
        return lhs.name == rhs.name &&
            lhs.details == rhs.details &&
            lhs.moreDetails == rhs.moreDetails &&
            lhs.posterImage == rhs.posterImage &&
            lhs.coverImage == rhs.coverImage
    }
}
