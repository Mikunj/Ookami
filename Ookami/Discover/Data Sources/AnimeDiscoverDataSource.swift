//
//  AnimeDiscoverDataSource.swift
//  Ookami
//
//  Created by Maka on 8/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

final class AnimeDiscoverDataSource: MediaDiscoverDataSource {
    
    //The filter to apply to the results
    var filter: AnimeFilter {
        didSet {
            //Fetch the anime again with the new filters
            update(search: currentSearch)
        }
    }
    
    //An array of anime in order that they need to be shown in
    var anime: [Anime] = []
    
    /// Create an Anime Discover Data Source
    ///
    /// - Parameter filter: The initial filter to use
    init(filter: AnimeFilter = AnimeFilter()) {
        self.filter = filter
        super.init()
    }
    
    override func paginatedService(for searchText: String, completion: @escaping () -> Void) -> PaginatedService {
        return AnimeService().find(title: searchText, filters: filter) { [weak self] ids, error, original in
            
            completion()
            
            guard let strong = self else {
                return
            }
            
            guard error == nil else {
                if error as? PaginationError != nil {
                    //Don't print anything if it's pagination related
                    return
                }
                
                print(error!.localizedDescription)
                return
            }
            
            guard let ids = ids else {
                print("Didn't get any ids - Discover Anime")
                return
            }
            
            //We should return the results in order they were recieved so that users can get the best results
            let anime = ids.flatMap { Anime.get(withId: $0) }
            if original {
                strong.anime = anime
            } else {
                strong.anime.append(contentsOf: anime)
            }
            
            strong.itemData = strong.anime.map { ItemData.from(anime: $0) }
            strong.delegate?.didReloadItems(dataSource: strong)
            
            //If the device is an ipad and it's the original then we fetch the next page so that content is filled up on the screen
            if UIDevice.current.userInterfaceIdiom == .pad && original {
                strong.loadMore()
            }
        }
    }
    
    //MARK:- ItemDataSource
    override func didSelectItem(at indexPath: IndexPath) {
        if let parent = parent {
            let anime = self.anime[indexPath.row]
            AppCoordinator.showAnimeVC(in: parent, anime: anime)
        }
    }
    
}
