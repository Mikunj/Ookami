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
        
        let maxYear = Calendar.current.component(.year, from: Date())
        let values = Array(1907...maxYear).map { String($0) }
        
        let filter = SingleValueFilter(name: "Min", title: "Min Year", values: values,
                                       selectedValue: String(mediaFilter.year.start),
                                       onChange: {index, value in
                                        
                                        guard let year = Int(value) else {
                                            return
                                        }
                                        
                                        //We need to make sure that the end year is not less than the year the user selected
                                        if let end = mediaFilter.year.end,
                                            end < year {
                                            mediaFilter.year.end = year
                                        }
                                        
                                        mediaFilter.year.start = year
                                        onComplete()
        })
        
        return filter
    }
    
    private func maxYearFilter(from mediaFilter: MediaFilter, onComplete: @escaping () -> Void) -> Filter {
        
        //Get the upper and lower limits
        let maxYear = Calendar.current.component(.year, from: Date())
        let minYear = mediaFilter.year.start
        
        //We add "∞" because that means to the end of time
        var values = ["∞"]
        let initial = mediaFilter.year.end?.description ?? "∞"
        
        //Add the other years
        let years = Array(minYear...maxYear).reversed()
        values.append(contentsOf: years.map { String($0) })
        
        let filter = SingleValueFilter(name: "Max",
                                       title: "Max Year",
                                       values: values,
                                       selectedValue: initial,
                                       onChange: { index, value in
                                        mediaFilter.year.end = index == 0 ? nil : Int(value)
                                        onComplete()
        })
        
        return filter
    }
    
    
    //MARK:- Score
    
    func scoreFilter(from mediaFilter: MediaFilter, onComplete: @escaping () -> Void) -> FilterGroup {
        let min = minScoreFilter(from: mediaFilter, onComplete: onComplete)
        let max = maxScoreFilter(from: mediaFilter, onComplete: onComplete)
        return FilterGroup(name: "Score", filters: [min, max])
    }
    
    private func minScoreFilter(from mediaFilter: MediaFilter, onComplete: @escaping () -> Void) -> Filter {
        
        //Add 0.5 so it displays that rating
        let ratings = Array(stride(from: 0.5, to: 5.5, by: 0.5))
        let index = ratings.index(of: mediaFilter.rating.start) ?? 0
        
        
        //Format it to 1 decimal place display so it's consitent
        let values = ratings.map { String(format: "%.1f ★", $0) }
        let initial = values[index]
        
        
        let filter = SingleValueFilter(name: "Min",
                                       title: "Min Score",
                                       values: values,
                                       selectedValue: initial,
                                       onChange: { index, value in
                                        
                                        let rating = ratings[index]
                                        
                                        //We need to make sure that the max score is not less than the score the user selected
                                        if let max = mediaFilter.rating.end,
                                            max < rating {
                                            mediaFilter.rating.end = rating
                                        }
                                        
                                        mediaFilter.rating.start = rating
                                        onComplete()
                                        
        })
        
        return filter
        
    }
    
    private func maxScoreFilter(from mediaFilter: MediaFilter, onComplete: @escaping () -> Void) -> Filter {
        
        //With this filter we know 100% that the end rating will never be nil
        let minRating = mediaFilter.rating.start
        
        //Add 0.5 so it displays that rating
        let ratings = Array(stride(from: minRating, to: 5.5, by: 0.5))
        let index = ratings.index(of: mediaFilter.rating.end!) ?? 0
        
        
        //Format it to 1 decimal place display so it's consitent
        let values = ratings.map { String(format: "%.1f ★", $0) }
        let initial = values[index]
        
        
        let filter = SingleValueFilter(name: "Max",
                                       title: "Max Score",
                                       values: values,
                                       selectedValue: initial,
                                       onChange: { index, value in
                                        
                                        //We don't need to check if start is greater than end because we already put that restrictions on the values
                                        let rating = ratings[index]
                                        mediaFilter.rating.end = rating
                                        
                                        onComplete()
                                        
        })
        
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
