//
//  LibraryEntry+EntryViewData.swift
//  Ookami
//
//  Created by Maka on 6/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import OokamiKit

extension LibraryEntry {
    
    ///TODO: Maybe let the media build the data themselves? E.g anime.toEntryMediaHeaderData()
    /// Convert `LibraryEntry` to `EntryMediaHeaderViewData`
    ///
    /// - Returns: The data representation of entry
    func toEntryMediaHeaderData() -> EntryMediaHeaderViewData {
        var data = EntryMediaHeaderViewData()
        
        //An array of the details to include
        var details: [String] = []
        
        //Name
        if let media = self.media, let type = media.type {
            //Set the type
            data.mediaType = type
            
            switch type {
            case .anime:
                //Make sure we have an anime
                guard let anime = self.anime else {
                    break
                }
                
                data.name = anime.canonicalTitle
                data.posterImage = anime.posterImage
                data.synopsis = anime.synopsis
                data.coverImage = anime.coverImage
                details.append(anime.subtypeRaw.uppercased())
                
                if anime.episodeCount > 0 {
                    details.append("\(anime.episodeCount) episodes")
                }
                
                if anime.episodeLength > 0 {
                    details.append("\(anime.episodeLength) minutes")
                }
                
                break
            case .manga:
                guard let manga = self.manga else {
                    break
                }
                
                data.name = manga.canonicalTitle
                data.posterImage = manga.posterImage
                data.synopsis = manga.synopsis
                data.coverImage = manga.coverImage
                details.append(manga.subtypeRaw.uppercased())
                break
            }
        }
        
        //Combine the details
        let detailString = details.joined(separator: " ᛫ ")
        data.details = detailString
        
        
        return data
    }
}
