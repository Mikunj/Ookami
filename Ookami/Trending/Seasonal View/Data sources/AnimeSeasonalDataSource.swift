//
//  AnimeSeasonalDataSource.swift
//  Ookami
//
//  Created by Maka on 10/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class AnimeSeasonalDataSource: AnimeYearTrendingDataSource, SeasonalTrendingDataSource {
    
    //The current season
    var currentSeason: AnimeFilter.Season?
    
    override func paginatedService(_ completion: @escaping () -> Void) -> PaginatedService? {
        guard currentSeason != nil else { return nil }
        
        return super.paginatedService(completion)
    }
    
    //Get the filter with the current year and season applied
    override func filter() -> AnimeFilter {
        let season = currentSeason ?? .spring
        
        let filter = initialFilter.copy()
        filter.filter(key: "season_year", value: currentYear)
        filter.seasons = [season]
        
        return filter
    }
    
    func didSet(season: AnimeFilter.Season) {
        if currentSeason != season {
            currentSeason = season
            updateService()
        }
    }
}
