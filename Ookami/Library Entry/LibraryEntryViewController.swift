//
//  LibraryEntryViewController.swift
//  Ookami
//
//  Created by Maka on 6/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import Cartography
import Reusable

private enum DataType {
    case string
    case bool
}

private struct TableData {
    var type: DataType
    var value: Any
    var heading: String
}

//TODO: Add entry editing and syncing
class LibraryEntryViewController: UIViewController {

    //The entry we are viewing
    let entry: LibraryEntry
    
    //The unmanaged entry
    var unmanaged: LibraryEntry
    
    //The tableview to display data in
    lazy var tableView: UITableView = {
        let t = UITableView()
        t.alwaysBounceVertical = true
        t.backgroundColor = Theme.ControllerTheme().backgroundColor
        t.dataSource = self
        t.delegate = self
        
        t.register(cellType: EntryStringTableViewCell.self)
        t.register(cellType: EntryBoolTableViewCell.self)
        
        t.tintColor = Theme.Colors().secondary
        
        //Auto table height
        t.estimatedRowHeight = 60
        t.rowHeight = UITableViewAutomaticDimension
        
        //Set the footer view so we don't get extra seperators
        t.tableFooterView = UIView(frame: .zero)
        
        return t
    }()
    
    var editAccessory: UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.backgroundColor = UIColor.blue
        return view
    }
    
    //Whether the entry is editable
    let editable: Bool
    
    //The data we are going to use for the table view
    fileprivate var tableData: [TableData] = []
    
    /// Create an LibraryEntryViewController
    ///
    /// - Parameter entry: The library entry to view.
    init(entry: LibraryEntry) {
        //Get the unmanaged entry
        self.entry = entry
        unmanaged = LibraryEntry(value: entry)
        
        //entry is only editabe if we are the current user
        editable = entry.userID == CurrentUser().userID
        
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Do not use this to initialize `LibraryEntryViewController`
    /// It will throw a fatal error if you do.
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use LibraryEntryViewController(entry:)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = unmanaged.toEntryMediaHeaderData().name
        //TODO: Add button bar items here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        constrain(tableView) { view in
            view.edges == view.superview!.edges
        }
        
        //Add the header
        //Testing to see if media is copied or just the basic values
        let header = EntryMediaHeaderView(data: unmanaged.toEntryMediaHeaderData())
        header.delegate = self
        tableView.tableHeaderView = header
        
        updateData()
        
        //Force tableview to resize cells properley
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }
    
    //Update the table data
    func updateData() {
        
        let progress = TableData(type: .string, value: String(unmanaged.progress), heading: "Progress")
        
        let ratingString = unmanaged.rating > 0 ? String(unmanaged.rating) : "-"
        let rating = TableData(type: .string, value: ratingString, heading: "Rating")
        
        let notes = TableData(type: .string, value: unmanaged.notes, heading: "Notes")
        
        let reconsumeCount = TableData(type: .string, value: String(unmanaged.reconsumeCount), heading: "Reconsume Count")
        
        let reconsuming = TableData(type: .bool, value: unmanaged.reconsuming, heading: "Reconsuming")
        
        let isPrivate = TableData(type: .bool, value: unmanaged.isPrivate, heading: "Private")
        
        tableData = [progress, rating, notes, reconsumeCount, reconsuming]
        
        //Only add private if entry belongs to current user
        if entry.userID == CurrentUser().userID {
            tableData.append(isPrivate)
        }
        
        tableView.reloadData()
    }
    
}

//MARK:- Data source
extension LibraryEntryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = tableData[indexPath.row].type
        switch type {
        case .bool:
            return tableView.dequeueReusableCell(for: indexPath) as EntryBoolTableViewCell
        case .string:
            return tableView.dequeueReusableCell(for: indexPath) as EntryStringTableViewCell
        }
    }
    
}

//MARK:- Delegate
extension LibraryEntryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let data = tableData[indexPath.row]
        cell.tintColor = Theme.Colors().secondary
        
        if let stringCell = cell as? EntryStringTableViewCell {
            cell.accessoryType = .none
            cell.accessoryView = editAccessory
            stringCell.headingLabel.text = data.heading
            
            let value = data.value as? String ?? ""
            stringCell.valueLabel.text = value.isEmpty ? "-" : value
        }
        
        if let boolCell = cell as? EntryBoolTableViewCell {
            boolCell.headingLabel.text = data.heading
            
            let value = data.value as? Bool ?? false
            cell.accessoryType = value ? .checkmark : .none
        }
        
        if !editable {
            cell.accessoryView = nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //TODO: Handle value editing here
    }
}

//MARK:- EntryMediaHeaderViewDelegate
extension LibraryEntryViewController: EntryMediaHeaderViewDelegate {
    func didTapMediaButton() {
        
    }
}
