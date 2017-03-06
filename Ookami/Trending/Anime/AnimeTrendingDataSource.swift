//
//  AnimeTrendingDataSource.swift
//  Ookami
//
//  Created by Maka on 3/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class AnimeTrendingDataSource: MediaTrendingDataSource {
    
    //The filter to apply
    var filter: AnimeFilter
    
    /// Create an Anime Trending Data Source
    ///
    /// - Parameters:
    ///   - title: The title
    ///   - detail: The detail
    ///   - filter: The filter to use for displaying anime
    ///   - parent: The parent of the data source
    ///   - delegate: The delegate
    ///   - onTap: The block which gets called when the see all button is tapped.
    init(title: String, detail: String = "", filter: AnimeFilter, parent: UIViewController, delegate: TrendingDelegate, onTap: @escaping () -> Void) {
        self.filter = filter
        super.init(title: title, detail: detail, parent: parent, delegate: delegate, onTap: onTap)
    }
    
    //Fetch the anime
    override func fetch() {
        guard !fetching else { return }
        
        fetching = true
        
        let service = AnimeService().find(title: "", filters: filter, limit: 10) { [weak self] ids, error, _ in
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
        if let anime = Anime.get(withId: mediaIds[indexPath.row]) {
            var data = ItemData.from(anime: anime)
            data.details = ""
            return data
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let parent = parent,
            let anime = Anime.get(withId: mediaIds[indexPath.row]) {
                AppCoordinator.showAnimeVC(in: parent, anime: anime)
        }
    }
    
}
