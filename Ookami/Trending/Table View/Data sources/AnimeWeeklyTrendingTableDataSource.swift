//
//  AnimeWeeklyTrendingTableDataSource.swift
//  Ookami
//
//  Created by Maka on 10/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class AnimeWeeklyTrendingTableDataSource: MediaTrendingTableDataSource {
    
    /// Create a Weekly Anime Trending Data Source
    ///
    /// - Parameters:
    ///   - title: The title
    ///   - detail: The detail text
    ///   - parent: The parent
    ///   - delegate: The delegate
    init(title: String, detail: String = "", parent: UIViewController, delegate: TrendingTableDelegate) {
        super.init(title: title, detail: detail, parent: parent, delegate: delegate, onTap: {})
        self.showSeeAllButton = false
    }
    
    override func fetchMediaIds(_ completion: @escaping ([Int]?, Error?) -> Void) {
        AnimeService().trending(completion: completion)
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
