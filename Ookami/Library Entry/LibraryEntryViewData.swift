//
//  LibraryEntryViewData.swift
//  Ookami
//
//  Created by Maka on 7/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import ActionSheetPicker_3_0

//A class to handle the data in LibraryEntryViewController
class LibraryEntryViewData {
    
    //The updater
    let updater: LibraryEntryUpdater
    
    /// Create a data source for LibraryEntryViewController
    ///
    /// - Parameter entry: The entry to use as the data source
    init(entry: LibraryEntry) {
        self.updater = LibraryEntryUpdater(entry: entry)
    }
    
    //Get the table data
    func tableData() -> [TableData] {
        //Progress
        let entry = updater.entry
        let max = entry.maxProgress()
        let progressValue = max != nil ? "\(entry.progress) of \(max!)" : "\(entry.progress)"
        let progress = TableData(type: .button, value: progressValue, heading: .progress)
        
        //Status
        var statusValue = "-"
        if let mediaStatus = entry.status, let type = entry.media?.type {
            statusValue = mediaStatus.toString(forMedia: type)
        }
        
        let status = TableData(type: .string, value: statusValue, heading: .status)
        
        //Rating
        let ratingString = entry.rating > 0 ? String(entry.rating) : "-"
        let rating = TableData(type: .string, value: ratingString, heading: .rating)
        
        //Notes
        let notes = TableData(type: .string, value: entry.notes, heading: .notes)
        
        //Reconsuming
        let reconsumedString = "\(entry.reconsumeCount) times"
        let reconsumeCount = TableData(type: .button, value: reconsumedString, heading: .reconsumeCount)
        
        
        let reconsuming = TableData(type: .bool, value: entry.reconsuming, heading: .reconsuming)
        
        //Private
        let isPrivate = TableData(type: .bool, value: entry.isPrivate, heading: .isPrivate)
        
        var tableData = [progress, status, rating, notes, reconsumeCount, reconsuming]
        
        //Only add private if entry belongs to current user
        if entry.userID == CurrentUser().userID {
            tableData.append(isPrivate)
        }
        
        return tableData
    }
    
}

//Mark:- TableData
extension LibraryEntryViewData {
    struct TableData {
        var type: CellType
        var value: Any
        var heading: Heading
    }
    
    enum CellType {
        case string
        case bool
        case button
    }
    
    enum Heading: String {
        case progress = "Progress"
        case status = "Status"
        case rating = "Rating"
        case notes = "Notes"
        case reconsumeCount = "Reconsumed"
        case reconsuming = "Reconsuming"
        case isPrivate = "Private"
    }
}
