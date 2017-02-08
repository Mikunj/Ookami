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
        
        update()
    }
    
    override func paginatedService(for searchText: String, completion: @escaping () -> Void) -> PaginatedService {
        return AnimeService().find(title: searchText, filters: filter) { [weak self] ids, error in
            
            completion()
            
            guard let strong = self else {
                return
            }
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let ids = ids else {
                print("Didn't get any ids - Discover Anime")
                return
            }
            
            //We should return the results in order they were recieved so that users can get the best results
            strong.anime = ids.flatMap { Anime.get(withId: $0) }
            strong.delegate?.didReloadItems(dataSource: strong)
        }
    }
    
    //MARK:- ItemDataSource
    override var count: Int {
        return anime.count
    }
    
    override func items() -> [ItemData] {
        return anime.map { ItemData.from(anime: $0) }
    }
    
    override func didSelectItem(at indexPath: IndexPath) {
        if let parent = parent {
            let anime = self.anime[indexPath.row]
            AppCoordinator.showAnimeVC(in: parent, anime: anime)
        }
    }
    
}
