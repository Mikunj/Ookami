//
//  ItemData+DiscoverView.swift
//  Ookami
//
//  Created by Maka on 8/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

extension ItemData {
    
    static func from(anime: Anime) -> ItemData {
        let details = anime.isAiring() ? "Airing" : nil
        
        return ItemData(name: anime.canonicalTitle, details: details, moreDetails: anime.subtype?.rawValue.uppercased(), posterImage: anime.posterImage, coverImage: anime.coverImage)
    }
    
    static func from(manga: Manga) -> ItemData {
        return ItemData(name: manga.canonicalTitle, details: nil, moreDetails: manga.subtype?.rawValue.uppercased(), posterImage: manga.posterImage, coverImage: manga.coverImage)
    }
}
