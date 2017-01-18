//
//  SearchMangaDataSource.swift
//  Ookami
//
//  Created by Maka on 17/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class SearchMangaDataSource: SearchViewControllerDataSource {
    
    weak var delegate: SearchViewControllerDelegate? = nil
    
    //The manga we are showing
    var manga: [Manga] = []
    
    //The data used for animating
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
        let manga = data[indexPath.row]
        cell.update(data: manga)
        
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
    
    //Update the manga data
    func updateData(manga: [Manga]) {
        let newData = manga.map { SearchMediaTableCellData(manga: $0) }
        let oldData = self.data
        
        self.manga = manga
        self.data = newData
        delegate?.reloadTableView(oldData: oldData, newData: newData)
    }
    
    
    func didUpdateSearch(text: String) {
        
        //Don't bother calling api if text is empty
        if text.isEmpty {
            updateData(manga: [])
            operation?.cancel()
            delegate?.hideIndicator()
            return
        }
        
        //Check if we have a operation in progress, if so then cancel it
        if operation != nil {
            operation?.cancel()
        }
        
        delegate?.showIndicator()
        operation = MangaService().find(title: text) { [weak self] ids, error in
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
                print("Didn't get any ids - Search Manga")
                return
            }
            
            //We should return the results in order they were recieved so that users can get the best results
            let manga = ids.flatMap { Manga.get(withId: $0) }
            strong.updateData(manga: manga)
        }
    }
    
    func didTapCell(at indexPath: IndexPath, controller: SearchViewController) {
        let _ = self.manga[indexPath.row]
        //TODO: show manga vc here
    }
}
