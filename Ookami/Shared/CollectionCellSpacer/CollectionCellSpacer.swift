//
//  CollectionCellSpacer.swift
//  Ookami
//
//  Created by Maka on 2/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit

//A Swift implementation of JBSpacer
//https://github.com/mikeswanson/JBSpacer
class CollectionCellSpacer {
    
    let option: CollectionCellSpacerOption
    let screenScale: CGFloat
    
    fileprivate var spacing: CollectionCellSpacing = CollectionCellSpacing.zero
    
    init(option: CollectionCellSpacerOption, screenScale: CGFloat = 0.0) {
        self.option = option
        self.screenScale = screenScale
        updateSpacing()
    }
    
    func applySpacing(to layout: UICollectionViewFlowLayout) {
        let gutter = snap(float: spacing.gutter, toScale: 1000.0)
        let margin = snap(float: spacing.margin, toScale: 1000.0)
        let extra = snap(float: spacing.margin + spacing.extra, toScale: 1000.0)
        
        layout.minimumLineSpacing = gutter
        layout.minimumInteritemSpacing = gutter
        layout.itemSize = option.itemSize
        layout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: extra)
        
    }
    
    func updateSpacing() {
        spacing = CollectionCellSpacing.zero
        
        let minMargin = option.minimumGutter * option.gutterToMarginRatio
        let maxContentWidth = option.availableWidth - (minMargin * 2.0)
        var itemCount: UInt = UInt(CGFloat(maxContentWidth) / option.itemSize.width)
        var neededContentWidth = CGFloat.greatestFiniteMagnitude
        
        if itemCount > 0 {
            
            while itemCount > 0, neededContentWidth > maxContentWidth {
                neededContentWidth = (CGFloat(itemCount) * option.itemSize.width) + (CGFloat(itemCount - 1) * option.minimumGutter)
                itemCount -= 1
            }
            
            if (neededContentWidth <= maxContentWidth) {
                spacing.itemCount = Int(itemCount + 1)
                
                let fItemCount = CGFloat(spacing.itemCount)
                let a = option.availableWidth - (fItemCount * option.itemSize.width)
                let b = fItemCount + (2.0 * option.gutterToMarginRatio) - 1.0
                let idealGutter = a / b
                
                let screenScale = self.screenScale == 0.0 ? UIScreen.main.scale : self.screenScale
                spacing.margin = snap(float: idealGutter * option.gutterToMarginRatio, toScale: screenScale)
                spacing.gutter = snap(float: idealGutter, toScale: screenScale)
                
                spacing.extra = option.availableWidth -
                    ((spacing.margin * 2.0) +
                        (fItemCount * option.itemSize.width) +
                        ((fItemCount - 1) * spacing.gutter))
                
                if option.distributeExtraToMargins, spacing.extra >= 2.0 / screenScale {
                    let extraToDistribute = snap(float: spacing.extra * 0.5, toScale: screenScale)
                    
                    spacing.margin += extraToDistribute
                    spacing.extra -= extraToDistribute * 2.0
                }
                
                if fabsf(Float(spacing.extra)) < 0.0001 {
                    spacing.extra = 0.0
                }
            }
        }
    }
    
    func snap(float: CGFloat, toScale scale: CGFloat) -> CGFloat {
        let value = Float(float * scale)
        return (CGFloat(floorf(value)) / scale)
    }

}

//MARK:- Static
extension CollectionCellSpacer {
    /// Finds the best spacing from a given array of options
    ///
    /// - Parameter options: An array of options
    /// - Returns: The best option from the array
    static func bestSpacing(with options: [CollectionCellSpacerOption]) -> CollectionCellSpacerOption? {
        
        var bestOption: CollectionCellSpacerOption? = nil
        var bestSpacing: CollectionCellSpacing = CollectionCellSpacing.zero
        bestSpacing.gutter = CGFloat.greatestFiniteMagnitude
        bestSpacing.extra = CGFloat.greatestFiniteMagnitude
        
        for option in options {
            let spacer = CollectionCellSpacer(option: option)
            let spacing = spacer.spacing
            if spacing.itemCount > 0 && (spacing.gutter < bestSpacing.gutter ||
                (spacing.gutter == bestSpacing.gutter && spacing.extra < bestSpacing.extra)) {
                bestOption = option
                bestSpacing = spacing
            }
            
            if bestSpacing.gutter == option.minimumGutter && bestSpacing.extra == 0.0 {
                break
            }
        }
        
        return bestOption
    }
}
