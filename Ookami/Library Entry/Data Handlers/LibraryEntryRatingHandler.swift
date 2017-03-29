//
//  LibraryEntryRatingHandler.swift
//  Ookami
//
//  Created by Maka on 29/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import ActionSheetPicker_3_0

class LibraryEntryRatingHandler: LibraryEntryDataHandler {
    
    var heading: LibraryEntryViewData.Heading {
        return .rating
    }
    
    func tableData(for entry: LibraryEntry) -> LibraryEntryViewData.TableData {
        let ratingString = entry.rating > 0 ? String(Double(entry.rating) / 2) : "-"
        return LibraryEntryViewData.TableData(type: .string, value: ratingString, heading: heading)
    }
    
    //The handling of tap
    func didSelect(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        
        var ratings = Array(stride(from: 1.0, to: 10.5, by: 0.5))
        ratings.insert(0, at: 0)
        
        let halvedRating = Double(updater.entry.rating) / 2
        let initial = ratings.index(of: halvedRating) ?? 0
        
        //Format it to 1 decimal place display so it's consitent
        let rows = ratings.map { String(format: "%.1f", $0) }
        
        ActionSheetStringPicker.show(withTitle: "Rating", rows: rows, initialSelection: initial, doneBlock: { picker, index, value in
            
            //We need to convert 1 - 10 to 2 - 20
            let newRating = Int(ratings[index] * 2)
            updater.update(rating: newRating)
            controller.reloadData()
        }, cancel: { _ in }, origin: cell)
        
    }
}
