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
class MediaYearTrendingDataSource: YearTrendingDataSource {
    
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
    
    //The current year text
    var currentYear: Int = -1
    
    //The paginated service that we use
    var service: PaginatedService? = nil
    
    //Bool to check whether we have fetched the media
    var fetched: Bool = false
    
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
    
    /// Update the trending results.
    /// This will discard the previous service and fetch a whole new one.
    ///
    /// - Parameter year: The year
    func update(year: Int) {
        guard year > 0 else { return }
        
        fetched = false
        
        //Set the current year
        currentYear = year
        
        //Check if we have a operation in progress, if so then cancel it
        if service != nil {
            service?.cancel()
        }
        
        showIndicator(forced: true)
        
        service = paginatedService(for: year, completion: {
            self.delegate?.hideActivityIndicator()
            self.fetched = true
        })
    }
    
    //The service for the given year
    func paginatedService(for year: Int, completion: @escaping () -> Void) -> PaginatedService {
        fatalError("paginatedService(for:completion:) needs to be implemented in a subclass")
    }
    
    func didSet(year: Int) {
        if currentYear != year {
            update(year: year)
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
        update(year: currentYear)
    }
    
    func shouldShowEmptyDataSet() -> Bool {
        return count == 0
    }
    
    func dataSetImage() -> UIImage? {
        let size = CGSize(width: 44, height: 44)
        let color = UIColor.lightGray.lighter(amount: 0.1)
        return UIImage(named: "book")?
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

