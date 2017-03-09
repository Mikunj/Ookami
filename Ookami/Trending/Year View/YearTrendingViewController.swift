//
//  YearTrendingViewController.swift
//  Ookami
//
//  Created by Maka on 6/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import Cartography
import ActionSheetPicker_3_0

protocol YearTrendingDataSource: PaginatedTrendingDataSource {
    func didSet(year: Int)
}

//A view controller which displays yearly trending media
//The user can then pick a year and the results will change
//Basically an ItemViewController with a year picker
class YearTrendingViewController: PaginatedTrendingViewController {
    
    /// The current year
    var currentYear: Int {
        didSet {
            yearDataSource?.didSet(year: currentYear)
        }
    }
    
    var yearDataSource: YearTrendingDataSource? {
        return dataSource as? YearTrendingDataSource
    }
    
    //The base title to use E.g "Highest Rated Anime" and the year will be filled in
    var baseTitle: String
    
    /// The min year that user can select from
    var minYear: Int
    
    /// The max year that the user can pick
    var maxYear: Int
    
    //The years array that will be displayed in the drop down
    fileprivate var years: [String]
    
    //Year bar button item to choose the year
    fileprivate lazy var yearBarButton: UIBarButtonItem = {
        return UIBarButtonItem(withIcon: .calendarIcon, size: CGSize(width: 22, height: 22), target: self, action: #selector(yearTapped))
    }()
    
    /// Make a year trending view controller.
    ///
    /// - Parameters:
    ///   - title: The title of the controller.
    ///   - minYear: The mininum year the user can pick.
    ///   - maxYear: The maximum year the user can pick. If set to -1, then the maximum will be the current year.
    ///   - dataSource: The data source to use
    init(title: String, currentYear: Int, minYear: Int = 1907, maxYear: Int = -1, dataSource: YearTrendingDataSource) {
        self.baseTitle = title
        self.currentYear = currentYear
        
        let currentMax = maxYear >= 0 ? maxYear : Calendar.current.component(.year, from: Date())
        
        //Make sure we have the right values
        assert(minYear <= currentMax, "Min year should be less than or equal to Max year")
        self.minYear = minYear
        self.maxYear = currentMax
        self.years = Array(minYear...currentMax).reversed().map { String($0) }
        
        super.init(dataSource: dataSource)
        set(year: currentYear)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(title:currentYear:minYear:maxYear:dataSource:) instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = yearBarButton
    }
    
    func set(year: Int) {
        self.title = baseTitle + " " + year.description
        self.currentYear = year
    }
    
    func yearTapped() {
        let currentIndex = years.index(of: currentYear.description) ?? 0
        ActionSheetStringPicker.show(withTitle: "Year", rows: years, initialSelection: currentIndex, doneBlock: { picker, index, value in
            if let year = Int(self.years[index]) {
                self.set(year: year)
            }
        }, cancel: nil, origin: yearBarButton)
    }
}
