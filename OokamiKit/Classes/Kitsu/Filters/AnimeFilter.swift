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
            episodes.capValues(min: 0, max: 99999)
            episodes.applyCorrection()
        }
    }
    
    //The age rating of the anime to filter
    public var ageRatings: [AgeRating] = []
    
    //The streamer to filter
    public var streamers: [Streamer] = []
    
    //The seasons to filter
    public var seasons: [Season] = []
    
    public override init() {
        episodes = RangeFilter(start: 0, end: nil)
        super.init()
    }
    
    public override func construct() -> [String : Any] {
        var dict = super.construct()
        
        //Episode count
        dict["episodeCount"] = episodes.description
        
        //Age rating
        if ageRatings.count > 0 {
            dict["ageRating"] = ageRatings.map { $0.rawValue.uppercased() }
        }
        
        //Season
        if seasons.count > 0 {
            dict["season"] = seasons.map { $0.rawValue }
        }
        
        //Streamers
        if streamers.count > 0 {
            dict["streamers"] = streamers.map { $0.rawValue.capitalized }
        }
        
        return dict
    }
}

extension AnimeFilter {
    
    //The seasons to filter by
    public enum Season: String {
        case spring
        case summer
        case fall
        case winter
        
        static let all: [Season] = [.spring, .summer, .fall, .winter]
    }
    
    //The list of streamers which offer the anime
    public enum Streamer: String {
        case hulu
        case funimation
        case crunchyroll
        case viewstar
        case daisuki
        case netflix
        
        public static let all: [Streamer] = [.hulu, .funimation, .crunchyroll, .viewstar, .daisuki, .netflix]
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
