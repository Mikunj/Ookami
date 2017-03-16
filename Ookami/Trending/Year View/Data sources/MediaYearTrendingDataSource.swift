//
//  MediaYearTrendingDataSource.swift
//  Ookami
//
//  Created by Maka on 6/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

/// A data source for media year trends
/// Must be subclassed
class MediaYearTrendingDataSource: PaginatedItemViewDataSourceBase, YearTrendingDataSource {
    
    //The parent
    weak var parent: UIViewController?
    
    //The current year text
    var currentYear: Int = -1
    
    /// Update the trending results.
    /// This will discard the previous service and fetch a whole new one.
    ///
    /// - Parameter year: The year
    func update(year: Int) {
        guard year > 0 else { return }
        
        //Set the current year
        currentYear = year
        
        updateService()
    }
    
    func didSet(year: Int) {
        if currentYear != year {
            update(year: year)
        }
    }
    
    override func dataSetImage() -> UIImage? {
        let size = CGSize(width: 46, height: 44)
        let color = UIColor.lightGray.lighter(amount: 0.1)
        return UIImage(named: "Trending_tab_bar")?
            .resize(size)
            .color(color)
    }
    
    override func dataSetTitle() -> NSAttributedString? {
        let title = "Could not find any results."
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                          NSForegroundColorAttributeName: UIColor.lightGray.lighter(amount: 0.1)]
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    
}

