//
//  Cacheable.swift
//  Ookami
//
//  Created by Maka on 27/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

///Protocol for object cache
protocol Cacheable {
    
    ///The last time object was updated
    var localLastUpdate: Date? { get set }
    
    ///Function to check whether we can clear the object from cache
    ///The default is `true`
    func canClearFromCache() -> Bool
    
    ///Function which gets called before object is cleared from cache
    ///This is an optional function
    func willClearFromCache()
}

extension Cacheable {
    
    /// Check whether the object can be cleared from cache
    ///
    /// - Returns: Whether object can be cleared from cache
    func canClearFromCache() -> Bool {
        return true
    }
    
    ///Function which gets called before object is cleared from cache
    func willClearFromCache() {}
}
