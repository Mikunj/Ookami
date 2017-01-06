//
//  UserLibraryViewController.swift
//  Ookami
//
//  Created by Maka on 4/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import OokamiKit
import Cartography

//TODO: Need to add PagedLibraryDataSource

//Class used for displaying a users library (both anime and manga)
final class UserLibraryViewController: UIViewController {
    
    //The current user we're fetching library for
    fileprivate var userID: Int
    
    //The source of the data
    fileprivate var source: UserLibraryViewDataSource
    
    //The list of items which can be selected in the dropdown menu
    fileprivate var dropDownMenuItems = ["Anime", "Manga"]
    
    //The dropdown menu
    fileprivate var dropDownMenu: BTNavigationDropdownMenu!
    
    //The library view controllers
    fileprivate var animeController: LibraryViewController!
    fileprivate var mangaController: LibraryViewController!
    
    /// Create a `UserLibraryViewController`
    ///
    /// - Parameters:
    ///   - userID: The user id who we are showing the library of
    ///   - dataSource: The data source to use.
    init(userID: Int, dataSource: UserLibraryViewDataSource) {
        self.userID = userID
        self.source = dataSource
        super.init(nibName: nil, bundle: nil)
        
        //Set ourselves as the parent so we can show the appropriate VC when an entry is tapped
        self.source.parent = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use UserLibraryViewController.init(dataSource:)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Themeing
        let theme = Theme.DropDownTheme()
        dropDownMenu.cellBackgroundColor = theme.backgroundColor
        dropDownMenu.cellTextLabelColor = theme.textColor
        dropDownMenu.menuTitleColor = theme.textColor
        dropDownMenu.arrowTintColor = theme.textColor
        dropDownMenu.cellSelectionColor = theme.selectionBackgroundColor
        dropDownMenu.cellSeparatorColor = theme.seperatorColor
        
        self.navigationController?.navigationBar.topItem?.titleView = dropDownMenu
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the library views
        animeController = LibraryViewController(dataSource: source.anime, type: .anime)
        mangaController = LibraryViewController(dataSource: source.manga, type: .manga)
        
        for controller in [animeController, mangaController] as [LibraryViewController] {
            self.addChildViewController(controller)
            self.view.addSubview(controller.view)
            
            constrain(controller.view) { view in
                view.edges == view.superview!.edges
            }
            
            controller.didMove(toParentViewController: self)
        }
        
        //Setup dropdown menu
        dropDownMenu = BTNavigationDropdownMenu(title: dropDownMenuItems[0], items: dropDownMenuItems as [AnyObject])
        dropDownMenu.animationDuration = 0.2
        dropDownMenu.shouldKeepSelectedCellColor = true
        
        dropDownMenu.didSelectItemAtIndexHandler = { [weak self] index in
            if let item = self?.dropDownMenuItems[index] {
                if item == "Anime" { self?.show(.anime) }
                if item == "Manga" { self?.show(.manga) }
            }
        }
        
        show(.anime)
    }
    
    /// Show the appropriate view controller for the given media type
    ///
    /// - Parameter type: The media type
    func show(_ type: Media.MediaType) {
        animeController.view.isHidden = type != .anime
        mangaController.view.isHidden = type != .manga
    }
    
}

extension UserLibraryViewController: LibraryDataSourceParent {
    func didTapEntry(entry: LibraryEntry) {
        let entryVC = LibraryEntryViewController(entry: entry)
        self.navigationController?.pushViewController(entryVC, animated: true)
    }
}
