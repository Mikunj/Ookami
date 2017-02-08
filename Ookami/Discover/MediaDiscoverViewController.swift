//
//  MediaDiscoverViewController.swift
//  Ookami
//
//  Created by Maka on 8/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import BTNavigationDropdownMenu
import OokamiKit
import Cartography

//Class used for displaying the discover page for all media (anime, manga, etc...)
final class MediaDiscoverViewController: UIViewController {
    
    //The disover view controller
    fileprivate var discoverController: DiscoverViewController
    
    //The current media that is being shown
    fileprivate var currentMedia: Media.MediaType = .anime
    
    //The sources used
    fileprivate var animeSource: AnimeDiscoverDataSource
    fileprivate var mangaSource: MangaDiscoverDataSource
    
    //The list of items which can be selected in the dropdown menu
    fileprivate var dropDownMenuItems = ["Anime", "Manga"]
    
    //The dropdown menu
    fileprivate var dropDownMenu: BTNavigationDropdownMenu!
    
    init() {
        animeSource = AnimeDiscoverDataSource()
        mangaSource = MangaDiscoverDataSource()
        discoverController = DiscoverViewController(dataSource: animeSource)
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
        
        self.addChildViewController(discoverController)
        self.view.addSubview(discoverController.view)
        
        constrain(discoverController.view) { view in
            view.edges == view.superview!.edges
        }
        
        discoverController.didMove(toParentViewController: self)
        
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
        if type != currentMedia {
            discoverController.dataSource = type == .anime ? animeSource : mangaSource
            currentMedia = type
        }
    }
    
}

