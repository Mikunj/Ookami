//
//  AnimeViewController.swift
//  Ookami
//
//  Created by Maka on 13/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import RealmSwift

//TODO: Add more sections (characters, franchise)

//A view controller to display anime
class AnimeViewController: MediaViewController {
    
    fileprivate var anime: Anime
    
    /// Create an `AnimeViewController`
    ///
    /// - Parameter anime: The anime to display
    init(anime: Anime) {
        self.anime = anime
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(anime:) instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the header data
        mediaHeader.data = headerData()
        mediaHeader.delegate = self
        
        //TODO: Update anime here
        
        //Reload the data
        reloadData()
    }
    
    override func sectionData() -> [MediaViewControllerSection] {
        let sections: [MediaViewControllerSection?] = [genreSection(), synopsisSection()]
        return sections.flatMap { $0 }
    }
    
}

//MARK:- Sections
extension AnimeViewController {
    fileprivate func genreSection() -> MediaViewControllerSection? {
        guard anime.genres.count > 0 else {
            return nil
        }
        
        var genre = MediaViewControllerSection(title: "Genres", cellCount: 1)
        genre.cellForIndexPath = { indexPath, tableView in
            let cell = tableView.dequeueReusableCell(for: indexPath) as MediaTextTableViewCell
            
            let names = self.anime.genres.map { $0.name }.filter { !$0.isEmpty }
            cell.simpleTextLabel.text = names.joined(separator: ",")
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        return genre
    }
    
    fileprivate func synopsisSection() -> MediaViewControllerSection {
        var synopsis = MediaViewControllerSection(title: "Synopsis", cellCount: 1)
        synopsis.cellForIndexPath = { indexPath, tableView in
            let cell = tableView.dequeueReusableCell(for: indexPath) as MediaTextTableViewCell
            
            cell.isUserInteractionEnabled = false
            cell.simpleTextLabel.text = self.anime.synopsis
            return cell
        }
        
        return synopsis
    }
}

extension AnimeViewController {
    
    func getEntry() -> LibraryEntry? {
        guard let user = CurrentUser().userID else {
            return nil
        }
        
        let entries = LibraryEntry.belongsTo(user: user, type: .anime)
        let entry = entries.first { e in
            guard let media = e.media else { return false }
            return media.id == anime.id
        }
        
        return entry
    }
    
    func headerData() -> MediaTableHeaderViewData {
        var data = MediaTableHeaderViewData()
        data.title = anime.canonicalTitle
        data.details = detailText()
        data.airing = airingText()
        data.showTrailerIcon = !anime.youtubeVideoId.isEmpty
        data.posterImage = anime.posterImage
        data.coverImage = anime.coverImage
        
        //Update if we have the entry or not
        let entry = getEntry()
        data.entryState = entry == nil ? .add : .edit
        
        return data
    }
    
    private func detailText() -> String {
        var details: [String] = []
        details.append(anime.subtypeRaw.uppercased())
        
        details.append(anime.ageRating)
        
        let episodes = anime.episodeCount > 0 ? "\(anime.episodeCount)" : "?"
        details.append("\(episodes) eps")
        
        let length = anime.episodeLength > 0 ? "\(anime.episodeLength)" : "?"
        details.append("\(length) mins")
        
        let rating = String(format: "%.2f ★", anime.averageRating)
        details.append(rating)
        
        return details.joined(separator: " ᛫ ")
    }
    
    private func airingText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        
        var startDate = "?"
        if let date = anime.startDate {
            startDate = formatter.string(from: date)
        }
        
        var endDate: String? = nil
        if let date = anime.endDate {
            endDate = formatter.string(from: date)
        }
        
        let prefix = endDate == nil ? "Airing from" : "Aired"
        let suffix = endDate == nil ? "" : "to \(endDate!)"
        return "\(prefix) \(startDate) \(suffix)"
    }
}

extension AnimeViewController: MediaTableHeaderViewDelegate {
    
    func didTapEntryButton(state: MediaTableHeaderView.EntryButtonState) {
        switch state {
        case .edit:
            if let entry = getEntry() {
                AppCoordinator.showLibraryEntryVC(in: self.navigationController, entry: entry)
            }
            break
        default:
            break
        }
    }
    
    func didTapTrailerButton() {
        
    }
}
