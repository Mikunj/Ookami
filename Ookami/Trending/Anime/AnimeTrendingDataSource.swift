//
//  AnimeTrendingDataSource.swift
//  Ookami
//
//  Created by Maka on 3/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class AnimeTrendingDataSource: TrendingDataSource {
    
    //The filter to apply
    var filter: AnimeFilter
    
    //The current anime ids that we have
    var animeIds: [Int] = []
    
    //Whether we are currently fetching
    private(set) var fetching: Bool = false
    
    //The collection view layout to use
    override var collectionViewLayout: UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let padding: CGFloat = 4
        layout.minimumLineSpacing = padding
        layout.minimumInteritemSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: padding / 2, left: padding, bottom: padding * 2, right: padding)
        
        let phoneSize = CGSize(width: 110, height: 165)
        let padSize = CGSize(width: 150, height: 225)
        layout.itemSize = UIDevice.current.userInterfaceIdiom == .pad ? padSize : phoneSize
        
        return layout
    }
    
    /// Create an Anime Trending Data Source
    ///
    /// - Parameters:
    ///   - title: The title
    ///   - filter: The filter to use for displaying anime
    ///   - parent: The parent of the data source
    ///   - delegate: The delegate
    init(title: String, filter: AnimeFilter, parent: UIViewController, delegate: TrendingDelegate) {
        self.filter = filter
        super.init(title: title, parent: parent, delegate: delegate)
        fetchAnime()
    }
    
    //Fetch the anime
    func fetchAnime() {
        guard !fetching else { return }
        
        fetching = true
        
        let service = AnimeService().find(title: "", filters: filter) { [weak self] ids, error, _ in
            self?.fetching = false
            
            guard error == nil,
                let ids = ids else {
                    return
            }
            
            self?.animeIds = ids
            self?.reload()
        }
        
        service.start()
    }
    
    //MARK:- Collection View
    override func setup(collectionView: UICollectionView) {
        if animeIds.count == 0 { fetchAnime() }
        collectionView.register(cellType: ItemSimpleGridCell.self)
        super.setup(collectionView: collectionView)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeIds.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as ItemSimpleGridCell
        
        //Load the data
        if let anime = Anime.get(withId: animeIds[indexPath.row]) {
            var data = ItemData.from(anime: anime)
            
            //We don't want the airing status
            data.details = ""
            cell.update(data: data, loadImages: true)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let parent = parent,
            let anime = Anime.get(withId: animeIds[indexPath.row]) {
                AppCoordinator.showAnimeVC(in: parent, anime: anime)
        }
    }
    
}
