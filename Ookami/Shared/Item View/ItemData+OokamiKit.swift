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
            let rating = Double(self.rating) / 2
            details.append("\(rating) ★")
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
