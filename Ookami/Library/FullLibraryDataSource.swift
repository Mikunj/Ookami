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
final class FullLibraryDataSource: LibraryEntryDataSource {
    var delegate: ItemViewControllerDelegate? {
        didSet { delegate?.didReloadItems(dataSource: self) }
    }
    
    let userID: Int
    let type: Media.MediaType
    let status: LibraryEntry.Status
    
    var token: NotificationToken?
    var results: Results<LibraryEntry>?
    
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
        
        updateResults(with: .updatedAt)
        fetchLibrary()
    }
    
    deinit {
        token?.stop()
    }
    
    /// Fetch the library info
    func fetchLibrary() {
        var lastFetched: Date = Date(timeIntervalSince1970: 0)
        
        //Get the fetch time if user has it
        if let fetched = LastFetched.get(withId: userID) {
            switch type {
            case .anime:
                lastFetched = fetched.anime
            case .manga:
                lastFetched = fetched.manga
            }
        }
        
        LibraryService().get(userID: userID, type: type, status: status, since: lastFetched) { error in }
    }
    
    
}

//MARK: - LibraryEntryDataSource
extension FullLibraryDataSource {
    /// Convert a `LibraryEntry` to `ItemData`
    /// TODO: Move this into LibraryEntry+Library file
    ///
    /// - Parameter entry: The library entry to convert
    /// - Returns: The `ItemData` that was converted
    func toItemData(entry: LibraryEntry) -> ItemData {
        var data = ItemData()
        
        var maxCount = -1
        
        //Name
        if let media = entry.media, let type = media.type {
            switch type {
            case .anime:
                let anime = Anime.get(withId: media.id)
                data.name = anime?.canonicalTitle
                data.posterImage = anime?.posterImage
                maxCount = anime?.episodeCount ?? -1
                break
            case .manga:
                let manga = Manga.get(withId: media.id)
                data.name = manga?.canonicalTitle
                data.posterImage = manga?.posterImage
                maxCount = manga?.chapterCount ?? -1
                break
            }
        }
        
        data.countString = maxCount > 0 ? "\(entry.progress) / \(maxCount)" : "\(entry.progress)"
        
        return data
    }
    
    func items() -> [ItemData] {
        guard let results = results else {
            return []
        }
        
        return Array(results).map { toItemData(entry: $0) }
    }
    
    func didSelectItem(at indexpath: IndexPath) {
        
    }
    
    /// Update the realm results we are storing with a filter
    ///
    /// - Parameter filter: The filter that is to be used
    func updateResults(with filter: LibraryViewController.Filter?) {
        
        //TODO: Add function in LibraryEntry to make this more readable
        results = LibraryEntry.belongsTo(user: userID).filter("media.rawType = %@ AND rawStatus = %@", type.rawValue, status.rawValue).sorted(byProperty: "updatedAt", ascending: false)
        
        token?.stop()
        token = results?.addNotificationBlock { (changes: RealmCollectionChange) in
            self.delegate?.didReloadItems(dataSource: self)
        }
    }
    
    func didSet(filter: LibraryViewController.Filter) {
        updateResults(with: filter)
    }
}
