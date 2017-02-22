//
//  FilterValueViewController.swift
//  Ookami
//
//  Created by Maka on 22/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Cartography

class FilterValueViewController: UIViewController {
    
    //The table view
    lazy var tableView: UITableView  = {
        let t = UITableView()
        t.delegate = self
        t.dataSource = self
        
        t.tableFooterView = UIView(frame: .zero)
        t.backgroundColor = Theme.ControllerTheme().backgroundColor
        
        return t
    }()
    
    //The values
    var values: [String]
    
    //The values that have been selected
    var selectedValues: [String]
    
    //The block which gets called everytime a selection changes
    var onChange: ([String]) -> Void
    
    /// Create a filter value view which allows selection of multiple values.
    ///
    /// - Parameters:
    ///   - values: The array of values allowed to be selected
    ///   - selectedValues: The initial selected values
    ///   - onSelectionChange: The block which gets called everytime a selection changes, and it passed back the array of selected values
    init(values: [String], selectedValues: [String] = [], onSelectionChange: @escaping ([String]) -> Void) {
        self.values = values
        self.selectedValues = selectedValues
        self.onChange = onSelectionChange
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(values:selectedValues:onSelectionChange:) instead")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(withIcon: .trashIcon, size: CGSize(width: 22, height: 22), target: self, action: #selector(didClear))
    }
    
    func didClear() {
        selectedValues = []
        onChange(selectedValues)
        tableView.reloadData()
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
extension FilterValueViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "FilterValueCell")
        cell.tintColor = Theme.Colors().secondary
        
        let value = values[indexPath.row]
        
        cell.textLabel?.text = value.capitalized
        cell.accessoryType = selectedValues.contains(value) ? .checkmark : .none
        
        return cell
    }
    
}

//MARK:- Delegate
extension FilterValueViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let value = values[indexPath.row]
        
        //Check if we get an index, if not then it's not in the selected values
        if let index = selectedValues.index(of: value) {
            selectedValues.remove(at: index)
        } else {
            selectedValues.append(value)
        }
        
        onChange(selectedValues)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

