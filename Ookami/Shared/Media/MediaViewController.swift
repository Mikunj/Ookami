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

//TODO: We can extract this into NavigationHidingViewController which can also be used by UserViewController.

class MediaViewController: UIViewController {
    
    //The top view to emulate a navigation bar set by the system
    lazy var topView: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.NavigationTheme().barColor
        return v
    }()
    
    //The height constraint of the top view
    var topViewHeight: NSLayoutConstraint?
    
    //The navigation bar we use so we can get transparancy
    lazy var navigationBar: UINavigationBar = {
        let bar = UINavigationBar()
        let theme = Theme.NavigationTheme()
        bar.isTranslucent = true
        bar.barTintColor = UIColor.clear
        bar.tintColor = theme.barTextColor
        bar.titleTextAttributes = [NSForegroundColorAttributeName: theme.barTextColor]
        bar.setBackgroundImage(UIImage(), for: .default)
        bar.shadowImage = UIImage()
        
        let item = UINavigationItem(title: "")
        
        let close = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(didDismiss))
        item.leftBarButtonItem = close
        
        bar.setItems([item], animated: false)
        
        return bar
    }()
    
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
    
    //The header view
    lazy var mediaHeader: MediaTableHeaderView = {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let width = self.view.bounds.width
        let height: CGFloat = isIpad ? 464 : 344
        return MediaTableHeaderView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
    }()
    
    //The backing data for the table view
    var data: [MediaViewControllerSection] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        topView.isHidden = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        topView.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the table view
        self.view.addSubview(tableView)
        constrain(tableView) { view in
            view.edges == view.superview!.edges
        }
        
        //Add the bar
        topView.addSubview(navigationBar)
        constrain(navigationBar) { bar in
            bar.bottom == bar.superview!.bottom
            bar.left == bar.superview!.left
            bar.right == bar.superview!.right
            bar.height == 44
        }
        
        //The top view
        self.view.addSubview(topView)
        constrain(topView) { view in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.right == view.superview!.right
            topViewHeight = (view.height == 44)
        }
        updateTopViewHeight()
        
        self.view.bringSubview(toFront: topView)
        
        //Force tableview layout
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        
        tableView.tableHeaderView = mediaHeader
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateTopViewHeight()
    }
    
    //Update the height of the top view incase of orientation changes
    func updateTopViewHeight() {
        let statusHeight = UIApplication.shared.statusBarFrame.height
        let barHeight = self.navigationController?.navigationBar.frame.size.height ?? 44
        topViewHeight?.constant = barHeight + statusHeight
        UIView.animate(withDuration: 0.5, animations: topView.layoutIfNeeded)
    }
    
    func didDismiss() {
        self.dismiss(animated: true)
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
    func barTitle() -> String {
        return "Media"
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

//MARK:- Scroll view delegate
extension MediaViewController {
    
    //Update the display of the navigation bar
    func updateNavigationBar(offset: CGFloat = 0) {
        
        let minOffset = mediaHeader.coverImage.frame.height + 44
        
        UIView.animate(withDuration: 0.3) {
            let color = offset > minOffset ? Theme.NavigationTheme().barColor : UIColor.clear
            self.navigationBar.topItem?.title = offset > minOffset ? self.barTitle() : ""
            self.topView.backgroundColor = color
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        updateNavigationBar(offset: offset)
    }
}
