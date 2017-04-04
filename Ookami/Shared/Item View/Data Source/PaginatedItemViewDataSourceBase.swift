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
            delegate?.didReloadItems()
            showIndicator()
        }
    }
    
    //The items to show
    var itemData: [ItemData] = [] {
        didSet {
            self.delegate?.didReloadItems()
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
            let filtered = filterDuplicates(from: data)
            self.data.append(contentsOf: filtered)
        }
        
        self.itemData = self.data.map { $0.toItemData() }
        
        //If we fetch new data then scroll to the top
        if original { self.delegate?.scrollToTop(animated: true) }
    }
    
    //Filter any duplicates
    private func filterDuplicates(from data: [ItemDataTransformable]) -> [ItemDataTransformable] {
        
        //Since ItemDataTransformable is a protocol, we can't use `Array.contains()` to check if our data has any of the values listed
        //To overcome this we convert the data to `ItemData` and use that for checking against our current itemData. This works because `ItemData` is `Equatable`.
        let itemData = data.map { $0.toItemData() }
        var filtered: [ItemDataTransformable] = []
        
        //Loop through the array using index
        for i in 0..<itemData.count {
            //Check if we have the item data in our current itemData
            if self.itemData.contains(itemData[i]) {
                continue
            }
            
            //Since we don't then we can append it to the filtered array
            filtered.append(data[i])
        }
        
        return filtered
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
