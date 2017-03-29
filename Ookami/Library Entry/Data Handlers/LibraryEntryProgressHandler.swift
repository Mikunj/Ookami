//
//  LibraryEntryProgressHandler.swift
//  Ookami
//
//  Created by Maka on 29/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import ActionSheetPicker_3_0

class LibraryEntryProgressHandler: LibraryEntryDataHandler {
    
    var heading: LibraryEntryViewData.Heading {
        return .progress
    }
    
    func tableData(for entry: LibraryEntry) -> LibraryEntryViewData.TableData {
        
        let max = entry.maxProgress()
        let progressValue = max != nil ? "\(entry.progress) of \(max!)" : "\(entry.progress)"
        
        return LibraryEntryViewData.TableData(type: .button, value: progressValue, heading: heading)
    }
    
    //The handling of tap
    func didSelect(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        
        let max = updater.entry.maxProgress() ?? 999
        let rows = Array(0...max)
        ActionSheetStringPicker.show(withTitle: "Progress", rows: rows, initialSelection: updater.entry.progress, doneBlock: { picker, index, value in
            if let newValue = value as? Int {
                updater.update(progress: newValue)
                controller.reloadData()
            }
        }, cancel: { _ in }, origin: cell)
        
    }
}
