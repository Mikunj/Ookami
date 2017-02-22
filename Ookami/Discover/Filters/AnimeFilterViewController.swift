//
//  AnimeFilterViewController.swift
//  Ookami
//
//  Created by Maka on 22/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit
import Cartography

class AnimeFilterViewController: UIViewController {
    
    //The filter view
    var filterView: FilterViewController!
    
    init(filter: AnimeFilter) {
        super.init(nibName: nil, bundle: nil)
        filterView = FilterViewController(filters: filters(from: filter))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(filter:) instead.")
    }
    
    func filters(from animeFilter: AnimeFilter) -> [Filter] {
        //Year
        //Score
        //Episodes
        
        //Type
        let type = MultiValueFilter(name: "Type", values: Anime.SubType.all.map { $0.rawValue }, selectedValues: animeFilter.subtypes.map { $0.rawValue })
        
        //Rating
        //Seasons
        //Genres
        //Streamers
        return [type]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Theme.ControllerTheme().backgroundColor
        
        //Add the filter view
        self.addChildViewController(filterView)
        self.view.addSubview(filterView.view)
        
        constrain(filterView.view) { view in
            view.edges == view.superview!.edges
        }
        
        filterView.didMove(toParentViewController: self)
        
    }
    
}
