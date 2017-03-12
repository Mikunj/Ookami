//
//  LibraryFilterViewController.swift
//  Ookami
//
//  Created by Maka on 12/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import Cartography

class LibraryFilterViewController: UIViewController {
    
    //The filter view
    var filterView: FilterViewController
    
    //The modified sort
    var sort: LibraryViewController.Sort
    
    //The save closure
    var onSave: (LibraryViewController.Sort) -> Void
    
    /// Create a library filter view
    ///
    /// - Parameters:
    ///   - sort: The initial sort state of the view
    ///   - onSave: The closure which gets called when save was tapped. A new sort object is passed back.
    init(sort: LibraryViewController.Sort, onSave: @escaping (LibraryViewController.Sort) -> Void) {
        filterView = FilterViewController(filters: [])
        self.sort = sort
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
        self.reload()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init() instead.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Theme.ControllerTheme().backgroundColor
        
        //Add the filter view
        self.addChildViewController(filterView)
        self.view.addSubview(filterView.view)
        
        constrain(filterView.view) { view in
            view.edges == view.superview!.edges
        }
        
        filterView.didMove(toParentViewController: self)
        
        //Add the save and cancel buttons
        let cancelImage = UIImage(named: "Close")
        let cancel = UIBarButtonItem(image: cancelImage, style: .done, target: self, action: #selector(didCancel))
        
        let saveImage = UIImage(named: "Check")
        let save = UIBarButtonItem(image: saveImage, style: .done, target: self, action: #selector(didSave))
        
        self.navigationItem.leftBarButtonItem = cancel
        self.navigationItem.rightBarButtonItem = save
    }
    
    func didCancel() {
        dismiss(animated: true)
    }
    
    func didSave() {
        dismiss(animated: true) {
            self.onSave(self.sort)
        }
    }
    
    func reload() {
        filterView.filters = filters()
    }
    
    func filters() -> [FilterGroup] {
        return [FilterGroup(name: "", filters: [typeFilter(), directionFilter()])]
    }
    
    private func typeFilter() -> Filter {
        
        let sorts: [LibraryViewController.Sort.SortType] = [.updatedAt, .title, .progress, .rating]
        let values = sorts.map { $0.rawValue.capitalized }
        let selected = values[sorts.index(of: sort.type) ?? 0]
        
        return SingleValueFilter(name: "Sort By", title: "Sort By", values: values, selectedValue: selected) { index, value in
            self.sort.type = sorts[index]
            self.reload()
        }
    }
    
    private func directionFilter() -> Filter {
        let directions: [LibraryViewController.Sort.Direction] = [.ascending, .descending]
        let values = directions.map { $0.rawValue.capitalized }
        let selected = values[directions.index(of: sort.direction) ?? 0]
        
        return SingleValueFilter(name: "Direction", title: "Direction", values: values, selectedValue: selected) { index, value in
            self.sort.direction = directions[index]
            self.reload()
        }
    }
}

