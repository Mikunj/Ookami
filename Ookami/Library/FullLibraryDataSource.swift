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
            delegate?.didReloadItems()
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
    
    //An array of the sorted library entries
    //We store these and update as we go instead of using a computed property
    //This is so that we don't get sync issues (e.g you tap cell 1, but because the data has updated, you get the page to another cell)
    fileprivate var sortedResults: [LibraryEntry] = []
    
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
        
        updateResults(with: LibraryViewController.Sort.load())
        fetchLibrary()
    }
    
    deinit {
        token?.stop()
    }
    
    func refresh() {
        fetchedEntries = false
        fetchLibrary(forced: true)
    }
    
    func loadMore() {}
    
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
                self.delegate?.didReloadItems()
                
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
    
    var count: Int {
        return results?.count ?? 0
    }
    
    func items() -> [ItemData] {
        return sortedResults.map { $0.toItemData() }
    }
    
    func didSelectItem(at indexpath: IndexPath) {
        let entry = sortedResults[indexpath.row]
        parent?.didTapEntry(entry: entry)
    }
    
    /// Update the realm results we are storing and sort them
    ///
    /// - Parameter sort: The sort that is to be used
    func updateResults(with sort: LibraryViewController.Sort?) {
        
        //Get the initial results aswell as the sorted
        results = LibraryEntry.belongsTo(user: userID, type: type, status: status)
        
        //Tell the delegate that we have some results
        //This is there to ensure data gets loaded properley before token is set
        didReloadItems(with: sort)
        
        token?.stop()
        token = results?.addNotificationBlock { [unowned self] changes in
            
            self.didReloadItems(with: sort)
            
            //Reload the library view to update the counts
            self.parent?.didUpdateEntries()
            
            //Hide the indicator if results were updated
            let count = self.results?.count ?? 0
            if count > 0 {
                self.delegate?.hideActivityIndicator()
            }
            
        }
    }
    
    func didReloadItems(with sort: LibraryViewController.Sort?) {
        getBackgroundSortedResults(with: sort) { sorted in
            self.sortedResults = sorted
            
            //Reload the data
            self.delegate?.didReloadItems()
        }
    }
    
    func didSet(sort: LibraryViewController.Sort) {
        updateResults(with: sort)
    }
    
    func shouldShowEmptyDataSet() -> Bool {
        return (results?.count ?? 0) == 0
    }
    
    func dataSetImage() -> UIImage? {
        let size = CGSize(width: 44, height: 44)
        let color = UIColor.lightGray.lighter(amount: 0.1)
        return UIImage(named: "book")?
            .resize(size)
            .color(color)
    }
    
    func dataSetTitle() -> NSAttributedString? {
        let title = "Could not find any \(type.rawValue.capitalized)."
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                          NSForegroundColorAttributeName: UIColor.lightGray.lighter(amount: 0.1)]
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    func dataSetDescription() -> NSAttributedString? {
        let description = "Pull down to refresh."
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14),
                          NSForegroundColorAttributeName: UIColor.lightGray.lighter(amount: 0.1)]
        return NSAttributedString(string: description, attributes: attributes)
    }
}

//MARK:- Sorting
extension FullLibraryDataSource {
    
    //Sort the results in the background
    func getBackgroundSortedResults(with sort: LibraryViewController.Sort?, completion: @escaping ([LibraryEntry]) -> Void) {
        
        //Make sure we have results or exit early
        guard let results = results else {
            completion([])
            return
        }
        
        let ids: [Int] = results.map { $0.id }
        
        //Start the background work
        DispatchQueue.global(qos: .background).async {
            
            let entries = LibraryEntry.get(withIds: ids)
            let results = self.getSorted(results: entries, with: sort)
            let sortedIds: [Int] = results.map { $0.id }
            
            DispatchQueue.main.async {
                
                //We flatMap it here instead of using `get(withIds:)` because we care about the order.
                //Using `get(withIds:)` doesn't always guarantee they'll be in the order we sent the ids in.
                let sortedEntries = sortedIds.flatMap { LibraryEntry.get(withId: $0) }
                completion(sortedEntries)
            }
            
        }
        
    }
    
    func getSorted(results: Results<LibraryEntry>?, with sort: LibraryViewController.Sort?) -> [LibraryEntry] {
        
        //Check if we need to sort
        guard let results = results else { return [] }
        guard let sort = sort else { return Array(results) }
        
        let ascending = sort.direction == .ascending
        
        //Apply the sort
        switch sort.type {
        case .updatedAt:
            //We don't need to add a secondary sort for title as it's going to be very unlikely that we'll get 2 same values
            return Array(results.sorted(byKeyPath: "updatedAt", ascending: ascending))
            
        case .title:
            return titleSort(results: results, ascending: ascending)
            
        case .progress:
            return self.sorted(results: results) { first, second in
                return (first.progress, second.progress, ascending)
            }
            
        case .rating:
            return self.sorted(results: results) { first, second in
                return (first.rating, second.rating, ascending)
            }
        }
    }
    
    //Sort results by the given values (T1, T2, Bool). The bool indicated whether the sort is ascending.
    private func sorted<T: Comparable>(results: Results<LibraryEntry>, by values: (LibraryEntry, LibraryEntry) -> (T, T, Bool)) -> [LibraryEntry] {
        
        //Get the titles from 2 entries. Helper closure
        let titles: (LibraryEntry, LibraryEntry) -> (String, String) = {
            return (self.title(from: $0), self.title(from: $1))
        }
        
        return Array(results.sorted(by: { first, second -> Bool in
            let input = values(first, second)
            return self.sort(primary: (input.0, input.1), secondary: titles(first, second), ascending: input.2)
        }))
    }
    
    //Sort by primary value P, and then secondary values S if the primary values are the same.
    //S will always be sorted descending.
    private func sort<P: Comparable, S: Comparable>(primary: (P, P), secondary: (S, S), ascending: Bool) -> Bool {
        switch primary {
        case let (lhs, rhs) where lhs == rhs:
            return secondary.0 < secondary.1
        case let (lhs, rhs):
            return compare(lhs: lhs, rhs: rhs, ascending: ascending)
        }
    }
    
    //Compare two objects of type T
    private func compare<T: Comparable>(lhs: T, rhs: T, ascending: Bool) -> Bool {
        let c: (T, T) -> Bool = ascending ? (>) : (<)
        return c(lhs, rhs)
    }
    
    //MARK:- Title
    private func titleSort(results: Results<LibraryEntry>, ascending: Bool) -> [LibraryEntry] {
        
        return results.sorted(by: { first, second -> Bool in
            return compare(lhs: title(from: first), rhs: title(from: second), ascending: ascending)
        })
        
    }
    
    private func title(from entry: LibraryEntry) -> String {
        //Note: In the future, if users can select which titles to use, then this will need to change to relect that
        return entry.anime?.canonicalTitle ?? entry.manga?.canonicalTitle ?? ""
    }
}
