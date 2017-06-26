//
//  AnimeTrendingTableViewController.swift
//  Ookami
//
//  Created by Maka on 3/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class AnimeTrendingTableViewController: TrendingTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.data = [weeklyTrending(), seasonFilter(), highestRatedFilter(), popularityFilter()]
        self.tableView.reloadData()
    }
    
    //MARK:- Weekly Trending
    private func weeklyTrending() -> AnimeWeeklyTrendingTableDataSource {
        return AnimeWeeklyTrendingTableDataSource(title: "Trending", detail: "This Week", parent: self, delegate: self)
    }
    
    //MARK:- Highest Rated
    private func highestRatedFilter() -> AnimeTrendingTableDataSource {
        //For trending, we don't want users always to be viewing the previous years media, for that purpose we only show the previous years results during the first season and then revert to current year for the rest of the seasons.
        let year = Calendar.current.component(.year, from: Date())
        let filterYear = currentSeason() == .winter ? year - 1 : year
        
        let title = "Highest Rated Anime"
        let detail = filterYear.description
        
        let filter = AnimeFilter()
        filter.year.start = filterYear
        filter.year.end = filterYear
        filter.sort = Sort(by: "average_rating")
        
        return AnimeTrendingTableDataSource(title: title, detail: detail, filter: filter, parent: self, delegate: self) { [weak self] in
            let source = AnimeYearTrendingDataSource(filter: filter)
            let yearController = YearTrendingViewController(title: "Highest Rated", initialYear: year, dataSource: source)
            self?.navigationController?.pushViewController(yearController, animated: true)
        }
    }
    
    //MARK:- Popularity
    private func popularityFilter() -> AnimeTrendingTableDataSource {
        //For trending, we don't want users always to be viewing the previous years media, for that purpose we only show the previous years results during the first season and then revert to current year for the rest of the seasons.
        let year = Calendar.current.component(.year, from: Date())
        let filterYear = currentSeason() == .winter ? year - 1 : year
        
        let title = "Most Popular Anime"
        let detail = filterYear.description
        
        let filter = AnimeFilter()
        filter.year.start = filterYear
        filter.year.end = filterYear
        
        
        return AnimeTrendingTableDataSource(title: title, detail: detail, filter: filter, parent: self, delegate: self) { [weak self] in
            let source = AnimeYearTrendingDataSource(filter: filter)
            let yearController = YearTrendingViewController(title: "Most Popular", initialYear: year, dataSource: source)
            self?.navigationController?.pushViewController(yearController, animated: true)
        }

    }
    
    //MARK:- Season
    private func seasonFilter() -> AnimeTrendingTableDataSource {
        let year = Calendar.current.component(.year, from: Date())
        let season = currentSeason()
        
        let title = "Seasonal Anime"
        let detail = "\(season.rawValue.capitalized) \(year)"
        
        let filter = AnimeFilter()
        filter.filter(key: "season_year", value: year)
        filter.seasons = [season]
        
        return AnimeTrendingTableDataSource(title: title, detail: detail, filter: filter, parent: self, delegate: self) { [weak self] in
            let source = AnimeSeasonalDataSource(filter: filter)
            let seasonController = SeasonalTrendingViewController(initialSeason: season, initialYear: year, dataSource: source)
            self?.navigationController?.pushViewController(seasonController, animated: true)
        }
    }
    
    private func currentSeason() -> AnimeFilter.Season {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 1...3:
            return .winter
        case 4...6:
            return .spring
        case 7...9:
            return .summer
        default:
            return .fall
        }
    }
}
