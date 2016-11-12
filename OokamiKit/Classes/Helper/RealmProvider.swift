//
//  RealmProvider.swift
//  Ookami
//
//  Created by Maka on 5/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift

public class RealmProvider {
    
    //Disable initializer
    private init() {}
    
    /// Get a realm instance. This works the same way as calling try! Realm()
    /// Therefore, you should follow it's guidelines such as not using an instance across threads. Instead call this again on the new thread to recieve another instance.
    ///
    /// This is a utility function which helps with testing. If a class of 'XCTest' is detected then an in-memory realm is made and returned. Else it just returns a normal instance.
    ///
    /// - Returns: A normal realm instance or an in-memory instance if being called within an XCTest class
    public class func realm() -> Realm {
        if let _ = NSClassFromString("XCTest") {
            return try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "realm-test-id"))
        } else {
            return try! Realm();
            
        }
    }

}
