//
//  DiscoverFilterHelper.swift
//  Ookami
//
//  Created by Maka on 23/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import ActionSheetPicker_3_0

//A Helper class that provides basic filters for MediaFilter
class DiscoverFilterHelper {
    
    //MARK:- Year
    func yearFilter(from mediaFilter: MediaFilter, onComplete: @escaping () -> Void) -> FilterGroup {
        let min = minYearFilter(from: mediaFilter, onComplete: onComplete)
        let max = maxYearFilter(from: mediaFilter, onComplete: onComplete)
        return FilterGroup(name: "Year", filters: [min, max])
    }
    
    private func minYearFilter(from mediaFilter: MediaFilter, onComplete: @escaping () -> Void) -> Filter {
        let filter = Filter(name: "Min") { vc, tableView, cell in
            guard let cell = cell else {
                return
            }
            
            let maxYear = Calendar.current.component(.year, from: Date())
            let rows = Array(1907...maxYear)
            let initial = rows.index(of: mediaFilter.year.start) ?? 0
            ActionSheetStringPicker.show(withTitle: "Min Year", rows: rows, initialSelection: initial, doneBlock: { picker, index, value in
                
                let year = rows[index]
                
                //We need to make sure that the end year is not less than the year the user selected
                if let end = mediaFilter.year.end,
                    end < year {
                    mediaFilter.year.end = year
                }
                
                mediaFilter.year.start = year
                onComplete()
            }, cancel: { _ in
            }, origin: cell)
        }
        
        filter.secondaryText = "\(mediaFilter.year.start)"
        filter.accessory = .none
        
        return filter
    }
    
    private func maxYearFilter(from mediaFilter: MediaFilter, onComplete: @escaping () -> Void) -> Filter {
        let text = mediaFilter.year.end != nil ? "\(mediaFilter.year.end!)" : "∞"
        
        let filter = Filter(name: "Max") { vc, tableView, cell in
            guard let cell = cell else {
                return
            }
            
            let maxYear = Calendar.current.component(.year, from: Date())
            let minYear = mediaFilter.year.start
            
            //We add "∞" because that means to the end of time
            var rows = ["∞"]
            let years = Array(minYear...maxYear).reversed()
            rows.append(contentsOf: years.map { String($0) })
            
            //Get the initial, if we don't have the end that the initial value is inifinty
            let initial = rows.index(of: text) ?? 0
            
            ActionSheetStringPicker.show(withTitle: "Max Year", rows: rows, initialSelection: initial, doneBlock: { picker, index, value in
                
                //We don't need to check if start is greater than end because we already put that restrictions on the values
                
                let year = rows[index]
                mediaFilter.year.end = index == 0 ? nil : Int(year)
                
                onComplete()
            }, cancel: { _ in
            }, origin: cell)
        }
        
        filter.secondaryText = text
        filter.accessory = .none
        
        return filter
    }
    
    
    //MARK:- Score
    
    func scoreFilter(from mediaFilter: MediaFilter, onComplete: @escaping () -> Void) -> FilterGroup {
        let min = minScoreFilter(from: mediaFilter, onComplete: onComplete)
        let max = maxScoreFilter(from: mediaFilter, onComplete: onComplete)
        return FilterGroup(name: "Score", filters: [min, max])
    }
    
    private func minScoreFilter(from mediaFilter: MediaFilter, onComplete: @escaping () -> Void) -> Filter {
        let filter = Filter(name: "Min") { vc, tableView, cell in
            guard let cell = cell else {
                return
            }
            
            //Add 0.5 so it displays that rating
            let ratings = Array(stride(from: 0.5, to: 5.5, by: 0.5))
            let initial = ratings.index(of: mediaFilter.rating.start) ?? 0
            
            //Format it to 1 decimal place display so it's consitent
            let rows = ratings.map { String(format: "%.1f", $0) }
            
            ActionSheetStringPicker.show(withTitle: "Min Score", rows: rows, initialSelection: initial, doneBlock: { picker, index, value in
                
                let rating = ratings[index]
                
                //We need to make sure that the max score is not less than the score the user selected
                if let max = mediaFilter.rating.end,
                    max < rating {
                    mediaFilter.rating.end = rating
                }
                
                mediaFilter.rating.start = rating
                onComplete()
            }, cancel: { _ in
            }, origin: cell)
        }
        
        filter.secondaryText = "\(mediaFilter.rating.start) ★"
        filter.accessory = .none
        
        return filter

    }
    
    private func maxScoreFilter(from mediaFilter: MediaFilter, onComplete: @escaping () -> Void) -> Filter {
        let filter = Filter(name: "Max") { vc, tableView, cell in
            guard let cell = cell else {
                return
            }
            
            //With this filter we know 100% that the end rating will never be nil
            let minRating = mediaFilter.rating.start
            
            let ratings = Array(stride(from: minRating, to: 5.5, by: 0.5))
            let initial = ratings.index(of: mediaFilter.rating.end!) ?? 0
            
            //Format it to 1 decimal place display so it's consitent
            let rows = ratings.map { String(format: "%.1f", $0) }
            
            ActionSheetStringPicker.show(withTitle: "Max Score", rows: rows, initialSelection: initial, doneBlock: { picker, index, value in
                
                //We don't need to check if start is greater than end because we already put that restrictions on the values
                let rating = ratings[index]
                mediaFilter.rating.end = rating
                
                onComplete()
            }, cancel: { _ in
            }, origin: cell)
        }
        
        filter.secondaryText = "\(mediaFilter.rating.end!) ★"
        filter.accessory = .none
        
        return filter
    }
    
    func genreFilter(from mediaFilter: MediaFilter) -> Filter {
        let genres = Array(Genre.all().sorted(byKeyPath: "name").map { $0.name })
        return MultiValueFilter(name: "Genres",
                                values: genres,
                                selectedValues: mediaFilter.genres,
                                onChange: { selected in
                                    let selectedGenres = selected.flatMap {
                                        return Genre.get(withName: $0)
                                    }
                                    mediaFilter.filter(genres: selectedGenres)
        })
    }
    
}
