//
//  SearchMediaTableCellData.swift
//  Ookami
//
//  Created by Maka on 18/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

struct SearchMediaTableCellData {
    var name: String
    var details: String = "-"
    var moreDetails: String = "-"
    var synopsis: String
    var posterImage: String? = nil
    var indicatorColor: UIColor = UIColor.clear
    
    //Create with an anime
    init(anime: Anime) {
        self.name = anime.canonicalTitle
        self.posterImage = anime.posterImage
        self.synopsis = anime.synopsis
        
        let seperator = " ᛫ "
        self.details = details(for: anime).joined(separator: seperator)
        self.moreDetails = moreDetails(for: anime).joined(separator: seperator)
        
        //Indicator color
        if let entry = UserHelper.entry(forMedia: .anime, id: anime.id) {
            self.indicatorColor = entry.status?.color() ?? UIColor.clear
        }
    }
    
    private func details(for anime: Anime) -> [String] {
        var details: [String] = []
        
        details.append(anime.subtypeRaw.uppercased())
        
        if !anime.ageRating.isEmpty {
            details.append(anime.ageRating.uppercased())
        }
        
        if let date = anime.startDate {
            let year = Calendar.current.component(.year, from: date)
            details.append(String(year))
        }
        
        if anime.averageRating > 0 {
            details.append(String(format: "%.2f ★", anime.averageRating))
        }
        
        if anime.isAiring() {
            details.append("Airing")
        }
        
        return details
    }
    
    private func moreDetails(for anime: Anime) -> [String] {
        var moreDetails: [String] = []
        moreDetails.append(anime.episodeCountString)
        moreDetails.append(anime.episodeLengthString)
        
        return moreDetails
    }
    
    //Create with a manga
    init(manga: Manga) {
        self.name = manga.canonicalTitle
        self.posterImage = manga.posterImage
        self.synopsis = manga.synopsis
        
        let seperator = " ᛫ "
        self.details = details(for: manga).joined(separator: seperator)
        self.moreDetails = moreDetails(for: manga).joined(separator: seperator)
        
        //Indicator color
        if let entry = UserHelper.entry(forMedia: .manga, id: manga.id) {
            self.indicatorColor = entry.status?.color() ?? UIColor.clear
        }
    }
    
    private func details(for manga: Manga) -> [String] {
        var details: [String] = []
        details.append(manga.subtypeRaw.uppercased())
        
        if let date = manga.startDate {
            let year = Calendar.current.component(.year, from: date)
            details.append(String(year))
        }
        
        if manga.averageRating > 0 {
            details.append(String(format: "%.2f ★", manga.averageRating))
        }
        
        return details
    }
    
    private func moreDetails(for manga: Manga) -> [String] {
        var moreDetails: [String] = []
        let chapterCount = manga.chapterCount > 0 ? "\(manga.chapterCount)" : "?"
        let chapterText = manga.chapterCount == 1 ? "chapter" : "chapters"
        moreDetails.append("\(chapterCount) \(chapterText)")
        
        let volumeCount = manga.volumeCount > 0 ? "\(manga.volumeCount)" : "?"
        let volumeText = manga.volumeCount == 1 ? "volume" : "volumes"
        moreDetails.append("\(volumeCount) \(volumeText)")
        
        return moreDetails
    }
    
}

extension SearchMediaTableCellData: Equatable {
    static func ==(lhs: SearchMediaTableCellData, rhs: SearchMediaTableCellData) -> Bool {
        return lhs.name == rhs.name &&
            lhs.details == rhs.details &&
            lhs.synopsis == rhs.synopsis &&
            lhs.posterImage == rhs.posterImage &&
            lhs.indicatorColor == rhs.indicatorColor
    }
}
