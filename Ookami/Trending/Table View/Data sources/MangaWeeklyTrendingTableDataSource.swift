//
//  MangaWeeklyTrendingTableDataSource.swift
//  Ookami
//
//  Created by Maka on 10/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class MangaWeeklyTrendingTableDataSource: MediaTrendingTableDataSource {
    
    /// Create a Weekly Manga Trending Data Source
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
        MangaService().trending(completion: completion)
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
