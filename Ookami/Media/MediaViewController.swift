//
//  MediaViewController.swift
//  Ookami
//
//  Created by Maka on 13/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Cartography

//A section of data that can be displayed in the controller
struct MediaViewControllerSection {
    var title: String
    var cellCount: Int
    var cellForIndexPath: (IndexPath, UITableView) -> UITableViewCell = { _,_ in return UITableViewCell() }
    var willDisplayCell: ((IndexPath, UITableViewCell) -> Void)? = nil
    var didSelectRow: ((IndexPath, UITableView) -> Void)? = nil
    var heightForRow: (IndexPath) -> CGFloat = { _ in
        return UITableViewAutomaticDimension
    }
    var estimatedHeightForRow: (IndexPath) -> CGFloat = { _ in
        return 44
    }
    
    init(title: String, cellCount: Int) {
        self.title = title
        self.cellCount = cellCount
    }
}

//A controller which allows the display of media
class MediaViewController: NavigationHidingViewController {
    
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
        t.register(cellType: MediaInfoTableViewCell.self)
        
        //Auto table height
        t.estimatedRowHeight = 15
        t.rowHeight = UITableViewAutomaticDimension
        
        //Set the footer view so we don't get extra seperators
        t.tableFooterView = UIView(frame: .zero)
        
        //Disable default reading margins
        t.cellLayoutMarginsFollowReadableWidth = false
        
        return t
    }()
    
    //The height of the header
    var headerHeight: CGFloat {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        return isIpad ? 464 : 344
    }
    
    //The header view
    lazy var mediaHeader: MediaTableHeaderView = {
        let width = self.view.bounds.width
        let height = self.headerHeight
        return MediaTableHeaderView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
    }()
    
    //The layout constraints used for parallax
    var mediaHeaderTop: NSLayoutConstraint?
    var mediaHeaderHeight: NSLayoutConstraint?
    
    //The backing data for the table view
    var data: [MediaViewControllerSection] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Force the scrollview scroll
        scrollViewDidScroll(tableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the table view
        self.view.addSubview(tableView)
        constrain(tableView) { view in
            view.edges == view.superview!.edges
        }
        
        //Add the header to the table view
        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        tableView.addSubview(mediaHeader)
        constrain(mediaHeader, self.view) { header, view in
            mediaHeaderTop = (header.top == view.top)
            header.left == view.left
            header.right == view.right
            mediaHeaderHeight = (header.height == headerHeight)
        }
        
        //Force tableview layout
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        
        //Bring the bar at the front
        self.view.bringSubview(toFront: barView)
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
    
    //The title to show on the navigation bar
    override func barTitle() -> String {
        return "Media"
    }
    
    override func visibleOffset() -> CGFloat {
        return -150
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return data[indexPath.section].heightForRow(indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return data[indexPath.section].estimatedHeightForRow(indexPath)
    }
}

//MARK:- Delegate
extension MediaViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TitleTableSectionView()
        view.titleLabel.text = data[section].title
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 27
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

//MARK:- Scroll view delegate
extension MediaViewController {
    
    func updateHeaderConstraints(offset: CGFloat) {
        //We use the diff because media header is attached to the top of the base view
        //We need to know how much we moved up / down
        let diff = headerHeight + offset
        
        //The minimal offset that squash will occur until
        let minSquash: CGFloat = headerHeight - 100
        
        //Stick the top until we reach min squash
        let topDiff = (diff > 0 && diff < minSquash) ? 0 : diff
        mediaHeaderTop?.constant = min(0, -topDiff)
        
        //Squish the height until we reach the min squash
        let excessHeight = topDiff == 0 ? minSquash : 0
        mediaHeaderHeight?.constant = max(headerHeight - excessHeight, -offset)
        
        //This will cause a space to be left at the bottom if the table contents height is less than the header height.
        //We set the insets so that it looks like mediaHeader is actually the tableHeaderView.
        //Without setting them the section headers will float when scrolling.
        //If in the future, section headers are removed then this should also be removed.
        let barViewHeight = barView.frame.height
        let topInset = min(headerHeight, max(barViewHeight, -offset))
        tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        updateNavigationBar(offset: offset)
        updateHeaderConstraints(offset: offset)
    }
}
