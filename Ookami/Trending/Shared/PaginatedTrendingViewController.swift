//
//  PaginatedTrendingViewController.swift
//  Ookami
//
//  Created by Maka on 9/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import Cartography

protocol PaginatedTrendingDataSource: ItemViewControllerDataSource {
    weak var parent: UIViewController? { get set }
}

//A view controller to display paginated trending items
class PaginatedTrendingViewController: UIViewController {
    
    /// The data source to use
    var dataSource: PaginatedTrendingDataSource {
        didSet {
            itemController.dataSource = dataSource
            dataSource.parent = self
        }
    }
    
    //The item controller to show the results
    fileprivate var itemController: ItemViewController
    
    /// Make a paginated trending view controller.
    ///
    /// - Parameters:
    ///   - dataSource: The data source to use
    init(dataSource: PaginatedTrendingDataSource) {
        self.dataSource = dataSource
        
        itemController = ItemViewController(dataSource: dataSource)
        itemController.type = .simpleGrid
        itemController.shouldLoadImages = true
        super.init(nibName: nil, bundle: nil)
        
        self.dataSource.parent = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(dataSource:) instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the item view controller and the search bar
        self.addChildViewController(itemController)
        
        self.view.addSubview(itemController.view)
        
        constrain(itemController.view) { view in
            view.edges == view.superview!.edges
        }
        
        itemController.didMove(toParentViewController: self)
    }

}
