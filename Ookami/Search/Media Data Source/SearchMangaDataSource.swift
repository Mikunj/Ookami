//
//  SearchMangaDataSource.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class SearchMangaDataSource: SearchMediaDataSource {

    //The manga we are showing
    var manga: [Manga] = []
    
    //The manga filters
    var filters: MangaFilter = MangaFilter()
    
    override func willClearData() {
        manga = []
    }
    
    override func paginatedService(for searchText: String, completion: @escaping () -> Void) -> PaginatedService {
        return MangaService().find(title: searchText, filters: filters) { [weak self] ids, error in
            guard let strong = self else {
                return
            }
            
            completion()
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let ids = ids else {
                print("Didn't get any ids - Search Manga")
                return
            }
            
            //We should return the results in order they were recieved so that users can get the best results
            strong.manga = ids.flatMap { Manga.get(withId: $0) }
        
            let data = strong.manga.map { SearchMediaTableCellData(manga: $0) }
            strong.updateData(newData: data)
        }
    }
    
    override func didTapCell(at indexPath: IndexPath, controller: SearchViewController) {
        let manga = self.manga[indexPath.row]
        AppCoordinator.showMangaVC(in: controller, manga: manga)

    }
}
