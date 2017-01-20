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
import SKPhotoBrowser

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
        
        //Update the anime
        AnimeService().get(id: anime.id) { _, _ in self.reloadData() }
        
        //Reload the data
        reloadData()
    }
    
    override func sectionData() -> [MediaViewControllerSection] {
        let sections: [MediaViewControllerSection?] = [titleSection(), infoSection(), synopsisSection()]
        return sections.flatMap { $0 }
    }
    
    override func barTitle() -> String {
        return anime.canonicalTitle
    }
    
}

//MARK:- Titles section
extension AnimeViewController {
    fileprivate func titleSection() -> MediaViewControllerSection? {
        
        let titles = getTitles()
        if titles.isEmpty {
            return nil
        }
        
        var section = MediaViewControllerSection(title: "Alternate Titles", cellCount: titles.count)
        section.cellForIndexPath = { indexPath, tableView in
            let cell = tableView.dequeueReusableCell(for: indexPath) as MediaInfoTableViewCell
            
            let (title, value) = titles[indexPath.row]
            cell.infoTitleLabel.text = title
            cell.infoLabel.text = value
            
            return cell
        }
        section.estimatedHeightForRow = { _ in return 20 }
        
        return section
    }
    
    private func getTitles() -> [(String, String)] {
        let titles = anime.titles.sorted(byProperty: "key")
        let info: [(String, String)] = titles.flatMap { title in
            if let titleString = title.languageKey?.toString().capitalized, !title.value.isEmpty {
                return (titleString, title.value)
            }
            return nil
        }
        
        return info
    }
}

//MARK:- Info section
extension AnimeViewController {
    
    fileprivate func infoSection() -> MediaViewControllerSection {
        let info = getInfo()
        var section = MediaViewControllerSection(title: "Information", cellCount: info.count)
        section.cellForIndexPath = { indexPath, tableView in
            let cell = tableView.dequeueReusableCell(for: indexPath) as MediaInfoTableViewCell
            
            let (title, value) = info[indexPath.row]
            cell.infoTitleLabel.text = title
            cell.infoLabel.text = value
            
            return cell
        }
        section.estimatedHeightForRow = { _ in return 20 }
        
        return section
    }
    
    fileprivate func getInfo() -> [(title: String, value: String)] {
        var info: [(String, String)] = []
        
        info.append(("Type", anime.subtypeRaw.uppercased()))
        
        let status = anime.isAiring() ? "Airing" : "Finished Airing"
        info.append(("Status", status))
        
        let airingTitle = anime.isAiring() ? "Airing": "Aired"
        info.append((airingTitle, airingText()))
        
        let episodes = anime.episodeCount > 0 ? "\(anime.episodeCount)" : "?"
        info.append(("Episodes", episodes))
        
        let duration = anime.episodeLength > 0 ? "\(anime.episodeLength)" : "?"
        info.append(("Duration", "\(duration) minutes"))
        
        if !anime.ageRating.isEmpty {
            let prefix = anime.ageRating
            let suffix = anime.ageRatingGuide.isEmpty ? "" : " - \(anime.ageRatingGuide)"
            let rating = prefix.appending(suffix)
            info.append(("Rating", rating))
        }
        
        if anime.genres.count > 0 {
            let genres = anime.genres.map { $0.name }.filter { !$0.isEmpty }
            info.append(("Genres", genres.joined(separator: ", ")))
        }
        
        return info
    }
    
    private func airingText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        
        var startDate = "?"
        if let date = anime.startDate {
            startDate = formatter.string(from: date)
        }
        
        var endDate: String = "?"
        if let date = anime.endDate {
            endDate = formatter.string(from: date)
        }
        
        return "\(startDate) to \(endDate)"
    }
}

//MARK:- Synopsis Section
extension AnimeViewController {
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

//MARK:- Header
extension AnimeViewController {
    
    func getEntry() -> LibraryEntry? {
        return UserHelper.entry(forMedia: .anime, id: anime.id)
    }
    
    func headerData() -> MediaTableHeaderViewData {
        var data = MediaTableHeaderViewData()
        data.title = anime.canonicalTitle
        data.details = detailText()
        data.airing = ""
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
}

//MARK:- User Gestures
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
        if !anime.youtubeVideoId.isEmpty {
            let id = anime.youtubeVideoId
            AppCoordinator.showYoutubeVideo(videoID: id, in: self)
        }
    }
    
    func didTapCoverImage(_ imageView: UIImageView) {
        if !anime.coverImage.isEmpty, let image = imageView.image {
            SKPhotoBrowserOptions.displayStatusbar = false
            let vc = SKPhotoBrowser(originImage: image, photos: [SKPhoto.photoWithImage(image)], animatedFromView: imageView)
            present(vc, animated: true)
        }
    }
}
