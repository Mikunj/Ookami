//
//  MangaTrendingTableViewController.swift
//  Ookami
//
//  Created by Maka on 6/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class MangaTrendingTableViewController: TrendingTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.data = [weeklyTrending(), highestRatedFilter(), popularityFilter()]
        self.tableView.reloadData()
    }
    
    //MARK:- Weekly Trending
    private func weeklyTrending() -> MangaWeeklyTrendingTableDataSource {
        return MangaWeeklyTrendingTableDataSource(title: "Trending", detail: "This Week", parent: self, delegate: self)
    }
    
    //MARK:- Highest Rated
    private func highestRatedFilter() -> MangaTrendingTableDataSource {
        //For Manga since there is no such thing as seasons, we just directly choose the current year
        let year = Calendar.current.component(.year, from: Date())
        let title = "Highest Rated Manga"
        let detail = year.description
        
        let filter = MangaFilter()
        filter.year.start = year
        filter.year.end = year
        filter.sort = Sort(by: "average_rating")
        
        return MangaTrendingTableDataSource(title: title, detail: detail, filter: filter, parent: self, delegate: self) { [weak self] in
            let source = MangaYearTrendingDataSource(filter: filter)
            let yearController = YearTrendingViewController(title: "Highest Rated", initialYear: year, dataSource: source)
            self?.navigationController?.pushViewController(yearController, animated: true)
        }

    }
    
    //MARK:- Popularity
    private func popularityFilter() -> MangaTrendingTableDataSource {
        //For Manga since there is no such thing as seasons, we just directly choose the current year
        let year = Calendar.current.component(.year, from: Date())
        let title = "Most Popular Manga"
        let detail = year.description
        
        let filter = MangaFilter()
        filter.year.start = year
        filter.year.end = year
        
        return MangaTrendingTableDataSource(title: title, detail: detail, filter: filter, parent: self, delegate: self) { [weak self] in
            let source = MangaYearTrendingDataSource(filter: filter.copy())
            let yearController = YearTrendingViewController(title: "Most Popular", initialYear: year, dataSource: source)
            self?.navigationController?.pushViewController(yearController, animated: true)
        }

    }

}
