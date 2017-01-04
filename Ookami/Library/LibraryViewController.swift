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

//Class used for displaying library entries
final class LibraryViewController: ButtonBarPagerTabStripViewController {
    
    //The current library we are displaying
    fileprivate var currentLibrary: Media.MediaType = .anime {
        didSet { updateItemViewControllers() }
    }
    
    //The source of data to use
    fileprivate var source: LibraryViewDataSource?
    
    //The controllers to display
    fileprivate var itemControllers: [LibraryEntry.Status: ItemViewController] = [:]
    
    //The list of items which can be selected in the dropdown menu
    fileprivate var dropDownMenuItems = ["Anime", "Manga"]
    
    //The dropdown menu
    fileprivate var dropDownMenu: BTNavigationDropdownMenu!
    
    /// Create an `LibraryViewController`
    ///
    /// - Parameter dataSource: The datasource to use.
    init(dataSource: LibraryViewDataSource) {
        self.source = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    /// Do not use this to initialize `LibraryViewController`
    /// It will throw a fatal error if you do.
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use LibraryViewController.init(dataSource:)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationController?.navigationBar.topItem?.titleView = dropDownMenu
        
    }
    
    override func viewDidLoad() {
        self.settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        self.settings.style.buttonBarItemTitleColor = UIColor.white
        self.settings.style.buttonBarBackgroundColor = UIColor.black
        self.settings.style.buttonBarItemBackgroundColor = UIColor.darkGray
        self.settings.style.buttonBarItemLeftRightMargin = 12
        self.settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14)
        
        super.viewDidLoad()
        
        //Add the dropdown menu
        dropDownMenu = BTNavigationDropdownMenu(title: dropDownMenuItems[0], items: dropDownMenuItems as [AnyObject])
        dropDownMenu.cellBackgroundColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        dropDownMenu.cellTextLabelColor = UIColor.white
        dropDownMenu.menuTitleColor = UIColor.white
        dropDownMenu.animationDuration = 0.2
        
        dropDownMenu.didSelectItemAtIndexHandler = { [weak self] index in
            if let item = self?.dropDownMenuItems[index] {
                if item == "Anime" { self?.currentLibrary = .anime }
                if item == "Manga" { self?.currentLibrary = .manga }
            }
        }

    }
    
    func updateItemViewControllers() {
        
        //Get the correct sources to use
        var s: [LibraryEntry.Status: LibraryEntryDataSource]? = nil
        switch currentLibrary {
        case .anime:
            s = source?.anime
        case .manga:
            s = source?.manga
        }
        
        //If we don't have a source then don't display anything
        guard let sources = s else {
            itemControllers.values.forEach { $0.dataSource = nil }
            return
        }
        
        //Update the sources
        for status in LibraryEntry.Status.all {
            itemControllers[status]?.dataSource = sources[status]
            itemControllers[status]?.title = status.toReadableString(for: currentLibrary)
        }
        
        self.buttonBarView.reloadData()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var controllers: [ItemViewController] = []
        
        //Create the item view controllers and add them in order
        for status in LibraryEntry.Status.all {
            let itemController = ItemViewController(dataSource: nil)
            itemController.title = status.toReadableString(for: currentLibrary)
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
