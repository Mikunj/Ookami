//
//  MangaFilterViewController.swift
//  Ookami
//
//  Created by Maka on 24/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

class MangaFilterViewController: BaseMediaFilterViewController {

    //The block that gets called upon saving
    fileprivate var onSave: (MangaFilter) -> Void
    
    //The current filter we are editing
    fileprivate var filter: MangaFilter
    
    /// Create a manga filter view controller
    ///
    /// - Parameters:
    ///   - filter: The initial manga filter
    ///   - onSave: The block which gets called when save is pressed. Passes back the new manga filter.
    init(filter: MangaFilter, onSave: @escaping (MangaFilter) -> Void) {
        self.onSave = onSave
        self.filter = filter.copy()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(filter:onSave:) instead.")
    }
    
    override func didSave() {
        dismiss(animated: true) {
            self.onSave(self.filter)
        }
    }
    
    override func didClear() {
        self.filter = MangaFilter()
        reload()
    }

    override func reload() {
        filterView.filters = filters()
    }
}

extension MangaFilterViewController {
    
    func filters() -> [FilterGroup] {
        let helper = DiscoverFilterHelper()
        
        let year = helper.yearFilter(from: filter) { self.reload() }
        let score = helper.scoreFilter(from: filter) { self.reload() }
        
        //Other
        let type = typeFilter()
        let genre = helper.genreFilter(from: filter)
        
        let other = FilterGroup(name: "", filters: [type, genre])
        
        
        return [year, score, other]
    }
    
    //The type filter
    func typeFilter() -> Filter {
        return MultiValueFilter(name: "Type",
                                values: Manga.SubType.all.map { $0.rawValue },
                                selectedValues: filter.subtypes.map { $0.rawValue },
                                onChange: { selected in
                                    self.filter.subtypes = selected.flatMap { Manga.SubType(rawValue: $0) }
        })
    }
}

