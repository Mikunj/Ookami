//
//  ItemData+LibraryView.swift
//  Ookami
//
//  Created by Maka on 19/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

extension ItemData {
    
    static func from(entry: LibraryEntry) -> ItemData {
        var data = ItemData()
        
        //An array of the details to include
        var details: [String] = []
        if entry.rating > 0 {
            details.append("\(entry.rating) ★")
        }
        
        
        //Name
        if let media = entry.media, let type = media.type {
            switch type {
            case .anime:
                data.name = entry.anime?.canonicalTitle ?? ""
                data.posterImage = entry.anime?.posterImage
                
                //check if anime is airing
                let airing = entry.anime?.isAiring() ?? false
                if airing {
                    details.append("Airing")
                }
                
            case .manga:
                data.name = entry.manga?.canonicalTitle ?? ""
                data.posterImage = entry.manga?.posterImage
            }
        }
        
        //Combine the details
        let detailString = details.joined(separator: " ᛫ ")
        data.details = detailString.isEmpty ? nil : detailString
        
        //Set the progress count
        var progressString = "\(entry.progress)"
        if let maxCount = entry.maxProgress() {
            progressString.append(" / \(maxCount)")
        }
        data.moreDetails = progressString
        
        return data
    }
    
}
