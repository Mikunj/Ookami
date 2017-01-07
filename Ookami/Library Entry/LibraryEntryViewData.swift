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
struct LibraryEntryViewData {
    
    //The entry we are viewing
    let entry: LibraryEntry
    
    //The unmanaged entry
    var unmanaged: LibraryEntry
    
    
    /// Create a data source for LibraryEntryViewController
    ///
    /// - Parameter entry: The entry to use as the data source
    init(entry: LibraryEntry) {
        self.entry = entry
        self.unmanaged = LibraryEntry(value: entry)
    }
    
    //Get the table data
    func tableData() -> [TableData] {
        //Progress
        let max = unmanaged.maxProgress()
        let progressValue = max != nil ? "\(unmanaged.progress) of \(max!)" : "\(unmanaged.progress)"
        let progress = TableData(type: .button, value: progressValue, heading: .progress)
        
        //Status
        var statusValue = "-"
        if let mediaStatus = unmanaged.status, let type = unmanaged.media?.type {
            statusValue = mediaStatus.toString(forMedia: type)
        }
        
        let status = TableData(type: .string, value: statusValue, heading: .status)
        
        //Rating
        let ratingString = unmanaged.rating > 0 ? String(unmanaged.rating) : "-"
        let rating = TableData(type: .string, value: ratingString, heading: .rating)
        
        //Notes
        let notes = TableData(type: .string, value: unmanaged.notes, heading: .notes)
        
        //Reconsuming
        let reconsumedString = "\(unmanaged.reconsumeCount) times"
        let reconsumeCount = TableData(type: .button, value: reconsumedString, heading: .reconsumeCount)
        
        
        let reconsuming = TableData(type: .bool, value: unmanaged.reconsuming, heading: .reconsuming)
        
        //Private
        let isPrivate = TableData(type: .bool, value: unmanaged.isPrivate, heading: .isPrivate)
        
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

//Mark:- Updating
extension LibraryEntryViewData {
    //Update the progress on the unmanaged entry
    func update(progress: Int) {
        if let maxProgress = unmanaged.maxProgress() {
            unmanaged.progress = min(maxProgress, max(progress, 0))
        } else {
            unmanaged.progress = progress
        }
    }
    
    //Update the status
    func update(status: LibraryEntry.Status) {
        unmanaged.status = status
        
        //Check for completed
        if status == .completed {
            //If we completed the show then set the progress to max
            if let max = unmanaged.maxProgress() {
                update(progress: max)
            }
            
            //We need to update the reconsume count aswell if we were reconsuming
            if unmanaged.reconsuming {
                update(reconsumeCount: unmanaged.reconsumeCount + 1)
                update(reconsuming: false)
            }
            
        }
    }
    
    //Update rating
    func update(rating: Double) {
        //Only allow ratings from 0 - 5.0 and in 0.5 increments
        let ratings = Array(stride(from: 0, to: 5.5, by: 0.5))
        if ratings.contains(rating) {
            unmanaged.rating = rating
        }
    }
    
    func update(notes: String) {
        unmanaged.notes = notes
    }
    
    //update reconsuming
    func update(reconsuming: Bool) {
        unmanaged.reconsuming = reconsuming
        
        //If we are reconsuming and the status is completed then set the progress to 0, and set it to current
        //We only do this on completed as the user may have not marked media as reconsuming when it's in a different status.
        if reconsuming, unmanaged.status == .completed {
            update(progress: 0)
            update(status: .current)
        }
    }
    
    //Update the reconsume count
    func update(reconsumeCount: Int) {
        unmanaged.reconsumeCount = reconsumeCount
    }
    
    func update(isPrivate: Bool) {
        unmanaged.isPrivate = isPrivate
    }
}
