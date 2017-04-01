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
    
    /// Create an Anime Discover Data Source
    ///
    /// - Parameter filter: The initial filter to use
    init(filter: AnimeFilter = AnimeFilter()) {
        self.filter = filter
        super.init()
    }
    
    /// Get the paginated service for the current search string
    override func paginatedService(_ completion: @escaping () -> Void) -> PaginatedService {
        return DiscoverService().find(type: .anime, title: currentSearch, filters: filter) { [weak self] ids, error, original in
            
            completion()
            
            guard error == nil,
                let ids = ids else {
                    if error as? PaginationError != nil {
                        //Don't print anything if it's pagination related
                        return
                    }
                    
                    print(error!.localizedDescription)
                    return
            }
            
            //We should return the results in order they were recieved so that users can get the best results
            let anime = ids.flatMap { Anime.get(withId: $0) }
            self?.updateItemData(from: anime, original: original)
            
            //If the device is an ipad and it's the original then we fetch the next page so that content is filled up on the screen
            if UIDevice.current.userInterfaceIdiom == .pad && original {
                self?.loadMore()
            }
        }
    }
    
    //MARK:- ItemDataSource
    override func didSelectItem(at indexPath: IndexPath) {
        if let parent = parent,
            let anime = self.data[indexPath.row] as? Anime {
            AppCoordinator.showAnimeVC(in: parent, anime: anime)
        }
    }
    
}
