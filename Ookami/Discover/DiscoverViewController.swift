//
//  DiscoverViewController.swift
//  Ookami
//
//  Created by Maka on 8/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import Cartography

protocol DiscoverDataSource: ItemViewControllerDataSource {
    weak var parent: UIViewController? { get set }
    func didSearch(text: String)
}

final class DiscoverViewController: UIViewController {
    
    //The data source to use
    var dataSource: DiscoverDataSource {
        didSet {
            itemController.dataSource = dataSource
            dataSource.parent = self
            dataSource.didSearch(text: searchBar.text ?? "")
        }
    }
    
    //The item controller to show the results
    fileprivate var itemController: ItemViewController
    
    //The search bar
    fileprivate lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search by title, character or staff..."
        bar.delegate = self
        bar.barTintColor = Theme.NavigationTheme().barColor.darkened(amount: 0.04)
        bar.tintColor = UIColor.white
        
        //Change the tint color of the cursor
        for subView in bar.subviews[0].subviews where subView is UITextField {
            subView.tintColor = Theme.Colors().secondary
        }
        
        return bar
    }()
    
    init(dataSource: DiscoverDataSource) {
        self.dataSource = dataSource
        itemController = ItemViewController(dataSource: dataSource)
        itemController.shouldLoadImages = true
        super.init(nibName: nil, bundle: nil)
        
        self.dataSource.parent = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(dataSource:) instead")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the item view controller and the search bar
        self.addChildViewController(itemController)
        
        self.view.addSubview(searchBar)
        self.view.addSubview(itemController.view)
        
        constrain(searchBar, itemController.view) { bar, view in
            bar.top == bar.superview!.top
            bar.left == bar.superview!.left
            bar.right == bar.superview!.right
            bar.height == 44
            bar.bottom == view.top
        
            view.left == view.superview!.left
            view.right == view.superview!.right
            view.bottom == view.superview!.bottom
        }
        
        itemController.didMove(toParentViewController: self)
        itemController.onScroll = {
            self.searchBar.resignFirstResponder()
        }
    }
    
    
}

//MARK:- Search bar delegate
extension DiscoverViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSource.didSearch(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

