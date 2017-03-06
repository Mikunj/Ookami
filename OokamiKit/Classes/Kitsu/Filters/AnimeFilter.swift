//
//  AnimeFilter.swift
//  Ookami
//
//  Created by Maka on 7/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

//A class for representing Anime filters
public class AnimeFilter: MediaFilter {
    
    //The episode range to filter
    public var episodes: RangeFilter<Int> {
        didSet {
            episodes.capValues(min: 1, max: 99999)
            episodes.applyCorrection()
        }
    }
    
    //The age rating of the anime to filter
    public var ageRatings: [AgeRating] = []
    
    //The streamer to filter
    public var streamers: [Streamer] = []
    
    //The seasons to filter
    public var seasons: [Season] = []
    
    //The subtypes to filter
    public var subtypes: [Anime.SubType] = []
    
    public override init() {
        episodes = RangeFilter(start: 1, end: nil)
        super.init()
    }
    
    public override func construct() -> [String : Any] {
        var dict = super.construct()
        
        //Episode count
        //If ep count is 1 then don't include the request else kitsu won't return anime with no episodes
        if episodes.start != 1 || episodes.end != nil {
            let start = episodes.start == 1 ? "" : String(episodes.start)
            let end = episodes.end?.description ?? ""
            dict["episodeCount"] = "\(start)..\(end)"
        }
        
        //Age rating
        //E.g: R, R18
        if ageRatings.count > 0 {
            dict["ageRating"] = ageRatings.map { $0.rawValue.uppercased() }.joined(separator: ",")
        }
        
        //Season
        if seasons.count > 0 {
            dict["season"] = seasons.map { $0.rawValue }.joined(separator: ",")
        }
        
        //Streamers
        //E.g: Hulu, Crunchyroll
        if streamers.count > 0 {
            dict["streamers"] = streamers.map { $0.rawValue.capitalized }.joined(separator: ",")
        }
        
        //Subtype
        if subtypes.count > 0 {
            dict["subtype"] = subtypes.map { $0.rawValue }.joined(separator: ",")
        }
        
        return dict
    }
    
    
    /// Create a copy of the filter
    ///
    /// - Returns: The filter copy
    public func copy() -> AnimeFilter {
        let f = AnimeFilter()
        f.year = self.year
        f.rating = self.rating
        f.genres = self.genres
        f.ageRatings = self.ageRatings
        f.episodes = self.episodes
        f.seasons = self.seasons
        f.streamers = self.streamers
        f.subtypes = self.subtypes
        f.sort = self.sort
        f.additionalFilters = self.additionalFilters
        return f
    }
}

extension AnimeFilter {
    
    //The seasons to filter by
    public enum Season: String {
        case spring
        case summer
        case fall
        case winter
        
        public static let all: [Season] = [.spring, .summer, .fall, .winter]
    }
    
    //The list of streamers which offer the anime
    //TODO: Might be better later to preload these from /streamers endpoint instead
    public enum Streamer: String {
        case hulu
        case funimation
        case crunchyroll
        case viewster
        case daisuki
        case netflix
        
        public static let all: [Streamer] = [.hulu, .funimation, .crunchyroll, .viewster, .daisuki, .netflix]
    }
    
    /// The age ratings
    public enum AgeRating: String {
        case g
        case pg
        case r
        case r18
        
        public static let all: [AgeRating] = [.g, .pg, .r, .r18]
    }
}
