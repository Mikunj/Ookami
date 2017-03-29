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
    
    //The handlers
    var dataHandlers: [LibraryEntryDataHandler] = {
        return [LibraryEntryProgressHandler(),
                LibraryEntryStatusHandler(),
                LibraryEntryRatingHandler(),
                LibraryEntryNotesHandler(),
                LibraryEntryReconsumeCountHandler(),
                LibraryEntryReconsumingHandler(),
                LibraryEntryPrivateHandler(),
                LibraryEntryDeleteHandler()]
    }()
    
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
        
        //Filter out the private handler if we are not the current user
        let handlers = dataHandlers.filter { handler in
            if entry.userID == CurrentUser().userID {
                return true
            }
            
            return handler.heading != .isPrivate
        }
        
        return handlers.map { $0.tableData(for: entry) }
    }
    
    //MARK:- On Select
    func didSelect(heading: Heading, cell: UITableViewCell, controller: LibraryEntryViewController) {
        guard let updater = updater else { return }
        
        for handler in dataHandlers {
            if handler.heading == heading {
                handler.didSelect(updater: updater, cell: cell, controller: controller)
                return
            }
        }
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
