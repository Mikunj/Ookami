//
//  MangaDiscoverDataSource.swift
//  Ookami
//
//  Created by Maka on 8/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

final class MangaDiscoverDataSource: MediaDiscoverDataSource {
    
    //The filter to apply to the results
    var filter: MangaFilter {
        didSet {
            //Fetch the manga again with the new filters
            update(search: currentSearch)
        }
    }
    
    //An array of manga in order that they need to be shown in
    var manga: [Manga] = []
    
    /// Create a Manga Discover Data Source
    ///
    /// - Parameter filter: The initial filter to use
    init(filter: MangaFilter = MangaFilter()) {
        self.filter = filter
        super.init()
    }
    
    override func paginatedService(for searchText: String, completion: @escaping () -> Void) -> PaginatedService {
        return MangaService().find(title: searchText, filters: filter) { [weak self] ids, error, original in
            
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
                print("Didn't get any ids - Discover Manga")
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

