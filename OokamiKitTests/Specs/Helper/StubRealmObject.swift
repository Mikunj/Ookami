//
//  StubRealmObject.swift
//  Ookami
//
//  Created by Maka on 8/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
import OokamiKit
import SwiftyJSON

class StubRealmObject: Object {
    dynamic var id = -1
    dynamic var data = ""
    
    override static func primaryKey() -> String {
        return "id"
    }
}

extension StubRealmObject: GettableObject { typealias T = StubRealmObject }
extension StubRealmObject: JSONParsable {
    
    public static var typeString: String { return "testStub" }

    public static func parse(json: JSON) -> StubRealmObject? {
        guard let id = json["id"].int else {
            return nil
        }
        
        let o = StubRealmObject()
        o.id = id
        return o
    }
}
