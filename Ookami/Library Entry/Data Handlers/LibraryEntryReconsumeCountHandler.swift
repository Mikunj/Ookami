//
//  LibraryEntryReconsumeCountHandler.swift
//  Ookami
//
//  Created by Maka on 29/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import ActionSheetPicker_3_0

class LibraryEntryReconsumeCountHandler: LibraryEntryDataHandler {
    
    var heading: LibraryEntryViewData.Heading {
        return .reconsumeCount
    }
    
    func tableData(for entry: LibraryEntry) -> LibraryEntryViewData.TableData {
        let reconsumedString = "\(entry.reconsumeCount) times"
        return LibraryEntryViewData.TableData(type: .button, value: reconsumedString, heading: heading)
    }
    
    //The handling of tap
    func didSelect(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        let rows = Array(0...999)
        ActionSheetStringPicker.show(withTitle: "Reconsume Count", rows: rows, initialSelection: updater.entry.reconsumeCount, doneBlock: { picker, index, value in
            if let newValue = value as? Int {
                updater.update(reconsumeCount: newValue)
                controller.reloadData()
            }
        }, cancel: { _ in }, origin: cell)
    }
}

