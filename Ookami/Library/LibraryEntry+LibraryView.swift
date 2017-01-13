//
//  LibraryEntry+LibraryView.swift
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
    
}

//MARK:- Item Data
extension LibraryEntry {
    
    /// Convert a `LibraryEntry` to `ItemData`
    ///
    /// - Returns: The `ItemData` that was converted
    func toItemData() -> ItemData {
        var data = ItemData()
        
        //An array of the details to include
        var details: [String] = []
        if self.rating > 0 {
            details.append("\(self.rating) ★")
        }
        
    
        //Name
        if let media = self.media, let type = media.type {
            switch type {
            case .anime:
                //Make sure we have an anime
                guard let anime = self.anime else {
                    break
                }
                
                data.name = anime.canonicalTitle
                data.posterImage = anime.posterImage
                
                //check if anime is airing
                if anime.isAiring() {
                    details.append("Airing")
                }
                
                break
            case .manga:
                guard let manga = self.manga else {
                    break
                }
                
                data.name = manga.canonicalTitle
                data.posterImage = manga.posterImage
                break
            }
        }
        
        //Combine the details
        let detailString = details.joined(separator: " ᛫ ")
        data.details = detailString.isEmpty ? nil : detailString
       
        //Set the progress count
        let maxCount = self.maxProgress()
        data.countString = maxCount != nil ? "\(self.progress) / \(maxCount!)" : "\(self.progress)"
        
        return data
    }
}

