//
//  AnimeTrendingViewController.swift
//  Ookami
//
//  Created by Maka on 3/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class AnimeTrendingViewController: TrendingViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the data
        let filter = AnimeFilter()
        filter.filter(key: "season_year", value: 2017)
        filter.seasons = [.winter]
        
        let filter2 = AnimeFilter()
        filter2.year.start = 2016
        filter2.year.end = 2016
        
        let testData = AnimeTrendingDataSource(title: "Winter Anime of 2017", filter: filter, parent: self, delegate: self)
        
        let test2Data = AnimeTrendingDataSource(title: "Most Popular Anime of 2016", filter: filter2, parent: self, delegate: self)
        
        self.data = [testData, test2Data]
        self.tableView.reloadData()
    }
}
