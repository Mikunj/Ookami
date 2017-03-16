//
//  MediaTrendingTableViewController.swift
//  Ookami
//
//  Created by Maka on 6/3/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import Cartography
import BTNavigationDropdownMenu

//Might be better to combine Both Anime and Manga into 1?

//View controller for showing Trends of Anime and Manga combined
class MediaTrendingTableViewController: UIViewController {
    
    //The trending view controller
    fileprivate var animeController: AnimeTrendingTableViewController
    fileprivate var mangaController: MangaTrendingTableViewController
    
    //The list of items which can be selected in the dropdown menu
    fileprivate var dropDownMenuItems = ["Anime", "Manga"]
    
    //The dropdown menu
    fileprivate var dropDownMenu: BTNavigationDropdownMenu!
    
    init() {
        animeController = AnimeTrendingTableViewController()
        mangaController = MangaTrendingTableViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init() instead.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.titleView = dropDownMenu
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Theme.ControllerTheme().backgroundColor
        
        for controller in [animeController, mangaController] as [UIViewController] {
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
        
        //Themeing
        let theme = Theme.DropDownTheme()
        dropDownMenu.cellBackgroundColor = theme.backgroundColor
        dropDownMenu.cellTextLabelColor = theme.textColor
        dropDownMenu.menuTitleColor = theme.textColor
        dropDownMenu.arrowTintColor = theme.textColor
        dropDownMenu.cellSelectionColor = theme.selectionBackgroundColor
        dropDownMenu.cellSeparatorColor = theme.seperatorColor
        
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
