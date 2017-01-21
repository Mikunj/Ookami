//
//  FullLibraryDataSource.swift
//  Ookami
//
//  Created by Maka on 2/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import RealmSwift

//A datasource which displays an entire library of a certain type and status
final class FullLibraryDataSource: LibraryDataSource {
    weak var delegate: ItemViewControllerDelegate? {
        didSet {
            delegate?.didReloadItems(dataSource: self)
            showIndicator()
        }
    }
    
    //The parent to report to
    weak var parent: LibraryDataSourceParent?
    
    //The user id
    let userID: Int
    
    //The type of library
    let type: Media.MediaType
    
    //The status of the library
    let status: LibraryEntry.Status
    
    //Realm tokem
    var token: NotificationToken?
    
    //Realm results
    var results: Results<LibraryEntry>?
    
    //Max amount of time we are allowed to retry
    let maxRetryCount = 3
    
    //Current retry count
    var retryCount = 0
    
    //Bool to indicate whether we have fetched entries or not
    var fetchedEntries = false
    
    /// Create a library data source that fetches a full library for the given `user` and `status`
    ///
    /// - Parameters:
    ///   - userID: The user id
    ///   - type: The type of library to fetch
    ///   - status: The status of the library to fetch
    init(userID: Int, type: Media.MediaType, status: LibraryEntry.Status) {
        self.userID = userID
        self.type = type
        self.status = status
        
        updateResults(with: .updatedAt(ascending: false))
        fetchLibrary()
    }
    
    deinit {
        token?.stop()
    }
    
    func refresh() {
        fetchedEntries = false
        fetchLibrary(forced: true)
    }
    
    func showIndicator(forced: Bool = false) {
        if forced {
            delegate?.showActivityIndicator()
            return
        }
        
        //Check if we have the results and if we don't then show the indicator
        if let results = results,
            results.count == 0,
            fetchedEntries == false {
            delegate?.showActivityIndicator()
        }
    }
    
    /// Fetch the library info
    func fetchLibrary(forced: Bool = false) {
        
        if forced {
            fetchedEntries = false
            retryCount = 0
        }
        
        var lastFetched: Date = Date(timeIntervalSince1970: 0)
        
        //Get the fetch time if user has it, only if we're not force refreshing library
        if !forced, let fetched = LastFetched.get(withId: userID) {
            switch type {
            case .anime:
                lastFetched = fetched.anime
            case .manga:
                lastFetched = fetched.manga
            }
        }
        
        if retryCount <= self.maxRetryCount {
            
            showIndicator(forced: forced)
            
            LibraryService().get(userID: userID, type: type, status: status, since: lastFetched) { error in
                
                //If we get an error and we can still retry then do it
                if let _ = error, self.retryCount + 1 <= self.maxRetryCount {
                    self.retryCount += 1
                    self.fetchLibrary()
                    return
                }
                
                //We successfully fetched entries
                self.fetchedEntries = true
                
                //Tell delegate to reload the items
                self.delegate?.didReloadItems(dataSource: self)
                
                //Hide the indicator if we have recieved all the results
                self.delegate?.hideActivityIndicator()
            }
        } else {
            
            //We have reached the retry count. Hide the indicator.
            self.delegate?.hideActivityIndicator()
        }
    }
    
}

//MARK: - LibraryEntryDataSource
extension FullLibraryDataSource {
    
    func items() -> [ItemData] {
        guard let results = results else {
            return []
        }
        
        return Array(results).map { ItemData.from(entry: $0) }
    }
    
    func didSelectItem(at indexpath: IndexPath) {
        if let entry = results?[indexpath.row] {
            parent?.didTapEntry(entry: entry)
        }
    }
    
    /// Update the realm results we are storing and sort them
    ///
    /// - Parameter sort: The sort that is to be used
    func updateResults(with sort: LibraryViewController.Sort?) {
        
        results = LibraryEntry.belongsTo(user: userID, type: type, status: status)
        
        //Sort the results
        if let sort = sort {
            switch sort {
            case .updatedAt(let ascending):
                results = results?.sorted(byKeyPath: "updatedAt", ascending: ascending)
                break
            }
        }
        
        //Tell the delegate that we have some results
        //This is there to ensure data gets loaded properley before token is set
        self.delegate?.didReloadItems(dataSource: self)
        
        token?.stop()
        token = results?.addNotificationBlock { [unowned self] changes in
            self.delegate?.didReloadItems(dataSource: self)
            
            //Hide the indicator if results were updated
            let count = self.results?.count ?? 0
            if count > 0 {
                self.delegate?.hideActivityIndicator()
            }
            
        }
    }
    
    func didSet(sort: LibraryViewController.Sort) {
        updateResults(with: sort)
    }
}
