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
    var selectedYear: Int {
        didSet {
            yearDataSource?.didSet(year: selectedYear)
        }
    }
    
    fileprivate var yearDataSource: YearTrendingDataSource? {
        return dataSource as? YearTrendingDataSource
    }
    
    //The base title to use E.g "Highest Rated Anime" and the year will be filled in
    var baseTitle: String
    
    /// The min year that user can select from
    var minYear: Int = 1907
    
    /// The max year that the user can pick
    var maxYear: Int = {
        Calendar.current.component(.year, from: Date())
    }()
    
    //The years array that will be displayed in the drop down
    var years: [String] {
        return Array(minYear...maxYear).reversed().map { String($0) }
    }
    
    //Year bar button item to choose the year
    lazy var yearBarButton: UIBarButtonItem = {
        return UIBarButtonItem(withIcon: .calendarIcon, size: CGSize(width: 22, height: 22), target: self, action: #selector(yearTapped))
    }()
    
    /// Make a year trending view controller.
    ///
    /// - Parameters:
    ///   - title: The title of the controller.
    ///   - initialYear: The current selected year. Limitation: 1907 < selectedYear < [Current Year]
    ///   - dataSource: The data source to use
    init(title: String, initialYear: Int, dataSource: YearTrendingDataSource) {
        self.baseTitle = title
        self.selectedYear = initialYear
        
        super.init(dataSource: dataSource)
        set(year: initialYear)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(title:selectedYear:dataSource:) instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = yearBarButton
    }
    
    func set(year: Int) {
        self.selectedYear = year
        updateTitle()
    }
    
    func updateTitle() {
        self.title = baseTitle + " " + selectedYear.description
    }
    
    func yearTapped() {
        let currentIndex = years.index(of: selectedYear.description) ?? 0
        ActionSheetStringPicker.show(withTitle: "Year", rows: years, initialSelection: currentIndex, doneBlock: { picker, index, value in
            if let year = Int(self.years[index]) {
                self.set(year: year)
            }
        }, cancel: nil, origin: yearBarButton)
    }
}
