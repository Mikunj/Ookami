//
//  FilterViewController.swift
//  Ookami
//
//  Created by Maka on 22/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Cartography

//A Class for representing a filterable view
class FilterViewController: UIViewController {
    
    //The table view
    lazy var tableView: UITableView  = {
        let t = UITableView()
        
        t.delegate = self
        t.dataSource = self
        
        t.tableFooterView = UIView(frame: .zero)
        t.backgroundColor = Theme.ControllerTheme().backgroundColor
        
        return t
    }()
    
    //The filters we want to show
    var filters: [Filter]
    
    /// Create a filter view controller.
    ///
    /// - Parameter filters: The filters that can be set
    init(filters: [Filter] = []) {
        self.filters = filters
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(filters:) instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the tableview
        self.view.addSubview(tableView)
        constrain(tableView) { view in
            view.edges == view.superview!.edges
        }
    }
}

//MARK:- Data source
extension FilterViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "FilterValueCell")
        cell.tintColor = Theme.Colors().secondary
        
        let filter = filters[indexPath.row]
        cell.textLabel?.text = filter.name.capitalized
        cell.detailTextLabel?.text = filter.secondaryText
        cell.accessoryType = filter.accessory
        
        return cell
    }
}

//MARK:- Delegate
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let filter = filters[indexPath.row]
        filter.onTap(self, tableView, tableView.cellForRow(at: indexPath))
    }
}
