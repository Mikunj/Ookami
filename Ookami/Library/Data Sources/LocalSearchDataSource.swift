//
//  LocalSearchDataSource.swift
//  Ookami
//
//  Created by Maka on 27/6/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import RealmSwift

//Note: Maybe ontop of just searching the local realm storage, also search the entry on kitsu. This is because some users libraries don't get loaded fully due to a kitsu bug, and if they search for the entry then it should be added in

//A datasource which uses the local realm storage for searching
final class LocalSearchDataSource: SearchDataSource {
    
    //The user id
    let userID: Int
    
    //The type of library
    let type: Media.MediaType
    
    //The parent to report to
    weak var parent: UIViewController?
    
    //The current search text
    private var currentSearch: String = ""
    
    //We want to display the results exactly as they're shown in the library
    var searchDisplayType: ItemViewController.CellType {
        return .detailGrid
    }
    
    //The placeholder text in the search bar
    var searchBarPlaceHolder: String {
        return "Search by title"
    }
    
    //The delegate
    weak var delegate: ItemViewControllerDelegate? {
        didSet {
            delegate?.didReloadItems()
        }
    }
    
    //The items to show
    var itemData: [ItemData] = [] {
        didSet {
            self.delegate?.didReloadItems()
        }
    }
    
    //Realm tokem
    private var token: NotificationToken?
    
    //The sorted entries
    private var sortedEntries: [LibraryEntry] = []
    
    //The filtered entries
    private var filteredEntries: [LibraryEntry] = []
    
    /// Create a LocalSearchDataSource which uses the realm data to search for entries of a given user and of a given type.
    ///
    /// - Parameters:
    ///   - userID: The user id
    ///   - type: The type of the entries to search.
    init(userID: Int, type: Media.MediaType) {
        self.userID = userID
        self.type = type
        
        //Get all the entries and add a notification block to them
        token = LibraryEntry.belongsTo(user: userID, type: type).addNotificationBlock { [weak self] changes in
            guard let strongSelf = self else { return }
            
            //This operation takes some time depending on the amount of entries the user has
            //Maybe find a better/faster way to sort by title?
            strongSelf.sortedResultsByTitle { sorted in
                strongSelf.sortedEntries = sorted
                strongSelf.update(search: strongSelf.currentSearch)
            }
        }
    }
    
    deinit {
        token?.stop()
    }
    
    /// Update the search results.
    ///
    /// - Parameter search: The text to search for, or blank if you want everything
    private func update(search: String = "") {
        
        //Set the current search
        currentSearch = search
        
        //Filter the entries
        backgroundFilter(title: currentSearch) { entries in
            self.filteredEntries = entries
            self.itemData = self.filteredEntries.map { $0.toItemData() }
        }
        //filteredEntries = filter(entries: sortedEntries, title: currentSearch)
        
    }
    
    /// Sort the library entry results by their titles
    /// This is done in a background thread.
    ///
    /// - Returns: The sorted entries
    private func sortedResultsByTitle(_ completion: @escaping ([LibraryEntry]) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            //Fetch the entries in the background and sort them
            let entries = LibraryEntry.belongsTo(user: self.userID, type: self.type)
            let results = entries.sorted(by: { first, second -> Bool in
                return self.title(from: first) < self.title(from: second)
            })
            let sortedIds = results.map { $0.id }
            
            DispatchQueue.main.async {
                
                //We flatMap it here instead of using `get(withIds:)` because we care about the order.
                //Using `get(withIds:)` doesn't always guarantee they'll be in the order we sent the ids in.
                let sortedEntries = sortedIds.flatMap { LibraryEntry.get(withId: $0) }
                completion(sortedEntries)
            }
            
        }
        
    }
    
    private func title(from entry: LibraryEntry) -> String {
        //Note: In the future, if users can select which titles to use, then this will need to change to relect that
        return entry.anime?.canonicalTitle ?? entry.manga?.canonicalTitle ?? ""
    }
    
    /// Filter the given entries which contain the given title
    ///
    /// - Parameters:
    ///   - entries: The array of entries
    ///   - title: The title to filter
    /// - Returns: An array of entries with the given title in their titles
    private func filter(entries: [LibraryEntry], title: String) -> [LibraryEntry] {
        
        if title.isEmpty {
            return entries
        }
        
        return entries.filter { entry in
            guard let mediaTitles = entry.anime?.titles ?? entry.manga?.titles else { return false }
            
            //Go through each title and see if it contains the given title string
            for mediaTitle in mediaTitles {
                if mediaTitle.value.lowercased().contains(title.lowercased()) {
                    return true
                }
            }
            
            return false
        }
    }
    
    /// Apply the title filter in a background thread.
    /// We do this because for very large libraryies it may be slow filtering on the main thread which can cause the UI to hang. We want to avoid this ALWAYS when making mobile apps, thus we move the filtering to a background thread.
    ///
    /// - Parameters:
    ///   - title: The title to filter
    ///   - completion: The completion block which passes back the filtered entries
    private func backgroundFilter(title: String, _ completion: @escaping ([LibraryEntry]) -> Void) {
        
        let sorted = sortedEntries.map { $0.id }
        DispatchQueue.global(qos: .background).async {
            
            //Fetch the entries in the background and filter them
            let entries = sorted.flatMap { LibraryEntry.get(withId: $0) }
            
            let filtered = self.filter(entries: entries, title: title)
            let filteredIds = filtered.map { $0.id }
            
            DispatchQueue.main.async {
                
                //We flatMap it here instead of using `get(withIds:)` because we care about the order.
                //Using `get(withIds:)` doesn't always guarantee they'll be in the order we sent the ids in.
                let filteredEntries = filteredIds.flatMap { LibraryEntry.get(withId: $0) }
                completion(filteredEntries)
            }
            
        }
    }
    
    func didSearch(text: String) {
        if currentSearch != text {
            update(search: text)
        }
    }
    
    var count: Int {
        return itemData.count
    }
    
    func items() -> [ItemData] {
        return itemData
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        if let parent = parent {
            let entry = filteredEntries[indexPath.row]
            
            if let anime = entry.anime  {
                AppCoordinator.showAnimeVC(in: parent, anime: anime)
            }
            
            if let manga = entry.manga {
                AppCoordinator.showMangaVC(in: parent, manga: manga)
            }
        }
    }
    
    //These 2 functions are unneeded because we are directly fetching from realm
    func refresh() {}
    func loadMore() {}
    
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

