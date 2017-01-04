//
//  UserLibraryViewDataSource.swift
//  Ookami
//
//  Created by Maka on 4/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import OokamiKit

/// A struct which holds the datasources
struct UserLibraryViewDataSource {
    
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
