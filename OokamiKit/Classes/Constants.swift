//
//  Constants.swift
//  Ookami
//
//  Created by Maka on 26/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation

enum Constants {}

/// Constants for the app
extension Constants {
    
    /// Urls that we use
    enum URL {
        static let kitsu = "https://kitsu.io"
        static let api = "\(kitsu)/api/edge"
        static let authToken = "\(kitsu)/api/oauth/token"
    }
    
    //API endpoints
    enum Endpoints {
        static let users = "/users"
        static let libraryEntries = "/library-entries"
        static let anime = "/anime"
        static let manga = "/manga"
        static let genres = "/genres"
        static let trending = "/trending"
        static let mediaRelationships = "/media-relationships"
    }
    
}
