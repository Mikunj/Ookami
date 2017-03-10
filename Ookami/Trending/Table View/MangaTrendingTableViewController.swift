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
        
        self.data = [highestRatedFilter(), popularityFilter()]
        self.tableView.reloadData()
    }
    
    //MARK:- Highest Rated
    private func highestRatedFilter() -> MangaTrendingTableDataSource {
        //We need to get current year - 1
        let year = Calendar.current.component(.year, from: Date()) - 1
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
        //We need to get current year - 1
        let year = Calendar.current.component(.year, from: Date()) - 1
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
