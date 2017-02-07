//
//  MediaFilter.swift
//  Ookami
//
//  Created by Maka on 7/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation

//A class for representing the media filters
public class MediaFilter {
    
    /// The year range to filter
    public var year: RangeFilter<Int> {
        didSet {
            year.capValues(min: 1800, max: 99999)
            year.applyCorrection()
        }
    }
    
    //The rating range between 0.5 and 5.0 inclusive
    public var rating: RangeFilter<Float> {
        didSet {
            //Set the end to 5.0 if it's not set
            rating.end = rating.end ?? 5.0
            rating.capValues(min: 0.5, max: 5.0)
            rating.applyCorrection()
        }
    }
    
    //The genres
    public internal(set) var genres: [String] = []
    
    /// Create a media filter
    public init() {
        year = RangeFilter(start: 1907, end: nil)
        rating = RangeFilter(start: 0.5, end: 5.0)
    }
    
    /// Filter the media by genres.
    ///
    /// - Parameter genres: An array of genres to filter. If empty then it shows All genres.
    public func filter(genres: [Genre]) {
        self.genres = genres.map { $0.name }
    }
    
    /// Convert the filters to a dictionary.
    ///
    /// - Returns: The dictionary representation of the filters
    public func construct() -> [String: Any] {
        var dict: [String: Any] = ["year": year.description]
        
        //Only include rating if it's not the default
        //This is because kitsu doesn't return media which has no rating ...
        if rating.start != 0.5 || rating.end != 5.0 {
            dict["averageRating"] = rating.description
        }
        
        //Filter genres only if we added them
        if genres.count > 0 {
            dict["genres"] = genres
        }
        
        return dict
    }
    
}
