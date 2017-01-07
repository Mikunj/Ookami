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
import ActionSheetPicker_3_0



//TODO: Add entry editing and syncing
class LibraryEntryViewController: UIViewController {
    
    let data: LibraryEntryViewData
    
    //The tableview to display data in
    lazy var tableView: UITableView = {
        let t = UITableView()
        t.alwaysBounceVertical = true
        t.backgroundColor = Theme.ControllerTheme().backgroundColor
        t.dataSource = self
        t.delegate = self
        
        t.register(cellType: EntryStringTableViewCell.self)
        t.register(cellType: EntryBoolTableViewCell.self)
        t.register(cellType: EntryButtonTableViewCell.self)
        
        t.tintColor = Theme.EntryView().tintColor
        
        //Auto table height
        t.estimatedRowHeight = 60
        t.rowHeight = UITableViewAutomaticDimension
        
        //Set the footer view so we don't get extra seperators
        t.tableFooterView = UIView(frame: .zero)
        
        //Disable default reading margins
        t.cellLayoutMarginsFollowReadableWidth = false
        
        return t
    }()
    
    //Pencil image used to indicate that user can edit the field
    fileprivate lazy var pencilImage: UIImage = {
        return FontAwesomeIcon.pencilIcon.image(ofSize: CGSize(width: 10, height: 10), color: Theme.EntryView().tintColor)
    }()
    
    //Whether the entry is editable
    let editable: Bool
    
    //The data we are going to use for the table view
    fileprivate var tableData: [LibraryEntryViewData.TableData] = []
    
    /// Create an LibraryEntryViewController
    ///
    /// - Parameter entry: The library entry to view.
    init(entry: LibraryEntry) {
        //Get the unmanaged entry
        self.data = LibraryEntryViewData(entry: entry)
        
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
        
        // Show the save icon if we can edit the entries
        if editable {
            let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didSave))
            
            self.navigationItem.rightBarButtonItem = save
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the table view
        self.view.addSubview(tableView)
        constrain(tableView) { view in
            view.edges == view.superview!.edges
        }

        //Add the header
        let header = EntryMediaHeaderView(data: data.unmanaged.toEntryMediaHeaderData())
        header.delegate = self
        tableView.tableHeaderView = header
        
        tableView.reloadData()
    }
    
}

//MARK:- Data source
extension LibraryEntryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //We can do it this was because we are 100% certain the data count won't change randomly while view is up
        return data.tableData().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableData = data.tableData()
        let type = tableData[indexPath.row].type
        var cell: UITableViewCell = UITableViewCell()
        switch type {
        case .bool:
            cell = tableView.dequeueReusableCell(for: indexPath) as EntryBoolTableViewCell
            break
        case .string:
            cell = tableView.dequeueReusableCell(for: indexPath) as EntryStringTableViewCell
            break
        case .button:
            cell = tableView.dequeueReusableCell(for: indexPath) as EntryButtonTableViewCell
            break
            
        }
        
        //We update here because tableview won't automatically adjust height in willDisplayCell, unless we change orientation
        update(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    func update(cell: UITableViewCell, indexPath: IndexPath) {
        let tableData = self.data.tableData()
        let data = tableData[indexPath.row]
        let heading = data.heading.rawValue
        
        //String cell
        if let stringCell = cell as? EntryStringTableViewCell {
            
            let pencil = UIImageView(image: pencilImage)
            
            cell.accessoryType = .none
            cell.accessoryView = pencil
            stringCell.headingLabel.text = heading
            
            let value = data.value as? String ?? ""
            stringCell.valueLabel.text = value.isEmpty ? "-" : value
        }
        
        //Bool cell
        if let boolCell = cell as? EntryBoolTableViewCell {
            boolCell.headingLabel.text = heading
            
            let value = data.value as? Bool ?? false
            cell.accessoryType = value ? .checkmark : .none
        }
        
        //Button cell
        if let buttonCell = cell as? EntryButtonTableViewCell {
            let value = data.value as? String ?? ""
            buttonCell.headingLabel.text = heading
            buttonCell.valueLabel.text = value.isEmpty ? "-" : value
            buttonCell.button.isHidden = !editable
            buttonCell.delegate = self
            buttonCell.indexPath = indexPath
        }
        
        if !editable {
            cell.accessoryView = nil
        }
    }
    
}

//MARK:- Delegate
extension LibraryEntryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !editable { return }
        
        data.editData(at: indexPath, tableView: tableView)
    }
}

//MARK:- EntryMediaHeaderViewDelegate & Entry Button Delegate
extension LibraryEntryViewController: EntryMediaHeaderViewDelegate, EntryButtonDelegate {
    func didTapMediaButton() {
        
    }
    
    func didTapButton(inCell: EntryButtonTableViewCell, indexPath: IndexPath?) {
        if let indexPath = indexPath {
            data.incrementValue(at: indexPath)
            tableView.reloadData()
        }
    }
}

//Mark:- Entry editing
extension LibraryEntryViewController {
    
    //Save was tapped
    func didSave() {
        
    }
    
    
}
