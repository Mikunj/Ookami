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
    private(set) var updater: LibraryEntryUpdater?
    
    /// Create a data source for LibraryEntryViewController
    ///
    /// - Parameter entry: The entry to use as the data source
    init(entry: LibraryEntry) {
        self.updater = LibraryEntryUpdater(entry: entry)
        NotificationCenter.default.addObserver(self, selector: #selector(didDeleteEntry(notification:)), name: LibraryService.Notifications.deletedEntry.name, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Check if entry was deleted, if so then invalidate the updater
    @objc func didDeleteEntry(notification: Notification) {
        guard let entry = updater?.entry else {
            return
        }
        
        //Check if the entry that changed was for this entry data
        if let info = notification.userInfo,
            let id = info["id"] as? Int,
            id == entry.id {
            updater = nil
        }
    }
    
    //Check whether the entry was invalidated by realm (this can happen if it gets deleted while we still have it)
    func isInvalid() -> Bool {
        return updater == nil || updater!.entry.isInvalidated
    }
    
    //Get the table data
    func tableData() -> [TableData] {
        //Progress
        guard let entry = updater?.entry else {
            return []
        }
        
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
        let ratingString = entry.rating > 0 ? String(Double(entry.rating) / 2) : "-"
        let rating = TableData(type: .string, value: ratingString, heading: .rating)
        
        //Notes
        let notes = TableData(type: .string, value: entry.notes, heading: .notes)
        
        //Reconsuming
        let reconsumedString = "\(entry.reconsumeCount) times"
        let reconsumeCount = TableData(type: .button, value: reconsumedString, heading: .reconsumeCount)
        
        
        let reconsuming = TableData(type: .bool, value: entry.reconsuming, heading: .reconsuming)
        
        //Private
        let isPrivate = TableData(type: .bool, value: entry.isPrivate, heading: .isPrivate)
        
        let delete = TableData(type: .delete, value: "Delete library entry", heading: .delete)
        
        var tableData = [progress, status, rating, notes, reconsumeCount, reconsuming]
        
        //Only add private if entry belongs to current user
        if entry.userID == CurrentUser().userID {
            tableData.append(isPrivate)
        }
        
        //Add the delete at the very end
        tableData.append(delete)
        
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
        case delete
    }
    
    enum Heading: String {
        case delete = "Delete"
        case progress = "Progress"
        case status = "Status"
        case rating = "Rating"
        case notes = "Notes"
        case reconsumeCount = "Reconsumed"
        case reconsuming = "Reconsuming"
        case isPrivate = "Private"
    }
}
