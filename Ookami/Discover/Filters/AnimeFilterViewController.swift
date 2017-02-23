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
import ActionSheetPicker_3_0

class AnimeFilterViewController: UIViewController {
    
    //The filter view
    var filterView: FilterViewController!
    
    //The block that gets called upon saving
    fileprivate var onSave: (AnimeFilter) -> Void
    
    //The current filter we are editing
    fileprivate var filter: AnimeFilter
    
    init(filter: AnimeFilter, onSave: @escaping (AnimeFilter) -> Void) {
        self.onSave = onSave
        self.filter = filter.copy()
        super.init(nibName: nil, bundle: nil)
        filterView = FilterViewController(filters: filters())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(filter:) instead.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        //Add the save and cancel buttons
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didCancel))
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didSave))
        
        self.navigationItem.leftBarButtonItem = cancel
        self.navigationItem.rightBarButtonItem = save
    }
    
    func didCancel() {
        dismiss(animated: true)
    }
    
    func didSave() {
        onSave(filter)
        dismiss(animated: true)
    }
}

extension AnimeFilterViewController {
    
    func reload() {
        filterView.filters = filters()
    }
    
    func filters() -> [FilterGroup] {
        let helper = DiscoverFilterHelper()
        
        let year = helper.yearFilter(from: filter) { self.reload() }
        let score = helper.scoreFilter(from: filter) { self.reload() }
        
        //Episodes
        
        let genre = helper.genreFilter(from: filter)
        
        let other = FilterGroup(name: "", filters: [genre, typeFilter()])
        
        
        //Episodes
        //Seasons
        
        //Streamers
        return [year, score, other]
    }
    
    
    
    //The type filter
    func typeFilter() -> Filter {
        return MultiValueFilter(name: "Type",
                                values: Anime.SubType.all.map { $0.rawValue },
                                selectedValues: filter.subtypes.map { $0.rawValue },
                                onChange: { selected in
                                    self.filter.subtypes = selected.flatMap { Anime.SubType(rawValue: $0) }
        })
    }
}
