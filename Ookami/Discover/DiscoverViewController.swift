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
    weak var parent: DiscoverViewController? { get set }
}

final class DiscoverViewController: UIViewController {
    
    //The data source to use
    fileprivate var dataSource: DiscoverDataSource {
        didSet {
            itemController.dataSource = dataSource
            dataSource.parent = self
        }
    }
    
    //The item controller to show the results
    fileprivate var itemController: ItemViewController
    
//    //The search bar
//    fileprivate lazy var searchBar: UISearchBar = {
//        return UISearchBar()
//    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the item view controller
        self.addChildViewController(itemController)
        self.view.addSubview(itemController.view)
        
        constrain(itemController.view) { view in
            view.edges == view.superview!.edges
        }
        
        itemController.didMove(toParentViewController: self)
    }
    
    
}

