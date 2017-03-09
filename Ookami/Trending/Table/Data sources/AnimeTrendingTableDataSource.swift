//
//  AnimeTrendingTableDataSource.swift
//  Ookami
//
//  Created by Maka on 3/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class AnimeTrendingTableDataSource: MediaBaseTrendingTableDataSource {
    
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
    init(title: String, detail: String = "", filter: AnimeFilter, parent: UIViewController, delegate: TrendingTableDelegate, onTap: @escaping () -> Void) {
        self.filter = filter
        super.init(title: title, detail: detail, parent: parent, delegate: delegate, onTap: onTap)
    }
    
    override func paginatedService(_ completion: @escaping ([Int]?, Error?) -> Void) -> PaginatedService {
        return AnimeService().find(title: "", filters: filter, limit: 10) { ids, error, _ in
            completion(ids, error)
        }
    }
    
    override func itemData(for indexPath: IndexPath) -> ItemData? {
        if let anime = Anime.get(withId: mediaIds[indexPath.row]) {
            var data = anime.toItemData()
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
