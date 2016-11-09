//
//  RealmGettableObjectSpec.swift
//  Ookami
//
//  Created by Maka on 9/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import RealmSwift

class RealmGettableObjectSpec: QuickSpec {
    
    override func spec() {
        describe("Realm Gettable objects") {
            var realm: Realm!
            
            beforeEach {
                realm = RealmProvider.realm()
            }
            
            afterEach {
                try! realm.write {
                    realm.deleteAll()
                }
            }
            
            context("Fetching") {
                it("should be able to fetch an object from the database") {
                    TestHelper.create(object: StubRealmObject.self, inRealm: realm, amount: 1) { index, object in
                        object.id = 1
                    }
                    
                    let another = StubRealmObject.get(withId: 1)
                    expect(another).toNot(beNil())
                }
                
                it("should be able to fetch multiple objects from the database") {
                    var ids: [Int] = []
                    TestHelper.create(object: StubRealmObject.self, inRealm: realm, amount: 3) { index, object in
                        object.id = index
                        ids.append(index)
                    }
                    
                    let objects = StubRealmObject.get(withIds: ids)
                    expect(objects).to(haveCount(3))
                }
                
                it("should be able to fetch all objects from the database") {
                    TestHelper.create(object: StubRealmObject.self, inRealm: realm, amount: 5) { index, object in
                        object.id = index
                    }
                    let objects = StubRealmObject.all()
                    expect(objects).to(haveCount(5))
                }
                
                it("should return a nil user if no id is found") {
                    let another = StubRealmObject.get(withId: 1)
                    expect(another).to(beNil())
                }
            }
        }
    }
    
}
