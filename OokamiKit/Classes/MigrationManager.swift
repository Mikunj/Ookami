//
//  MigrationManager.swift
//  Ookami
//
//  Created by Maka on 19/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

///A class used to handle data migration
public class MigrationManager {
    
    public init() {}
    
    /// Apply migrations to the Realm
    public func applyMigrations() {
        let schemaVersion: UInt64 = 1
        let migrationBlock: MigrationBlock =  { migration, oldSchemaVersion in
            self.migrateTo_1(from: oldSchemaVersion, migration: migration)
        }
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: schemaVersion, migrationBlock: migrationBlock)
    }
    
    //MARK:- Migrations
    //Please use the format: private func migrateTo_[new](from schema: UInt64, migration: Migration)
    
    private func migrateTo_1(from schema: UInt64, migration: Migration) {
        guard schema < 1 else {
            return
        }
        
        //Anime
        // => [Added] nsfw
        // => [Added] popularityRank
        // => [Added] ratingRank
        migration.enumerateObjects(ofType: Anime.className()) { _, new in
            new?["nsfw"] = false
            new?["popularityRank"] = -1
            new?["ratingRank"] = -1
        }
        
        //Manga
        // => [Added] ageRating
        // => [Added] ageRatingGuide
        // => [Added] nsfw
        // => [Added] popularityRank
        // => [Added] ratingRank
        // => [Added] serialization
        migration.enumerateObjects(ofType: Manga.className()) { _, new in
            new?["ageRating"] = ""
            new?["ageRatingGuide"] = ""
            new?["nsfw"] = false
            new?["popularityRank"] = -1
            new?["ratingRank"] = -1
            new?["serialization"] = ""
        }
    }
    
}
