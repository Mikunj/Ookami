//
//  CacheManager.swift
//  Ookami
//
//  Created by Maka on 27/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

///A Class to handle caching of Realm objects
public class CacheManager {
    
    /// A shared instance of the manager
    public static var shared: CacheManager = {
        let manager = CacheManager()
        
        manager.register(Anime.self)
        manager.register(Manga.self)
        manager.register(Genre.self)
        manager.register(LibraryEntry.self)
        manager.register(User.self)
        
        return manager
    }()
    
    //TODO: Change from RealmProvider to Database.provider once it's implemented
    
    /// The classes to manage cache for.
    var registered: [Object.Type] = []
    
    /// The amount of time to cache objects for, in seconds. default: 5 days
    public var cacheTime: Int = 60 * 60 * 24 * 5
    
    /// The realm provider
    public internal(set) var provider: RealmProvider
    
    /// Create a cache manager
    ///
    /// - Parameter realmProvider: The realm provider
    public init(realmProvider: RealmProvider = RealmProvider()) {
        self.provider = realmProvider
    }
    
    /// Register a class to the manager which will then manage its cache automatically
    ///
    /// - Parameter type: The class to manage cache for.
    func register<T: Object>(_ type: T.Type) where T: Cacheable {
        registered.append(type)
    }
    
    /// Clear the cache
    public func clearCache() {
        
        //Get all the objects and check their lastLocalUpdate time
        for type in registered {
            let objects = Array(provider.realm().objects(type))
            for object in objects {
                
                //Make sure this object is cacheable
                guard let c = object as? Cacheable else {
                    continue
                }
                
                //Check if we have a last update time
                guard let lastUpdated = c.localLastUpdate else {
                    continue
                }
                
                //We need to delete object if it's lastUpdateTime + cacheTime is in the past
                if lastUpdated.addingTimeInterval(TimeInterval(cacheTime)) < Date() {
                    deleteFromCache(object: object)
                }
            }
        }
    }
    
    /// Delete an object from cache
    ///
    /// - Parameter object: The object to delete from cache
    func deleteFromCache<T: Object>(object: T) {
        guard let c = object as? Cacheable else {
            return
        }
        
        //Check if we can delete the object
        if c.canClearFromCache() {
            
            //Delete the object
            c.willClearFromCache()
            
            let realm = provider.realm()
            try! realm.write {
                realm.delete(object)
            }
        }
        
    }
}
