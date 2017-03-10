//
//  SeasonalTrendingViewController.swift
//  Ookami
//
//  Created by Maka on 10/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import OokamiKit

protocol SeasonalTrendingDataSource: YearTrendingDataSource {
    func didSet(season: AnimeFilter.Season)
}

//A View controller which presents seasonal data
//Subclasses from `YearTrendingViewController` because we also associate a year with the season
class SeasonalTrendingViewController: YearTrendingViewController {
    
    //The data source converted
    fileprivate var seasonalDataSource: SeasonalTrendingDataSource? {
        return dataSource as? SeasonalTrendingDataSource
    }
    
    //The selected season
    var selectedSeason: AnimeFilter.Season {
        didSet {
            seasonalDataSource?.didSet(season: selectedSeason)
        }
    }
    
    /// Make a seasonal trending view controller.
    ///
    /// - Parameters:
    ///   - initialSeason: The initial season.
    ///   - initialYear: The initial year. Limitation: 1907 < selectedYear < [Current Year]
    ///   - dataSource: The data source to use
    init(initialSeason: AnimeFilter.Season, initialYear: Int, dataSource: SeasonalTrendingDataSource) {
        self.selectedSeason = initialSeason
        super.init(title: "", initialYear: initialYear, dataSource: dataSource)
        
        set(season: initialSeason)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(season: AnimeFilter.Season) {
        self.selectedSeason = season
        updateTitle()
    }
    
    override func updateTitle() {
        let season = selectedSeason.rawValue.capitalized
        let year = selectedYear.description
        self.title = season + " " + year
    }
    
    override func yearTapped() {
        
        let seasons = AnimeFilter.Season.all.map { $0.rawValue.capitalized }
        let currentSeasonIndex = AnimeFilter.Season.all.index(of: selectedSeason) ?? 0
        
        let currentYearIndex = years.index(of: selectedYear.description) ?? 0
        
        ActionSheetMultipleStringPicker.show(withTitle: "Season", rows: [seasons, years], initialSelection: [currentSeasonIndex, currentYearIndex], doneBlock: { picker, indexes, values in
            
            guard let indexes = indexes as? [Int] else { return }
            
            let season = AnimeFilter.Season.all[indexes[0]]
            self.set(season: season)
            
            if let year = Int(self.years[indexes[1]]) {
                self.set(year: year)
            }
        }, cancel: nil, origin: yearBarButton)
    }
    
}
