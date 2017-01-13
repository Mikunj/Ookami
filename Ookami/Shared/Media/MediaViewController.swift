//
//  MediaViewController.swift
//  Ookami
//
//  Created by Maka on 13/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Cartography

struct MediaViewControllerSection {
    var title: String
    var cellCount: Int
    var cellForIndexPath: (IndexPath, UITableView) -> UITableViewCell = { _,_ in return UITableViewCell() }
    var willDisplayCell: ((IndexPath, UITableViewCell) -> Void)? = nil
    var didSelectRow: ((IndexPath, UITableView) -> Void)? = nil
    
    init(title: String, cellCount: Int) {
        self.title = title
        self.cellCount = cellCount
    }
}

class MediaViewController: UIViewController {
    
    //The tableview to display data in
    lazy var tableView: UITableView = {
        let t = UITableView()
        t.alwaysBounceVertical = true
        t.backgroundColor = Theme.ControllerTheme().backgroundColor
        t.dataSource = self
        t.delegate = self
        
        t.tintColor = Theme.EntryView().tintColor
        t.separatorStyle = .none
        
        t.register(cellType: MediaTextTableViewCell.self)
        
        //Auto table height
        t.estimatedRowHeight = 44
        t.rowHeight = UITableViewAutomaticDimension
        
        //Set the footer view so we don't get extra seperators
        t.tableFooterView = UIView(frame: .zero)
        
        //Disable default reading margins
        t.cellLayoutMarginsFollowReadableWidth = false
        
        return t
    }()
    
    lazy var mediaHeader: MediaTableHeaderView = {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let width = self.view.bounds.width
        let height: CGFloat = isIpad ? 420 : 295
        return MediaTableHeaderView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
    }()
    
    //The backing data for the table view
    var data: [MediaViewControllerSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the table view
        self.view.addSubview(tableView)
        constrain(tableView) { view in
            view.edges == view.superview!.edges
        }

        //Force tableview layout
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        
        tableView.tableHeaderView = mediaHeader
    }
    
    func reloadData() {
        data = sectionData()
        
        //Make it calculate the height
        let offset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(offset, animated: false)
    }
    
    ///Called when reloadData is called
    func sectionData() -> [MediaViewControllerSection] {
        return []
    }

}

//MARK:- DataSource
extension MediaViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = data[section]
        return section.cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = data[indexPath.section]
        let cell = section.cellForIndexPath(indexPath, tableView)
        
        return cell
    }
}

//MARK:- Delegate
extension MediaViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = MediaTableSectionView()
        view.titleLabel.text = data[section].title
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        return isIpad ? 50 : 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.section].didSelectRow?(indexPath, tableView)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let section = data[indexPath.section]
        section.willDisplayCell?(indexPath, cell)
    }
}
