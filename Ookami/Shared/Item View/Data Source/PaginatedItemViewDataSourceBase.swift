//
//  PaginatedItemViewDataSourceBase.swift
//  Ookami
//
//  Created by Maka on 9/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

//A class which provides general functionality for paginated data sources
class PaginatedItemViewDataSourceBase: ItemViewControllerDataSource {
    
    //The delegate
    weak var delegate: ItemViewControllerDelegate? {
        didSet {
            delegate?.didReloadItems(dataSource: self)
            showIndicator()
        }
    }
    
    //The items to show
    var itemData: [ItemData] = [] {
        didSet {
            self.delegate?.didReloadItems(dataSource: self)
        }
    }
    
    //The backing data
    var data: [ItemDataTransformable] = []
    
    //The paginated service that we use
    var service: PaginatedService? = nil
    
    //Bool to check whether we have fetched the media
    var fetched: Bool = false
    
    init() {
        updateService()
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
    
    //Update the service
    func updateService() {
        fetched = false
        
        //Check if we have a operation in progress, if so then cancel it
        if service != nil {
            service?.cancel()
        }
        
        showIndicator(forced: true)
        
        service = paginatedService() {
            self.delegate?.hideActivityIndicator()
            self.fetched = true
        }
    }
    
    //Update the item data from an array of data transformables
    func updateItemData(from data: [ItemDataTransformable], original: Bool) {
        if original {
            self.data = data
        } else {
            self.data.append(contentsOf: data)
        }
        
        self.itemData = self.data.map { $0.toItemData() }
    }
    
    //The paginated service
    func paginatedService(_ completion: @escaping () -> Void) -> PaginatedService? {
        fatalError("paginatedService(completion:) needs to be implemented in a subclass")
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
        updateService()
    }
    
    func shouldShowEmptyDataSet() -> Bool {
        return count == 0
    }
    
    func dataSetImage() -> UIImage? {
        return nil
    }
    
    func dataSetTitle() -> NSAttributedString? {
        return nil
    }
    
    func dataSetDescription() -> NSAttributedString? {
        return nil
    }
    
}
