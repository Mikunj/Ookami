//
//  MangaTrendingTableDataSource.swift
//  Ookami
//
//  Created by Maka on 6/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class MangaTrendingTableDataSource: MediaBaseTrendingTableDataSource {
    
    //The filter to apply
    var filter: MangaFilter
    
    /// Create an Manga Trending Data Source
    ///
    /// - Parameters:
    ///   - title: The title
    ///   - detail: The detail
    ///   - filter: The filter to use for displaying manga
    ///   - parent: The parent of the data source
    ///   - delegate: The delegate
    ///   - onTap: The block which gets called when the see all button is tapped.
    init(title: String, detail: String = "", filter: MangaFilter, parent: UIViewController, delegate: TrendingTableDelegate, onTap: @escaping () -> Void) {
        self.filter = filter
        super.init(title: title, detail: detail, parent: parent, delegate: delegate, onTap: onTap)
    }
    
    override func paginatedService(_ completion: @escaping ([Int]?, Error?) -> Void) -> PaginatedService {
        return MangaService().find(title: "", filters: filter, limit: 10) { ids, error, _ in
            completion(ids, error)
        }
    }
    
    override func itemData(for indexPath: IndexPath) -> ItemData? {
        if let manga = Manga.get(withId: mediaIds[indexPath.row]) {
            var data = manga.toItemData()
            data.details = ""
            return data
        }
        
        return nil
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let parent = parent,
            let manga = Manga.get(withId: mediaIds[indexPath.row]) {
            AppCoordinator.showMangaVC(in: parent, manga: manga)
        }
    }
    
}

