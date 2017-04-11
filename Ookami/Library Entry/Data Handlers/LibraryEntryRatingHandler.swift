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
        
        let system = entry.user?.ratingSystem ?? .advanced
        var ratingString = "-"
        
        switch system {
        case .advanced:
            if entry.rating > 0 {
                ratingString = String(Double(entry.rating) / 2)
            }
        case .simple:
            if let simple = entry.simpleRating {
                ratingString = simple.rawValue.capitalized
            }
        case .regular:
            if entry.rating > 0 {
                let rating = Double(entry.rating) / 4
                let rounded = rating.round(nearest: 0.5)
                ratingString = String(rounded)
            }
        }
        
        
        return LibraryEntryViewData.TableData(type: .string, value: ratingString, heading: heading)
    }
    
    //The handling of tap
    func didSelect(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        
        let system = updater.entry.user?.ratingSystem ?? .advanced
        
        switch system {
        case .advanced:
            showAdvancedRating(updater: updater, cell: cell, controller: controller)
        case .simple:
            showSimpleRating(updater: updater, cell: cell, controller: controller)
        case .regular:
            showRegularRating(updater: updater, cell: cell, controller: controller)
        }
        
    }
    
    private func showRegularRating(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        var ratings = Array(stride(from: 0.5, to: 5.5, by: 0.5))
        ratings.insert(0, at: 0)
        
        //We need to take this and round to the nearest 0.5
        //This is because if you do 19 / 4, you get 4.75 which is not present in the system
        //It needs to be rounded down to 4.5
        let quateredRating = Double(updater.entry.rating) / 4
        let rounded = quateredRating.round(nearest: 0.5)
        let initial = ratings.index(of: rounded) ?? 0
        
        //Format it to 2 decimal place display so it's consitent
        let rows = ratings.map { String(format: "%.1f", $0) }
        
        ActionSheetStringPicker.show(withTitle: "Rating", rows: rows, initialSelection: initial, doneBlock: { picker, index, value in
            
            //We need to convert 0.5 - 5 to 2 - 20
            let newRating = Int(ratings[index] * 4)
            updater.update(rating: newRating)
            controller.reloadData()
        }, cancel: { _ in }, origin: cell)
    }
    
    private func showAdvancedRating(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
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
    
    private func showSimpleRating(updater: LibraryEntryUpdater, cell: UITableViewCell, controller: LibraryEntryViewController) {
        
        let ratings = LibraryEntry.SimpleRating.all
        
        //The string representation of the ratings
        var stringRatings = ratings.map { $0.rawValue.capitalized }
        stringRatings.insert("-", at: 0)
        
        //The int representation of the ratings
        var intRatings = ratings.map { $0.toRating() }
        intRatings.insert(0, at: 0)
        
        //Initial rating
        var initial = 0
        if let simple = updater.entry.simpleRating,
            let index = ratings.index(of: simple) {
            initial = index + 1
        }
        
        ActionSheetStringPicker.show(withTitle: "Rating", rows: stringRatings, initialSelection: initial, doneBlock: { picker, index, value in
            let newRating = intRatings[index]
            updater.update(rating: newRating)
            controller.reloadData()
        }, cancel: { _ in }, origin: cell)
        
    }
}
