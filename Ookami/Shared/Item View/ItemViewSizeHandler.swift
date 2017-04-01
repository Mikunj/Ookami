//
//  ItemViewSizeHandler.swift
//  Ookami
//
//  Created by Maka on 1/4/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit

struct ItemViewSizeHandler {
    
    private init() {}
    
    //The sizes of the posters
    static private func posterSizes() -> [CGSize] {
        //The ratio of the poster (width / height)
        let posterRatio: Double = 100 / 150
        
        //If we have an ipad then make the posters bigger
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let minWidth = isIpad ? 150 : 100
        let maxWidth = isIpad ? 190 : 140
        
        //We need to work out heights from the given widths
        let widths = stride(from: minWidth, to: maxWidth, by: 5)
        let sizes = widths.map { width -> CGSize in
            let dWidth = Double(width)
            let height = floor((1 / posterRatio) * dWidth)
            return CGSize(width: dWidth, height: height)
        }

        return sizes
    }
    
    //Get the item sizes for a given cell type in ItemViewController
    static func itemSizes(for type: ItemViewController.CellType) -> [CGSize] {
        let posterSizes = self.posterSizes()
        
        switch type {
        case .detailGrid:
            
            //We need to add 25 to accomodate for the detail label at the bottom
            return posterSizes.map { size -> CGSize in
                return CGSize(width: size.width, height: size.height + 25)
            }
        case .simpleGrid:
            //Since the poster fills the whole view, we just pass in the computed sizes
            return posterSizes
        }

    }
}
