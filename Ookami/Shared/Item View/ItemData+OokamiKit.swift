//
//  ItemData+OokamiKit.swift
//  Ookami
//
//  Created by Maka on 9/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

extension Anime: ItemDataTransformable {
    func toItemData() -> ItemData {
        let details = self.isAiring() ? "Airing" : nil
        
        return ItemData(name: self.canonicalTitle, details: details, moreDetails: self.subtype?.rawValue.uppercased(), posterImage: self.posterImage, coverImage: self.coverImage)
    }
}

extension Manga: ItemDataTransformable {
    func toItemData() -> ItemData {
        return ItemData(name: self.canonicalTitle, details: nil, moreDetails: self.subtype?.rawValue.uppercased(), posterImage: self.posterImage, coverImage: self.coverImage)
    }
}

extension LibraryEntry: ItemDataTransformable {
    func toItemData() -> ItemData {
        var data = ItemData()
        
        //An array of the details to include
        var details: [String] = []
        if self.rating > 0 {
            
            let system = self.user?.ratingSystem ?? .advanced
            
            switch system {
            case .advanced:
                let rating = Double(self.rating) / 2
                
                //Display rating as full value or half value
                //This avoids ugly displays like 10.0
                let format = rating.truncatingRemainder(dividingBy: 1.0) == 0.0 ? "%.0f" : "%.1f"
                let ratingString = String(format: format, rating)
                
                details.append("\(ratingString) ★")
            case .simple:
                if let simple = self.simpleRating {
                    details.append(simple.rawValue.capitalized)
                }
                
            case .regular:
                let rating = Double(self.rating) / 4
                let rounded = rating.round(nearest: 0.5)
                
                //Display rating as full value or half value
                //This avoids ugly displays like 5.0
                let format = rounded.truncatingRemainder(dividingBy: 1.0) == 0.0 ? "%.0f" : "%.1f"
                let ratingString = String(format: format, rounded)
                
                details.append("\(ratingString) ★")

            }
        }
        
        
        //Name
        if let media = self.media, let type = media.type {
            switch type {
            case .anime:
                data.name = self.anime?.canonicalTitle ?? ""
                data.posterImage = self.anime?.posterImage
                
                //check if anime is airing
                let airing = self.anime?.isAiring() ?? false
                if airing {
                    details.append("Airing")
                }
                
            case .manga:
                data.name = self.manga?.canonicalTitle ?? ""
                data.posterImage = self.manga?.posterImage
            }
        }
        
        //Combine the details
        let detailString = details.joined(separator: " ᛫ ")
        data.details = detailString.isEmpty ? nil : detailString
        
        //Set the progress count
        var progressString = "\(self.progress)"
        if let maxCount = self.maxProgress() {
            progressString.append(" / \(maxCount)")
        }
        data.moreDetails = progressString
        
        return data

    }
}
