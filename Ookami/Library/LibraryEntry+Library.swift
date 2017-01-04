//
//  LibraryEntry+Library.swift
//  Ookami
//
//  Created by Maka on 4/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

extension LibraryEntry.Status {
    //Get the UIColor for a given status
    func color() -> UIColor {
        switch self {
        case .current:
            return UIColor(red: 155/255.0, green: 225/255.0, blue: 130/255.0, alpha: 1.0)
        case .completed:
            return UIColor(red: 112/255.0, green: 154/255.0, blue: 225/255.0, alpha: 1.0)
        case .planned:
            return UIColor(red: 225/255.0, green: 215/255.0, blue: 124/255.0, alpha: 1.0)
        case .onHold:
            return UIColor(red: 211/255.0, green: 84/255.0, blue: 0/255.0, alpha: 1.0)
        case .dropped:
            return UIColor(red: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0)
            
        }
    }
    
    func toReadableString(for type: Media.MediaType) -> String {
        switch self {
        case .current:
            return type == .anime ? "Currently Watching": "Currently Reading"
        case .planned:
            return type == .anime ? "Plan to Watch": "Plan to Read"
        case .completed:
            return "Completed"
        case .onHold:
            return "On Hold"
        case .dropped:
            return "Dropped"
        }
    }
}

extension LibraryEntry {
    /// Convert a `LibraryEntry` to `ItemData`
    ///
    /// - Returns: The `ItemData` that was converted
    func toItemData() -> ItemData {
        var data = ItemData()
        
        var maxCount = -1
        
        //Name
        if let media = self.media, let type = media.type {
            switch type {
            case .anime:
                let anime = Anime.get(withId: media.id)
                data.name = anime?.canonicalTitle
                data.posterImage = anime?.posterImage
                maxCount = anime?.episodeCount ?? -1
                break
            case .manga:
                let manga = Manga.get(withId: media.id)
                data.name = manga?.canonicalTitle
                data.posterImage = manga?.posterImage
                maxCount = manga?.chapterCount ?? -1
                break
            }
        }
        
        data.countString = maxCount > 0 ? "\(self.progress) / \(maxCount)" : "\(self.progress)"
        
        return data
    }
}
