//
//  MangaYearTrendingDataSource.swift
//  Ookami
//
//  Created by Maka on 6/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class MangaYearTrendingDataSource: MediaYearTrendingDataSource {
    
    //The filter we are going to use
    var filter: MangaFilter
    
    //An array of manga in order that they need to be shown in
    var manga: [Manga] = []
    
    /// Create an Manga Year Trending Data Source
    ///
    /// - Parameter filter: The initial filter to use.
    init(filter: MangaFilter = MangaFilter()) {
        self.filter = filter.copy()
    }
    
    /// Get the paginated service for a given search string
    ///
    /// - Parameters:
    ///   - searchText: The search string
    ///   - completion: The completion block
    /// - Returns: The paginated service
    override func paginatedService(for year: Int, completion: @escaping () -> Void) -> PaginatedService {
        
        //Use a copied version of the filter so we don't get any unintended value changes
        let copiedFilter = filter.copy()
        copiedFilter.year = RangeFilter<Int>(start: year, end: year)
        
        return MangaService().find(title: "", filters: copiedFilter) { [weak self] ids, error, original in
            
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
                print("Didn't get any ids - Year Trending Manga")
                return
            }
            
            //We should return the results in order they were recieved so that users can get the best results
            let manga = ids.flatMap { Manga.get(withId: $0) }
            if original {
                strong.manga = manga
            } else {
                strong.manga.append(contentsOf: manga)
            }
            
            strong.itemData = strong.manga.map { ItemData.from(manga: $0) }
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
            let manga = self.manga[indexPath.row]
            AppCoordinator.showMangaVC(in: parent, manga: manga)
        }
    }
}
