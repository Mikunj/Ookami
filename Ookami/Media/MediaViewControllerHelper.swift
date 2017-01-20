//
//  MediaViewControllerHelper.swift
//  Ookami
//
//  Created by Maka on 20/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit
import RealmSwift
import SKPhotoBrowser

//Class with methods that all MediaViewControllers will use
class MediaViewControllerHelper {
    
    //MARK:- Titles
    static func getTitleSection(for mediaTitles: List<MediaTitle>) -> MediaViewControllerSection? {
        let titles = getTitles(from: mediaTitles)
        if titles.isEmpty {
            return nil
        }
        
        return getSectionWithMediaInfoCell(title: "Alternate Titles", info: titles)
    }
    
    private static func getTitles(from mediaTitles: List<MediaTitle>) -> [(String, String)] {
        let titles = mediaTitles.sorted(byProperty: "key")
        let info: [(String, String)] = titles.flatMap { title in
            if let titleString = title.languageKey?.toString().capitalized, !title.value.isEmpty {
                return (titleString, title.value)
            }
            return nil
        }
        
        return info
    }
    
    
    //MARK:- Info
    static func getSectionWithMediaInfoCell(title: String, info: [(String, String)]) -> MediaViewControllerSection {
        var section = MediaViewControllerSection(title: title, cellCount: info.count)
        section.cellForIndexPath = { indexPath, tableView in
            let cell = tableView.dequeueReusableCell(for: indexPath) as MediaInfoTableViewCell
            
            let (title, value) = info[indexPath.row]
            cell.infoTitleLabel.text = title
            cell.infoLabel.text = value
            
            return cell
        }
        section.estimatedHeightForRow = { _ in return 20 }
        return section
    }
    
    //Get date range text from 2 dates
    //Format: [start] to [end]
    static func dateRangeText(start: Date?, end: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        
        var startDate = "?"
        if let date = start {
            startDate = formatter.string(from: date)
        }
        
        var endDate: String = "?"
        if let date = end {
            endDate = formatter.string(from: date)
        }
        
        return "\(startDate) to \(endDate)"
    }
    
    //Get a synopsis section
    static func getSynopsisSection(synopsis data: String) -> MediaViewControllerSection {
        var synopsis = MediaViewControllerSection(title: "Synopsis", cellCount: 1)
        synopsis.cellForIndexPath = { indexPath, tableView in
            let cell = tableView.dequeueReusableCell(for: indexPath) as MediaTextTableViewCell
            
            cell.isUserInteractionEnabled = false
            cell.simpleTextLabel.text = data
            return cell
        }
        
        return synopsis
    }
    
    static func tappedImageView(_ imageView: UIImageView, in vc: UIViewController) {
        if let image = imageView.image {
            SKPhotoBrowserOptions.displayStatusbar = false
            let photo = SKPhotoBrowser(originImage: image, photos: [SKPhoto.photoWithImage(image)], animatedFromView: imageView)
            vc.present(photo, animated: true)
        }
    }
    
}
