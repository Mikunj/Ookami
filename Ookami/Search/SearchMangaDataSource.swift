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
    
    //An array of sections that are populated
    var populatedSections: [Manga.SubType] = []
    var data: [Manga.SubType: [Manga]] = [:]
    
    var operation: Operation? = nil
    
    init(parent: UITableView) {
        parent.register(cellType: SearchMediaTableViewCell.self)
    }
    
    //We use populatedSections to only show sections which have data
    //No point in showing Movie if there is no movie in the response
    func numberOfSection(in tableView: UITableView) -> Int {
        return populatedSections.count
    }
    
    func numberOfRows(in section: Int, tableView: UITableView) -> Int {
        let type = populatedSections[section]
        return data[type]?.count ?? 0
    }
    
    func cellForRow(at indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as SearchMediaTableViewCell
        
        let type = populatedSections[indexPath.section]
        if let anime = data[type]?[indexPath.row] {
            cell.update(data: data(for: anime))
        }
        
        return cell
    }
    
    func data(for manga: Manga) -> SearchMediaTableCellData {
        var data = SearchMediaTableCellData()
        
        data.name = manga.canonicalTitle
        data.posterImage = manga.posterImage
        data.synopsis = manga.synopsis
        
        var details: [String] = []
        
        if manga.averageRating > 0 {
            details.append(String(format: "%.2f ★", manga.averageRating))
        }
        
        let chapterCount = manga.chapterCount > 0 ? "\(manga.chapterCount)" : "?"
        details.append("\(chapterCount) chapters")
        
        let volumeCount = manga.volumeCount > 0 ? "\(manga.volumeCount)" : "?"
        details.append("\(volumeCount) volumes")
        
        data.details = details.joined(separator: " ᛫ ")
        
        //Indicator color
        if let entry = UserHelper.entry(forMedia: .manga, id: manga.id) {
            data.indicatorColor = entry.status?.color() ?? UIColor.clear
        }
        
        return data
    }
    
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        return isIpad ? 332 : 166
    }
    
    //If you return nil then no section header is displayed
    func title(for section: Int) -> String? {
        let type = populatedSections[section]
        return type.rawValue.uppercased()
    }
    
    //Update the anime data
    func updateData(manga: [Manga]) {
        
        populatedSections.removeAll()
        var data: [Manga.SubType: [Manga]] = [:]
        
        for type in Manga.SubType.all {
            let subManga = manga.filter { $0.subtype == type }
            if !subManga.isEmpty { populatedSections.append(type) }
            data[type] = subManga
        }
        
        self.data = data
        delegate?.reloadTableView()
    }
    
    
    func didUpdateSearch(text: String) {
        
        //Don't bother calling api if text is empty
        if text.isEmpty {
            populatedSections.removeAll()
            data = [:]
            operation?.cancel()
            delegate?.reloadTableView()
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
                print("Didn't get any ids - Search Anime")
                return
            }
            
            //We should return the results in order they were recieved so that users can get the best results
            let manga = ids.flatMap { Manga.get(withId: $0) }
            strong.updateData(manga: manga)
        }
    }
    
    func didTapCell(at indexPath: IndexPath, controller: SearchViewController) {
        let type = populatedSections[indexPath.section]
        if let manga = data[type]?[indexPath.row] {
            //TODO: show manga vc here
        }
    }
}
