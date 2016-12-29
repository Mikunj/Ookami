//
//  DatabaseSpec.swift
//  Ookami
//
//  Created by Maka on 28/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Nimble
import Quick
@testable import OokamiKit
import RealmSwift

class DatabaseSpec: QuickSpec {
    
    override func spec() {
        describe("Database") {
            
            var realm: Realm!
            
            beforeEach {
                realm = RealmProvider().realm()
            }
            
            afterEach {
                try! realm.write {
                    realm.deleteAll()
                }
            }
            
            context("Write") {
                it("should correctly write objects to the database") {
                    let o = StubRealmObject()
                    o.id = 1
                    
                    expect(StubRealmObject.get(withId: 1)).to(beNil())
                    Database().write { realm in
                        realm.add(o)
                    }
                    expect(StubRealmObject.get(withId: 1)).toNot(beNil())
                }
            }
            
            context("Adding/Updating") {
                
                context("one object") {
                    it("should correctly add") {
                        let o = StubRealmObject()
                        o.id = 1
                        
                        
                        expect(StubRealmObject.get(withId: 1)).to(beNil())
                        Database().addOrUpdate(o)
                        expect(StubRealmObject.get(withId: 1)).toNot(beNil())
                    }
                    
                    it("should correctly update") {
                        let o = StubRealmObject()
                        o.id = 1
                        
                        try! realm.write {
                            realm.add(o)
                        }
                    
                        expect(StubRealmObject.get(withId: 1)?.data).to(equal(""))
                        
                        try! realm.write {
                            o.data = "updated"
                        }
                        
                        Database().addOrUpdate(o)
                        expect(StubRealmObject.get(withId: 1)?.data).to(equal("updated"))
                    }
                }
                
                context("Multiple objects") {
                    it("should correctly add") {
                        var objects: [StubRealmObject] = []
                        for i in 0..<3 {
                            let o = StubRealmObject()
                            o.id = i
                            objects.append(o)
                        }
                        
                        expect(StubRealmObject.all()).to(haveCount(0))
                        Database().addOrUpdate(objects)
                        expect(StubRealmObject.all()).to(haveCount(3))
                    }
                    
                    it("should correctly update") {
                        var objects: [StubRealmObject] = []
                        for i in 0..<3 {
                            let o = StubRealmObject()
                            o.id = i
                            objects.append(o)
                        }
                        
                        try! realm.write {
                            realm.add(objects)
                        }
                        
                        expect(StubRealmObject.get(withId: 1)?.data).to(equal(""))
                        
                        try! realm.write {
                            objects[1].data = "updated"
                        }
                        
                        Database().addOrUpdate(objects)
                        expect(StubRealmObject.get(withId: 1)?.data).to(equal("updated"))
                    }
                }
                
                context("Deleting") {
                    it("should correctly delete an object") {
                        let o = StubRealmObject()
                        o.id = 1
                        
                        try! realm.write {
                            realm.add(o)
                        }
                        
                        
                        expect(StubRealmObject.get(withId: 1)).toNot(beNil())
                        Database().delete(o)
                        expect(StubRealmObject.get(withId: 1)).to(beNil())
                    }
                    
                    it("should correctly delete multiple objects") {
                        TestHelper.create(object: StubRealmObject.self, inRealm: realm, amount: 2) { index, object in
                            object.id = index
                        }
                        
                        expect(StubRealmObject.all()).to(haveCount(2))
                        Database().delete(StubRealmObject.all())
                        expect(StubRealmObject.all()).to(haveCount(0))
                    }
                }
                
                context("Cacheable") {
                    it("should update lastLocalUpdate when adding a cacheable object") {
                        let o = StubCacheObject()
                        o.id = 1
                        
                        let date = Date(timeIntervalSince1970: 1)
                        o.localLastUpdate = date
                        
                        Database().addOrUpdate(o)
                        expect(StubCacheObject.get(withId: 1)?.localLastUpdate).toNot(equal(date))
                    }
                }
            }
        }
    }
    
}
