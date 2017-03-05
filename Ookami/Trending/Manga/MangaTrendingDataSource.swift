//
//  MangaTrendingDataSource.swift
//  Ookami
//
//  Created by Maka on 6/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class MangaTrendingDataSource: MediaTrendingDataSource {
    
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
    init(title: String, detail: String = "", filter: MangaFilter, parent: UIViewController, delegate: TrendingDelegate) {
        self.filter = filter
        super.init(title: title, detail: detail, parent: parent, delegate: delegate)
    }
    
    //Fetch the manga
    override func fetch() {
        guard !fetching else { return }
        
        fetching = true
        
        let service = MangaService().find(title: "", filters: filter, limit: 10) { [weak self] ids, error, _ in
            self?.fetching = false
            
            guard error == nil,
                let ids = ids else {
                    return
            }
            
            self?.mediaIds = ids
            self?.reload()
        }
        
        service.start()
    }
    
    override func itemData(for indexPath: IndexPath) -> ItemData? {
        if let manga = Manga.get(withId: mediaIds[indexPath.row]) {
            var data = ItemData.from(manga: manga)
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

