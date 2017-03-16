//
//  AnimeYearTrendingDataSource.swift
//  Ookami
//
//  Created by Maka on 6/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class AnimeYearTrendingDataSource: MediaYearTrendingDataSource {
    
    //The filter we are going to use
    var initialFilter: AnimeFilter
    
    /// Create an Anime Year Trending Data Source
    ///
    /// - Parameter filter: The initial filter to use.
    init(filter: AnimeFilter = AnimeFilter()) {
        self.initialFilter = filter.copy()
    }
    
    override func paginatedService(_ completion: @escaping () -> Void) -> PaginatedService? {
        
        guard currentYear > 0 else { return nil }
        
        return service(for: filter(), completion: completion)
    }
    
    //Get the filter with the current year applied
    func filter() -> AnimeFilter {
        let filter = initialFilter.copy()
        filter.year = RangeFilter<Int>(start: currentYear, end: currentYear)
        return filter
    }
    
    func service(for filter: AnimeFilter, completion: @escaping () -> Void) -> PaginatedService {
        return AnimeService().find(title: "", filters: filter) { [weak self] ids, error, original in
            
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
