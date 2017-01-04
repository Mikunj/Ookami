//
//  LibraryViewController.swift
//  Ookami
//
//  Created by Maka on 2/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import XLPagerTabStrip
import BTNavigationDropdownMenu

protocol LibraryEntryDataSource: ItemViewControllerDataSource {
    func didSet(filter: LibraryViewController.Filter)
}

//Class used for displaying library entries of a specific type
final class LibraryViewController: ButtonBarPagerTabStripViewController {
    
    //The current library we are displaying
    fileprivate var type: Media.MediaType
    
    //The source of data to use
    fileprivate var source: [LibraryEntry.Status: LibraryEntryDataSource]
    
    //The controllers to display
    fileprivate var itemControllers: [LibraryEntry.Status: ItemViewController] = [:]

    
    /// Create an `LibraryViewController`
    ///
    /// - Parameter dataSource: The datasource to use.
    init(dataSource: [LibraryEntry.Status: LibraryEntryDataSource], type: Media.MediaType) {
        self.source = dataSource
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Do not use this to initialize `LibraryViewController`
    /// It will throw a fatal error if you do.
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use LibraryViewController.init(dataSource:)")
    }
    
    override func viewDidLoad() {
        self.settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        self.settings.style.buttonBarItemTitleColor = UIColor.white
        self.settings.style.buttonBarBackgroundColor = UIColor.black
        self.settings.style.buttonBarItemBackgroundColor = UIColor.darkGray
        self.settings.style.buttonBarItemLeftRightMargin = 12
        self.settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14)
        
        super.viewDidLoad()
        
    }
    
    func updateItemViewControllers() {
        //Update the sources
        for status in LibraryEntry.Status.all {
            itemControllers[status]?.dataSource = source[status]
        }
        
        self.buttonBarView.reloadData()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var controllers: [ItemViewController] = []
        
        //Create the item view controllers and add them in order
        for status in LibraryEntry.Status.all {
            let itemController = ItemViewController(dataSource: nil)
            itemController.title = status.toReadableString(for: type)
            itemControllers[status] = itemController
            
            controllers.append(itemController)
        }
        
        updateItemViewControllers()
        
        return controllers
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        
        //Change the color under the bar
        let statuses = LibraryEntry.Status.all
        if progressPercentage < 0.5 {
            self.buttonBarView.selectedBar.backgroundColor = statuses[fromIndex].color()
        } else {
            self.buttonBarView.selectedBar.backgroundColor = statuses[toIndex].color()
        }
    }
}

//Mark:- Filter
extension LibraryViewController {
    enum Filter: String {
        case updatedAt
    }
}
