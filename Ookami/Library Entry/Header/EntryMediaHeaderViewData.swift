//
//  EntryMediaHeaderViewData.swift
//  Ookami
//
//  Created by Maka on 19/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

struct EntryMediaHeaderViewData {
    var name: String
    var details: String
    var synopsis: String
    var mediaType: Media.MediaType? = nil
    var posterImage: String? = nil
    var coverImage: String? = nil
    
    init() {
        self.name = ""
        self.details = ""
        self.synopsis = ""
    }
    
    init(anime: Anime) {
        self.mediaType = .anime
        self.name = anime.canonicalTitle
        self.posterImage = anime.posterImage
        self.synopsis = anime.synopsis
        self.coverImage = anime.coverImage
        
        var details: [String] = []
        details.append(anime.subtypeRaw.uppercased())
        details.append(anime.episodeCountString)
        details.append(anime.episodeLengthString)
        self.details = details.joined(separator: " ᛫ ")
    }
    
    init(manga: Manga) {
        self.mediaType = .manga
        self.name = manga.canonicalTitle
        self.posterImage = manga.posterImage
        self.synopsis = manga.synopsis
        self.coverImage = manga.coverImage
        
        var details: [String] = []
        details.append(manga.subtypeRaw.uppercased())
        details.append(manga.chapterCountString)
        details.append(manga.volumeCountString)
        
        self.details = details.joined(separator: " ᛫ ")
    }
}
