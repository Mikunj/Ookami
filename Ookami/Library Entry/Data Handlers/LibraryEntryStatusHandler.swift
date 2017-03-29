//
//  LibraryEntryStatusHandler.swift
//  Ookami
//
//  Created by Maka on 29/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import ActionSheetPicker_3_0

class LibraryEntryStatusHandler: LibraryEntryDataHandler {
    
    var heading: LibraryEntryViewData.Heading {
        return .status
    }
    
    func tableData(for entry: LibraryEntry) -> LibraryEntryViewData.TableData {
        var statusValue = "-"
        if let mediaStatus = entry.status, let type = entry.media?.type {
            statusValue = mediaStatus.toString(forMedia: type)
        }
        
        return LibraryEntryViewData.TableData(type: .string, value: statusValue, heading: heading)
    }
    
    //The handling of tap
    func didSelect(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        
        let statuses = LibraryEntry.Status.all
        let rows: [String] = statuses.map {
            if let media = updater.entry.media {
                return $0.toString(forMedia: media.type)
            }
            
            return "-"
        }
        
        let initial = statuses.index(of: updater.entry.status ?? .current) ?? 0
        ActionSheetStringPicker.show(withTitle: "Status", rows: rows, initialSelection: initial, doneBlock: { picker, index, value in
            updater.update(status: statuses[index])
            controller.reloadData()
        }, cancel: { _ in }, origin: cell)
        
    }
}
