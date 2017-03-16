//
//  MediaDiscoverDataSource.swift
//  Ookami
//
//  Created by Maka on 8/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

/// A data source for media discovery
/// Must be subclassed
class MediaDiscoverDataSource: PaginatedItemViewDataSourceBase, DiscoverDataSource {
    
    //The parent to report to
    weak var parent: UIViewController?
    
    //The current search text
    var currentSearch: String = ""

    /// Update the discovery results.
    /// This will discard the previous service and fetch a whole new one.
    ///
    /// - Parameter search: The text to search for, or blank if you want everything
    func update(search: String = "") {
        
        //Set the current search
        currentSearch = search
        
        //Update the service
        updateService()
    }
    
    func didSearch(text: String) {
        if currentSearch != text {
            update(search: text)
        }
    }
    
    //MARK:- ItemDataSource
    
    override func dataSetImage() -> UIImage? {
        let size = CGSize(width: 44, height: 44)
        let color = UIColor.lightGray.lighter(amount: 0.1)
        return UIImage(named: "search")?
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
