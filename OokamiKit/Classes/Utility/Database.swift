//
//  Database.swift
//  Ookami
//
//  Created by Maka on 28/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

///A wrapper for realm database
///This is also what enables the CacheManager to work.
public class Database {
    
    ///The realm provider
    var provider: RealmProvider
    
    ///The realm object that other classes can use
    public var realm: Realm {
        return provider.realm()
    }
    
    /// Create a database
    ///
    /// - Parameter provider: The realm provider
    public init(provider: RealmProvider = RealmProvider()) {
        self.provider = provider
    }
    
    /// Write to the database.
    ///
    /// This is just a wrapper function for `realm.write(:)`
    ///
    /// - Parameter block: The block containing actions to perform in the write transaction.
    /// - Returns: A bool which indicates whether the write transaction worked or not.
    @discardableResult public func write(block: (Realm) -> Void) -> Bool {
        do {
            try realm.write {
                block(realm)
            }
        } catch {
            return false
        }
        
        return true
    }
    
    /// Add or Update an object to the database.
    ///
    /// This also updates the `lastLocalUpdate` if the object is cacheable.
    ///
    /// - Parameter object: The object to add to the database.
    /// - Returns: Whether adding was successful or not.
    @discardableResult public func addOrUpdate(_ object: Object) -> Bool {
        updateCacheable(object)
        return write { realm in
            realm.add(object, update: true)
        }
    }
    
    /// Add or Update objects to the database.
    ///
    /// This also updates the `lastLocalUpdate` if an object is cacheable.
    ///
    /// - Parameter objects: The objects to add to the database.
    /// - Returns: Whether adding was successful or not.
    @discardableResult public func addOrUpdate(_ objects: [Object]) -> Bool {
        objects.forEach { updateCacheable($0) }
        return write { realm in
            realm.add(objects, update: true)
        }
    }
    
    /// Delete an object from the database
    ///
    /// - Parameter object: The object to delete
    /// - Returns: Whether deleting was successful or not.
    @discardableResult public func delete(_ object: Object) -> Bool {
        return write { realm in
            realm.delete(object)
        }
    }
    
    /// Checks if an object is `Cacheable` and updates the `lastLocalUpdate`.
    ///
    /// - Parameter object: The object
    private func updateCacheable(_ object: Object) {
        guard var c = object as? Cacheable else {
            return
        }
        
        c.localLastUpdate = Date()
    }
    
    
}
