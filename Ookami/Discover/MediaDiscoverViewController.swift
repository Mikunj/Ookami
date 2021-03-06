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
    
    //The discover view controller
    fileprivate var searchController: SearchItemViewController
    
    //The current media that is being shown
    fileprivate var currentMedia: Media.MediaType = .anime
    
    //The sources used
    fileprivate var animeSource: AnimeDiscoverDataSource
    fileprivate var mangaSource: MangaDiscoverDataSource
    
    //The list of items which can be selected in the dropdown menu
    fileprivate var dropDownMenuItems = ["Anime", "Manga"]
    
    //The dropdown menu
    fileprivate var dropDownMenu: BTNavigationDropdownMenu!
    
    fileprivate lazy var filterBarButton: UIBarButtonItem = {
        return UIBarButtonItem(withIcon: .filterIcon, size: CGSize(width: 22, height: 22), target: self, action: #selector(filterTapped))
    }()
    
    init() {
        animeSource = AnimeDiscoverDataSource()
        mangaSource = MangaDiscoverDataSource()
        searchController = SearchItemViewController(dataSource: animeSource)
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
        
        self.addChildViewController(searchController)
        self.view.addSubview(searchController.view)
        
        constrain(searchController.view) { view in
            view.edges == view.superview!.edges
        }
        
        searchController.didMove(toParentViewController: self)
        
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
        
        
        self.navigationItem.rightBarButtonItem = filterBarButton
        
        show(.anime)
    }
    
    /// Show the appropriate view controller for the given media type
    ///
    /// - Parameter type: The media type
    func show(_ type: Media.MediaType) {
        if type != currentMedia {
            searchController.dataSource = type == .anime ? animeSource : mangaSource
            currentMedia = type
        }
    }
    
    
    func filterTapped() {
        var filterVC: BaseMediaFilterViewController? = nil
        
        switch currentMedia {
        case .anime:
            filterVC = AnimeFilterViewController(filter: animeSource.filter) { newFilter in
                self.animeSource.filter = newFilter
            }
            
        case .manga:
            filterVC = MangaFilterViewController(filter: mangaSource.filter) { newFilter in
                self.mangaSource.filter = newFilter
            }
        }
        
        //Present the filter
        if let vc = filterVC {
            let nav = UINavigationController(rootViewController: vc)
            vc.title = "Filter"
            self.present(nav, animated: true)
        }
    }
    
}

