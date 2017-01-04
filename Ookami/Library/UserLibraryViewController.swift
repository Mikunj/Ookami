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

//NOTE: Sometimes the entries get loaded but don't show up. find out why

//Class used for displaying a users library (both anime and manga)
final class UserLibraryViewController: UIViewController {
    
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
    /// - Parameter dataSource: The datasource to use.
    init(dataSource: UserLibraryViewDataSource) {
        self.source = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use UserLibraryViewController.init(dataSource:)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
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
        dropDownMenu.cellBackgroundColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        dropDownMenu.cellTextLabelColor = UIColor.white
        dropDownMenu.menuTitleColor = UIColor.white
        dropDownMenu.animationDuration = 0.2
        
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
