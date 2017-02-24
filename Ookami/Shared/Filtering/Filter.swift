//
//  Filter.swift
//  Ookami
//
//  Created by Maka on 22/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

struct FilterGroup {
    var name: String
    var filters: [Filter]
}

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

//A filter that enables selecting 1 single value
class SingleValueFilter: Filter {

    //The values we can select
    var values: [String]
    
    //The current selected value
    var selectedValue: String
    
    //The block which gets called when selected value changes. It passes back the index and the selected value.
    var onChange: (Int, String) -> Void
    
    /// Create a single value filter
    ///
    /// - Parameters:
    ///   - name: The name which is shown on the filter cell
    ///   - title: The title that is shown on the picker control
    ///   - values: The values that can be selected
    ///   - selectedValue: The current selected value
    ///   - onChange: The block which gets called upon selection change
    init(name: String, title: String, values: [String], selectedValue: String, onChange: @escaping (Int, String) -> Void) {
        self.values = values
        self.selectedValue = selectedValue
        self.onChange = onChange
        super.init(name: name) { _ in }
        
        //Set the secondary text
        secondaryText = selectedValue
        accessory = .none
        
        //Hack so that we can use self after init
        self.onTap = { vc, tableView, cell in
            
            guard let cell = cell else {
                return
            }
            
            let initial = values.index(of: selectedValue) ?? 0
            ActionSheetStringPicker.show(withTitle: title,
                                         rows: values,
                                         initialSelection: initial,
                                         doneBlock: { picker, index, value in
                                            self.selectedValue = values[index]
                                            self.secondaryText = self.selectedValue
                                            tableView.reloadData()
                                            
                                            self.onChange(index, self.selectedValue)
                                            
            }, cancel: { _ in },
               origin: cell)
            
        }
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
                self.updateSecondaryText()
                tableView.reloadData()
                
                onChange(self.selectedValues)
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
