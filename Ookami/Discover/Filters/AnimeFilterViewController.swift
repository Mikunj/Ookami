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
        let episodes = episodeFilter()
        
        //Other
        let type = typeFilter()
        let rating = ratingFilter()
        let streamers = streamerFilter()
        let season = seasonFilter()
        let genre = helper.genreFilter(from: filter)
        
        let other = FilterGroup(name: "", filters: [type, rating, streamers, season, genre])
        
        
        return [year, score, episodes, other]
    }
    
    //MARK:- Episode
    
    func episodeFilter() -> FilterGroup {
        return FilterGroup(name: "Episodes", filters: [minEpisodeFilter(), maxEpisodeFilter()])
    }
    
    private func minEpisodeFilter() -> Filter {
        let epFilter = Filter(name: "Min") { vc, tableView, cell in
            guard let cell = cell else {
                return
            }
            
            let rows = [1, 13, 25, 50, 100]
            let initial = rows.index(of: self.filter.episodes.start) ?? 0
            ActionSheetStringPicker.show(withTitle: "Min Episode", rows: rows, initialSelection: initial, doneBlock: { picker, index, value in
                
                let episode = rows[index]
                
                //We need to make sure that the start episode is less than the end episode
                if let end = self.filter.episodes.end,
                    end < episode {
                    self.filter.episodes.end = episode
                }
                
                self.filter.episodes.start = episode
                self.reload()
            }, cancel: { _ in
            }, origin: cell)
        }
        
        epFilter.secondaryText = String(self.filter.episodes.start)
        epFilter.accessory = .none
        
        return epFilter
    }
    
    private func maxEpisodeFilter() -> Filter {
        let text = self.filter.episodes.end?.description ?? "∞"
        
        let epFilter = Filter(name: "Max") { vc, tableView, cell in
            guard let cell = cell else {
                return
            }
            
            //We add "∞" because that means to the end of time
            var rows = ["∞"]
            
            let minEpisodes = self.filter.episodes.start
            let episodes = [1, 13, 25, 50, 100]
            let minIndex = episodes.index(of: minEpisodes) ?? 0
            
            //Only add the episodes after the min episode
            for i in minIndex..<episodes.count {
                rows.append(String(episodes[i]))
            }
            
            //Get the initial, if we don't have the end that the initial value is inifinty
            let initial = rows.index(of: text) ?? 0
            
            ActionSheetStringPicker.show(withTitle: "Max Episodes", rows: rows, initialSelection: initial, doneBlock: { picker, index, value in
                
                //We don't need to check if start is greater than end because we already put that restrictions on the values
                
                let episode = rows[index]
                self.filter.episodes.end = index == 0 ? nil : Int(episode)
                self.reload()
            }, cancel: { _ in
            }, origin: cell)
        }
        
        epFilter.secondaryText = text
        epFilter.accessory = .none
        
        return epFilter
    }
    
    //MARK:- Other
    
    func streamerFilter() -> Filter {
        return MultiValueFilter(name: "Streamer",
                                values: AnimeFilter.Streamer.all.map { $0.rawValue }.sorted(),
                                selectedValues: filter.streamers.map { $0.rawValue },
                                onChange: { selected in
                                    self.filter.streamers = selected.flatMap { AnimeFilter.Streamer(rawValue: $0) }
        })
    }
    
    func ratingFilter() -> Filter {
        return MultiValueFilter(name: "Rating",
                                values: AnimeFilter.AgeRating.all.map { $0.rawValue },
                                selectedValues: filter.ageRatings.map { $0.rawValue },
                                onChange: { selected in
                                    self.filter.ageRatings = selected.flatMap { AnimeFilter.AgeRating(rawValue: $0) }
        })
    }
    
    func seasonFilter() -> Filter {
        return MultiValueFilter(name: "Season",
                                values: AnimeFilter.Season.all.map { $0.rawValue },
                                selectedValues: filter.seasons.map { $0.rawValue },
                                onChange: { selected in
                                    self.filter.seasons = selected.flatMap { AnimeFilter.Season(rawValue: $0) }
        })
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
