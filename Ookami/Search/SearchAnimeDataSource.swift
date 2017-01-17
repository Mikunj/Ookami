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
    
    //An array of sections that are populated
    var populatedSections: [Anime.SubType] = []
    var data: [Anime.SubType: [Anime]] = [:]
    
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
    
    func data(for anime: Anime) -> SearchMediaTableCellData {
        var data = SearchMediaTableCellData()
        
        data.name = anime.canonicalTitle
        data.posterImage = anime.posterImage
        data.synopsis = anime.synopsis
        
        //TODO: make a function in Anime extension to create details as it's being duplicated
        var details: [String] = []
        
        if anime.averageRating > 0 {
            details.append(String(format: "%.2f ★", anime.averageRating))
        }
        
        let episodeCount = anime.episodeCount > 0 ? "\(anime.episodeCount)" : "?"
        let episodeText = anime.episodeCount == 1 ? "episode" : "episodes"
        details.append("\(episodeCount) \(episodeText)")
        
        let episodeLength = anime.episodeLength > 0 ? "\(anime.episodeLength)" : "?"
        details.append("\(episodeLength) minutes")
        
        
        if anime.isAiring() {
            details.append("Airing")
        }
        
        data.details = details.joined(separator: " ᛫ ")
        
        //Indicator color
        if let entry = UserHelper.entry(forMedia: .anime, id: anime.id) {
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
    func updateData(anime: [Anime]) {
        
        populatedSections.removeAll()
        var data: [Anime.SubType: [Anime]] = [:]
        
        for type in Anime.SubType.all {
            let subAnime = anime.filter { $0.subtype == type }
            if !subAnime.isEmpty { populatedSections.append(type) }
            data[type] = subAnime
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
        let type = populatedSections[indexPath.section]
        if let anime = data[type]?[indexPath.row] {
            AppCoordinator.showAnimeVC(in: controller, anime: anime)
        }
    }
}
