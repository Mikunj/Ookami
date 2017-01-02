//
//  CollectionCellSpacing.swift
//  Ookami
//
//  Created by Maka on 2/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit

struct CollectionCellSpacing {
    //Number of items that fit, or 0 if spacing is invalid
    var itemCount = 0
    
    //Outer margin size (in points)
    var margin: CGFloat = 0.0
    
    //Inner gutter size (in points)
    var gutter: CGFloat = 0.0
    
    //Extra space that doesn't fit
    var extra: CGFloat = 0.0
    
    static let zero = CollectionCellSpacing()
    
}

extension CollectionCellSpacing : Equatable {
    static func == (lhs: CollectionCellSpacing, rhs: CollectionCellSpacing) -> Bool {
        return lhs.itemCount == rhs.itemCount &&
            lhs.margin == rhs.margin &&
            lhs.gutter == rhs.gutter &&
            lhs.extra == rhs.extra;
    }
}
