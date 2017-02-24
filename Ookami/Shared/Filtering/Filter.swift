//
//  Filter.swift
//  Ookami
//
//  Created by Maka on 22/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit

struct FilterGroup {
    var name: String
    var filters: [Filter]
}

//TODO: Make a SingleValueFilter which uses ActionSheetPicker_3.0 for values

//A class to represent a Filter for the View Controller
class Filter {
    //The name of the filter
    let name: String
    
    //The action on tap
    var onTap: (UIViewController, UITableView, UITableViewCell?) -> Void
    
    //The secondary text to show on the cell
    var secondaryText: String = ""
    
    //The accessory of the filter
    var accessory: UITableViewCellAccessoryType = .disclosureIndicator
    
    init(name: String, onTap: @escaping (UIViewController, UITableView, UITableViewCell?) -> Void) {
        self.name = name
        self.onTap = onTap
    }
}

//A filter that enables selecting multiple values
class MultiValueFilter: Filter {
    
    //The values we can accept
    var values: [String]
    
    //The selected values
    var selectedValues: [String]
    
    //Block which gets called everytime the selected values change
    var onChange: ([String]) -> Void
    
    init(name: String, values: [String], selectedValues: [String] = [], onChange: @escaping ([String]) -> Void) {
        self.values = values
        self.selectedValues = selectedValues
        self.onChange = onChange
        super.init(name: name) { _ in }
        updateSecondaryText()
        
        //Hack so that we can use self after init
        self.onTap = { vc, tableView, cell in
            let v = FilterValueViewController(values: self.values, selectedValues: self.selectedValues, onSelectionChange: { selected in
                self.selectedValues = selected
                onChange(self.selectedValues)
                
                self.updateSecondaryText()
                tableView.reloadData()
            })
            vc.navigationController?.pushViewController(v, animated: true)
        }
    }
    
    func updateSecondaryText() {
        let count = selectedValues.count
        if  count == 0 {
            secondaryText = "All"
        } else if count == 1 {
            secondaryText = selectedValues.first!.capitalized
        } else {
            secondaryText = "\(count) selected"
        }
    }
}
