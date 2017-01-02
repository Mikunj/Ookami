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

//TODO: Maybe move this into its own swift file
extension LibraryEntry.Status {
    //Get the UIColor for a given status
    func color() -> UIColor {
        switch self {
        case .current:
            return UIColor(red: 155/255.0, green: 225/255.0, blue: 130/255.0, alpha: 1.0)
        case .completed:
            return UIColor(red: 112/255.0, green: 154/255.0, blue: 225/255.0, alpha: 1.0)
        case .planned:
            return UIColor(red: 225/255.0, green: 215/255.0, blue: 124/255.0, alpha: 1.0)
        case .onHold:
            return UIColor(red: 211/255.0, green: 84/255.0, blue: 0/255.0, alpha: 1.0)
        case .dropped:
            return UIColor(red: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1.0)
            
        }
    }
}

protocol LibraryEntryDataSource: ItemViewControllerDataSource {
    func didSet(filter: LibraryViewController.Filter)
}

/// A struct which holds the datasources
struct LibraryViewDataSource {
    
    enum Errors: Error {
        case invalidSources(description: String)
    }
    
    typealias StatusDataSource = [LibraryEntry.Status: LibraryEntryDataSource]
    var anime: StatusDataSource
    var manga: StatusDataSource
    
    /// Create library data that holds all `LibraryViewDataSource` needed for `LibraryViewController`
    ///
    /// - Important: All statuses must have a data source.
    ///
    /// - Parameters:
    ///   - anime: A dictionary of anime data sources
    ///   - manga: A dictionary of manga data sources
    /// - Throws: `Errors.invalidSources(:)` if there were not enough data sources.
    init(anime: StatusDataSource, manga: StatusDataSource) throws {
        guard anime.count == LibraryEntry.Status.all.count else {
            throw Errors.invalidSources(description: "Anime - All statuses must have a datasource")
        }
        
        guard manga.count == LibraryEntry.Status.all.count else {
            throw Errors.invalidSources(description: "Manga - All statuses must have a datasource")
        }
        
        self.anime = anime
        self.manga = manga
    }
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
        }
        
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
