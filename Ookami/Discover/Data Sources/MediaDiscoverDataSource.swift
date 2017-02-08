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
class MediaDiscoverDataSource: DiscoverDataSource {
    
    //The parent to report to
    weak var parent: DiscoverViewController?
    
    //The delegate
    weak var delegate: ItemViewControllerDelegate? {
        didSet {
            delegate?.didReloadItems(dataSource: self)
            showIndicator()
        }
    }
    
    //The current search text
    var currentSearch: String = ""
    
    //The paginated service that we use
    var service: PaginatedService? = nil
    
    //Bool to check whether we have fetched the media
    var fetched: Bool = false
    
    init() {
        update()
    }
    
    //Show the activity indicator
    func showIndicator(forced: Bool = false) {
        if forced {
            delegate?.showActivityIndicator()
            return
        }
        
        //Check if we have the results and if we don't then show the indicator
        if count == 0,
            fetched == false {
            delegate?.showActivityIndicator()
        }
    }
    
    /// Update the discovery results.
    /// This will discard the previous service and fetch a whole new one.
    ///
    /// - Parameter search: The text to search for, or blank if you want everything
    func update(search: String = "") {
        
        fetched = false
        
        //Set the current search
        currentSearch = search
        
        //Check if we have a operation in progress, if so then cancel it
        if service != nil {
            service?.cancel()
        }
        
        showIndicator(forced: true)
        
        service = paginatedService(for: search, completion: {
            self.delegate?.hideActivityIndicator()
            self.fetched = true
        })
    }
    
    //The service for the given search text
    func paginatedService(for searchText: String, completion: @escaping () -> Void) -> PaginatedService {
        fatalError("paginatedService(for:completion:) needs to be implemented in a subclass")
    }
    
    //MARK:- ItemDataSource
    var count: Int {
        return 0
    }
    
    func items() -> [ItemData] {
        return []
    }
    
    func didSelectItem(at indexPath: IndexPath) {
    }
    
    func refresh() {
        update(search: currentSearch)
    }
    
    func shouldShowEmptyDataSet() -> Bool {
        return count == 0
    }
    
    func dataSetImage() -> UIImage? {
        return FontAwesomeIcon.searchIcon.image(ofSize: CGSize(width: 35, height: 35), color: UIColor.lightGray.lighter(amount: 0.1))
    }
    
    func dataSetTitle() -> NSAttributedString? {
        let title = "Could not find any results."
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                          NSForegroundColorAttributeName: UIColor.lightGray.lighter(amount: 0.1)]
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func dataSetDescription() -> NSAttributedString? {
        let description = "Type in a keyword to search."
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14),
                          NSForegroundColorAttributeName: UIColor.lightGray.lighter(amount: 0.1)]
        return NSAttributedString(string: description, attributes: attributes)
    }

}
