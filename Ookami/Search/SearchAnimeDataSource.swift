//
//  SearchAnimeDataSource.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class SearchAnimeDataSource: SearchViewControllerDataSource {
    
    weak var delegate: SearchViewControllerDelegate? = nil
    
    //The anime we have loaded
    var anime: [Anime] = []
    
    //The data used for animation
    var data: [SearchMediaTableCellData] = []
    
    //The network operation
    var operation: Operation? = nil
    
    init(parent: UITableView) {
        parent.register(cellType: SearchMediaTableViewCell.self)
    }
    
    //We use populatedSections to only show sections which have data
    //No point in showing Movie if there is no movie in the response
    func numberOfSection(in tableView: UITableView) -> Int {
        return 1
    }
    
    func numberOfRows(in section: Int, tableView: UITableView) -> Int {
        return data.count
    }
    
    func cellForRow(at indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as SearchMediaTableViewCell
        
        let animeData = data[indexPath.row]
        cell.update(data: animeData)
        
        
        return cell
    }
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        return isIpad ? 332 : 166
    }
    
    //If you return nil then no section header is displayed
    func title(for section: Int) -> String? {
        return nil
    }
    
    //Update the anime data
    func updateData(anime: [Anime]) {
        let newData = anime.map { SearchMediaTableCellData(anime: $0) }
        let oldData = self.data
        
        self.anime = anime
        self.data = newData
        delegate?.reloadTableView(oldData: oldData, newData: newData)
    }
    
    
    func didUpdateSearch(text: String) {
        
        //Don't bother calling api if text is empty
        if text.isEmpty {
            updateData(anime: [])
            operation?.cancel()
            delegate?.hideIndicator()
            return
        }
        
        //Check if we have a operation in progress, if so then cancel it
        if operation != nil {
            operation?.cancel()
        }
        
        delegate?.showIndicator()
        operation = AnimeService().find(title: text) { [weak self] ids, error in
            guard let strong = self else {
                return
            }
            
            strong.operation = nil
            strong.delegate?.hideIndicator()
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let ids = ids else {
                print("Didn't get any ids - Search Anime")
                return
            }
            
            //We should return the results in order they were recieved so that users can get the best results
            let anime = ids.flatMap { Anime.get(withId: $0) }
            strong.updateData(anime: anime)
        }
    }
    
    func didTapCell(at indexPath: IndexPath, controller: SearchViewController) {
        let anime = self.anime[indexPath.row]
        AppCoordinator.showAnimeVC(in: controller, anime: anime)
        
    }
}
