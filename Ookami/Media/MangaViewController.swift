//
//  MangaViewController.swift
//  Ookami
//
//  Created by Maka on 20/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import UIKit
import OokamiKit
import RealmSwift
import SKPhotoBrowser

//TODO: Add more sections (characters, franchise)

//A view controller to display manga
class MangaViewController: MediaViewController {
    
    fileprivate var manga: Manga
    
    /// Create an `MangaViewController`
    ///
    /// - Parameter manga: The manga to display
    init(manga: Manga) {
        self.manga = manga
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(manga:) instead")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mediaHeader.data = headerData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the header data
        mediaHeader.data = headerData()
        mediaHeader.delegate = self
        
        //Update the manga
        MangaService().get(id: manga.id) { _, _ in self.reloadData() }
        
        //Reload the data
        reloadData()
    }
    
    override func sectionData() -> [MediaViewControllerSection] {
        let sections: [MediaViewControllerSection?] = [titleSection(), infoSection(), synopsisSection()]
        return sections.flatMap { $0 }
    }
    
    override func barTitle() -> String {
        return manga.canonicalTitle
    }
    
    override func entryDidChange(notification: Notification) {
        //Check if the entry that changed was for this manga
        if let info = notification.userInfo,
            let mediaID = info["mediaID"] as? Int,
            let mediaType = info["mediaType"] as? Media.MediaType,
            mediaID == manga.id,
            mediaType == .manga {
            mediaHeader.data = headerData()
        }
    }
    
}

//MARK:- Titles section
extension MangaViewController {
    fileprivate func titleSection() -> MediaViewControllerSection? {
        return MediaViewControllerHelper.getTitleSection(for: manga.titles)
    }
}

//MARK:- Info section
extension MangaViewController {
    
    fileprivate func infoSection() -> MediaViewControllerSection {
        let info = getInfo()
        return MediaViewControllerHelper.getSectionWithMediaInfoCell(title: "Information", info: info)
    }
    
    fileprivate func getInfo() -> [(title: String, value: String)] {
        var info: [(String, String)] = []
        
        info.append(("Type", manga.subtypeRaw.uppercased()))
        
        let status = manga.isFinished() ? "Finished" : "Publishing"
        info.append(("Status", status))
        
        let publishedText = MediaViewControllerHelper.dateRangeText(start: manga.startDate, end: manga.endDate)
        info.append(("Published", publishedText))
        
        let chapters = manga.chapterCount > 0 ? "\(manga.chapterCount)" : "?"
        info.append(("Chapters", chapters))
        
        let volumes = manga.volumeCount > 0 ? "\(manga.volumeCount)" : "?"
        info.append(("Volumes", "\(volumes)"))
        
        info.append(("Serialization", manga.serialization))
        
        if !manga.ageRating.isEmpty {
            let prefix = manga.ageRating
            let suffix = manga.ageRatingGuide.isEmpty ? "" : " - \(manga.ageRatingGuide)"
            let rating = prefix.appending(suffix)
            info.append(("Rating", rating))
        }
        
        if manga.genres.count > 0 {
            let genres = manga.genres.map { $0.name }.filter { !$0.isEmpty }
            info.append(("Genres", genres.joined(separator: ", ")))
        }
        
        return info
    }
}

//MARK:- Synopsis Section
extension MangaViewController {
    fileprivate func synopsisSection() -> MediaViewControllerSection {
        return MediaViewControllerHelper.getSynopsisSection(synopsis: manga.synopsis)
    }
}

//MARK:- Header
extension MangaViewController {
    
    func headerData() -> MediaTableHeaderViewData {
        var data = MediaTableHeaderViewData()
        data.title = manga.canonicalTitle
        data.details = ""
        data.airing = ""
        data.posterImage = manga.posterImage
        data.coverImage = manga.coverImage
        
        //Update if we have the entry or not
        let entry = MediaViewControllerHelper.getEntry(id: manga.id, type: .manga)
        data.entryState = entry == nil ? .add : .edit
        
        return data
    }
    
}

//MARK:- User Gestures
extension MangaViewController: MediaTableHeaderViewDelegate {
    
    func didTapEntryButton(state: MediaTableHeaderView.EntryButtonState) {
        MediaViewControllerHelper.tappedEntryButton(state: state, mediaID: manga.id, mediaType: .manga, parent: self) { error in
            
            //User added manga
            guard error == nil else {
                ErrorAlert.showAlert(in: self, title: "Error Occured", message: error!.localizedDescription)
                return
            }
        }
    }
    
    func didTapTrailerButton() {}
    
    func didTapCoverImage(_ imageView: UIImageView) {
        MediaViewControllerHelper.tappedImageView(imageView, in: self)
    }
}
