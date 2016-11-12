//
//  RealmStorable.swift
//  Ookami
//
//  Created by Maka on 12/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

//Protocol for defining if an object can be stored in realm
public protocol RealmStorable {
    
    /// Whether the object can be stored in realm
    ///
    /// - Returns: A Boolean dictating whether object can be stored or not
    func canBeStored() -> Bool
}

//By default all realm object can be stored.
//This can however be changed by object-to-object basis
extension Object: RealmStorable {
    
    public func canBeStored() -> Bool {
        return true
    }
}
