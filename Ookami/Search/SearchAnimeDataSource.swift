//
//  SearchAnimeDataSource.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class SearchAnimeDataSource: SearchMediaDataSource {
    
    //The anime we have loaded
    var anime: [Anime] = []
    
    override func willClearData() {
        anime = []
    }
    
    override func operation(for searchText: String, completion: @escaping () -> Void) -> Operation {
        return AnimeService().find(title: searchText) { [weak self] ids, error in
            guard let strong = self else {
                return
            }
            
            completion()
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let ids = ids else {
                print("Didn't get any ids - Search Anime")
                return
            }
            
            //We should return the results in order they were recieved so that users can get the best results
            strong.anime = ids.flatMap { Anime.get(withId: $0) }
            let data = strong.anime.map { SearchMediaTableCellData(anime: $0) }
            strong.updateData(newData: data)
        }
    }
    
    override func didTapCell(at indexPath: IndexPath, controller: SearchViewController) {
        let anime = self.anime[indexPath.row]
        AppCoordinator.showAnimeVC(in: controller, anime: anime)
    }
}
