//
//  SearchItemViewController.swift
//  Ookami
//
//  Created by Maka on 27/6/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import Cartography

protocol SearchDataSource: ItemViewControllerDataSource {
    weak var parent: UIViewController? { get set }
    var searchBarPlaceHolder: String { get }
    var searchDisplayType: ItemViewController.CellType { get }
    
    func didSearch(text: String)
    
}

final class SearchItemViewController: UIViewController {
    
    //The data source to use
    var dataSource: SearchDataSource {
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
    
    init(dataSource: SearchDataSource) {
        self.dataSource = dataSource
        itemController = ItemViewController(dataSource: dataSource)
        itemController.type = .simpleGrid
        itemController.shouldLoadImages = true
        super.init(nibName: nil, bundle: nil)
        
        searchBar.placeholder = dataSource.searchBarPlaceHolder
        itemController.type = dataSource.searchDisplayType
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
        itemController.onScroll = { [unowned self] scrollView in
            
            //Scrolling presents a problem where if you type something, the collection view will scroll to the top and the keyboard will be dismissed immediately, leaving you with only 1 character typed.
            //This means to actually type out a word you would have to always be at the very top of the collection view
            //To combat this we only dismiss the keyboard if we are scrolling down
            //This ensures we can still keep typing when the collection view automatically scrolls to the top
            let yVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
            guard yVelocity < 0 else { return }
            
            self.searchBar.resignFirstResponder()
        }
    }
    
    
}

//MARK:- Search bar delegate
extension SearchItemViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSource.didSearch(text: searchText)
        itemController.scrollToTop(animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

