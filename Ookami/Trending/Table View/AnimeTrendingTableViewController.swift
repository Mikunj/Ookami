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
        
        self.data = [seasonFilter(), highestRatedFilter(), popularityFilter()]
        self.tableView.reloadData()
    }
    
    //MARK:- Highest Rated
    private func highestRatedFilter() -> AnimeTrendingTableDataSource {
        //We need to get current year - 1
        let year = Calendar.current.component(.year, from: Date()) - 1
        let title = "Highest Rated Anime"
        let detail = year.description
        
        let filter = AnimeFilter()
        filter.year.start = year
        filter.year.end = year
        filter.sort = Sort(by: "average_rating")
        
        return AnimeTrendingTableDataSource(title: title, detail: detail, filter: filter, parent: self, delegate: self) { [weak self] in
            let source = AnimeYearTrendingDataSource(filter: filter)
            let yearController = YearTrendingViewController(title: "Highest Rated", currentYear: year, dataSource: source)
            self?.navigationController?.pushViewController(yearController, animated: true)
        }
    }
    
    //MARK:- Popularity
    private func popularityFilter() -> AnimeTrendingTableDataSource {
        //We need to get current year - 1
        let year = Calendar.current.component(.year, from: Date()) - 1
        let title = "Most Popular Anime"
        let detail = year.description
        
        let filter = AnimeFilter()
        filter.year.start = year
        filter.year.end = year
        
        
        return AnimeTrendingTableDataSource(title: title, detail: detail, filter: filter, parent: self, delegate: self) { [weak self] in
            let source = AnimeYearTrendingDataSource(filter: filter)
            let yearController = YearTrendingViewController(title: "Most Popular", currentYear: year, dataSource: source)
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
        
        return AnimeTrendingTableDataSource(title: title, detail: detail, filter: filter, parent: self, delegate: self) {}
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
