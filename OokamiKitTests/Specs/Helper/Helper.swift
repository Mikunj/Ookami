//
//  TestHelper.swift
//  Ookami
//
//  Created by Maka on 4/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class TestHelper {
    
    /// Load a JSON file
    ///
    /// - Parameter file: The file name without extension
    /// - Returns: the JSON content if valid file/contents
    static func loadJSON(fromFile file: String) -> JSON? {
        if let path = Bundle.main.path(forResource: file, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = JSON(data: data)
                return json
            } catch let error {
                print(error.localizedDescription)
                return nil
            }
        } else {
            print("Invalid filename/path \(file).")
            return nil
        }
    }
    
    /// Creates objects in the realm database
    ///
    /// - Parameters:
    ///   - object: The object class
    ///   - realm: The realm
    ///   - amount: Amount of objects to create
    ///   - objectModifer: A closure for modifying the properties of the object before it is added to the realm. It passes the index and the object as its arguments.
    static func create<T: Object>(object: T.Type, inRealm realm: Realm, amount: Int, objectModifer: (Int, T) -> Void) {
        try! realm.write {
            for i in 0..<amount {
                let object = T()
                objectModifer(i, object)
                realm.add(object, update: true)
            }
        }
    }
}

