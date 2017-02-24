//
//  AnimeFilterViewController.swift
//  Ookami
//
//  Created by Maka on 22/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit
import OokamiKit

//TODO: Maybe add a clear button which sets the filter to default?

class AnimeFilterViewController: BaseMediaFilterViewController {
    
    //The block that gets called upon saving
    fileprivate var onSave: (AnimeFilter) -> Void
    
    //The current filter we are editing
    fileprivate var filter: AnimeFilter
    
    /// Create an anime filter view controller.
    ///
    /// - Parameters:
    ///   - filter: The anime filter.
    ///   - onSave: The block which gets called upon save. It passes back the new anime filter.
    init(filter: AnimeFilter, onSave: @escaping (AnimeFilter) -> Void) {
        self.onSave = onSave
        self.filter = filter.copy()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(filter:onSave:) instead.")
    }
    
    override func didSave() {
        onSave(filter)
        super.didSave()
    }
    
    override func reload() {
        filterView.filters = filters()
    }
}

extension AnimeFilterViewController {
    
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
        
        let values = [1, 13, 26, 50, 100].map { String($0) }
        let initial = String(filter.episodes.start)
        
        let epFilter = SingleValueFilter(name: "Min",
                                         title:"Min Episodes",
                                         values: values,
                                         selectedValue: initial,
                                         onChange: { index, value in
                                            
                                            guard let episode = Int(value) else {
                                                return
                                            }
                                            
                                            //We need to make sure that the start episode is less than the end episode
                                            if let end = self.filter.episodes.end,
                                                end < episode {
                                                self.filter.episodes.end = episode
                                            }
                                            
                                            self.filter.episodes.start = episode
                                            self.reload()
        })
        
        return epFilter
    }
    
    private func maxEpisodeFilter() -> Filter {
        
        
        //We add "∞" because that means to the end of time
        var values = ["∞"]
        
        let minEpisodes = self.filter.episodes.start
        let episodes = [1, 13, 26, 50, 100]
        let minIndex = episodes.index(of: minEpisodes) ?? 0
        
        //Only add the episodes after the min episode
        for i in minIndex..<episodes.count {
            values.append(String(episodes[i]))
        }
        
        let initial = self.filter.episodes.end?.description ?? "∞"
        
        let epFilter = SingleValueFilter(name: "Max",
                                         title: "Max Episodes",
                                         values: values,
                                         selectedValue: initial,
                                         onChange: { index, value in
                                            self.filter.episodes.end = index == 0 ? nil : Int(value)
                                            self.reload()
        })
        
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
