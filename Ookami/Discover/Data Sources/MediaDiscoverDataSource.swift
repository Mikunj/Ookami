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
    weak var parent: UIViewController?
    
    //The delegate
    weak var delegate: ItemViewControllerDelegate? {
        didSet {
            delegate?.didReloadItems(dataSource: self)
            showIndicator()
        }
    }
    
    //The items to show
    var itemData: [ItemData] = []
    
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
        if count == 0 && !fetched {
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
    
    func didSearch(text: String) {
        if currentSearch != text {
            update(search: text)
        }
    }
    
    func loadMore() {
        self.delegate?.showActivityIndicator()
        service?.next()
    }
    
    //MARK:- ItemDataSource
    var count: Int {
        return itemData.count
    }
    
    func items() -> [ItemData] {
        return itemData
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
        let size = CGSize(width: 44, height: 44)
        let color = UIColor.lightGray.lighter(amount: 0.1)
        return UIImage(named: "search")?
            .resize(size)
            .color(color)
    }
    
    func dataSetTitle() -> NSAttributedString? {
        let title = "Could not find any results."
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                          NSForegroundColorAttributeName: UIColor.lightGray.lighter(amount: 0.1)]
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func dataSetDescription() -> NSAttributedString? {
        return nil
    }
    
}
