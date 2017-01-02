//
//  CollectionCellSpacerOption.swift
//  Ookami
//
//  Created by Maka on 2/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit

struct CollectionCellSpacerOption {
    
    enum Errors: Error {
        case invalidItemSize
        case invalidMinimumGutter
        case invalidAvailableWidth
        case invalidGutterToMarginRatio
    }
    
    var itemSize: CGSize
    var minimumGutter: CGFloat
    var gutterToMarginRatio: CGFloat
    var availableWidth: CGFloat
    var distributeExtraToMargins = true
    
    init(itemSize: CGSize, minimumGutter: CGFloat, availableWidth: CGFloat, gutterToMarginRatio: CGFloat = 1.0, distributeExtraToMargins: Bool = true) throws {
        
        guard itemSize.width > 0.0, itemSize.height > 0.0 else {
            throw Errors.invalidItemSize
        }
        
        guard minimumGutter > 0.0 else {
            throw Errors.invalidMinimumGutter
        }
        
        guard availableWidth > 0.0 else {
            throw Errors.invalidAvailableWidth
        }
        
        guard gutterToMarginRatio > 0.0 else {
            throw Errors.invalidGutterToMarginRatio
        }
        
        
        self.itemSize = itemSize;
        self.minimumGutter = minimumGutter;
        self.availableWidth = availableWidth;
        self.gutterToMarginRatio = gutterToMarginRatio
        self.distributeExtraToMargins = distributeExtraToMargins
    }
}
