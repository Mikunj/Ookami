//
//  StubCacheObject.swift
//  Ookami
//
//  Created by Maka on 27/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import RealmSwift
@testable import OokamiKit

class StubCacheObject: Object, Cacheable {
    
    dynamic var id = -1
    dynamic var localLastUpdate: Date?
    dynamic var clearFromCache: Bool = true
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    func canClearFromCache() -> Bool {
        return clearFromCache
    }
}

extension StubCacheObject: GettableObject { typealias T = StubCacheObject }
