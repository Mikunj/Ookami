//
//  LibraryEntryFinishedAtHandler.swift
//  Ookami
//
//  Created by Maka on 26/6/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import ActionSheetPicker_3_0

class LibraryEntryFinishedAtHandler: LibraryEntryDataHandler {
    
    var heading: LibraryEntryViewData.Heading {
        return .finishedAt
    }
    
    //The table data
    func tableData(for entry: LibraryEntry) -> LibraryEntryViewData.TableData {
        
        //Format the date to dd/MM/YYYY
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        var date = "-"
        if let finish = entry.finishedAt {
            date = formatter.string(from: finish)
        }
        
        
        return LibraryEntryViewData.TableData(type: .string, value: date, heading: heading)
    }
    
    //The handling of tap
    func didSelect(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        
        let selected = updater.entry.finishedAt ?? Date()
        
        let picker = ActionSheetDatePicker(title: "Finished At:", datePickerMode: .date, selectedDate: selected, doneBlock: { _, value, _ in
            updater.update(finishedAt: value as? Date)
            controller.reloadData()
        }, cancel: { _ in }, origin: cell)

        picker?.minimumDate = Date(timeIntervalSince1970: 0)
        if let start = updater.entry.startedAt {
            picker?.minimumDate = start
        }
        
        picker?.maximumDate = Date()
        picker?.timeZone = TimeZone(abbreviation: "UTC")
        picker?.show()
    }
}
