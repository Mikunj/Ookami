//
//  CacheManagerSpec.swift
//  Ookami
//
//  Created by Maka on 27/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import RealmSwift

private class StubCacheManager: CacheManager {
    var deleteBlock: () -> () = {}
    
    override func deleteFromCache<T:Object>(object: T) {
        deleteBlock()
        super.deleteFromCache(object: object)
    }
}

class CacheManagerSpec: QuickSpec {
    
    override func spec() {
        describe("Cache Manager") {
            
            var realm: Realm!
            
            beforeEach {
                realm = RealmProvider().realm()
            }
            
            afterEach {
                try! realm.write {
                    realm.deleteAll()
                }
            }
            
            context("Registering") {
                it("should correctly register a class for cache") {
                    let m = CacheManager()
                    expect(m.registered).to(haveCount(0))
                    m.register(StubCacheObject.self)
                    expect(m.registered).to(haveCount(1))
                }
            }
            
            context("Clearing") {
                var m: StubCacheManager {
                    let manager = StubCacheManager()
                    manager.register(StubCacheObject.self)
                    return manager
                }
                
                context("Last updated") {
                    
                    context("should not call delete function") {
                        it("if lastUpdated is not set") {
                            let o = StubCacheObject()
                            o.id = 1
                            o.localLastUpdate = nil
                            
                            try! realm.write {
                                realm.add(o)
                            }
                            
                            var deleteCalled: Bool = false
                            let manager = m
                            manager.deleteBlock = {
                                deleteCalled = true
                            }
                            
                            manager.clearCache()
                            expect(deleteCalled).to(beFalse())
                        }
                        
                        it("if object has not passed cache time") {
                            let o = StubCacheObject()
                            o.id = 1
                            o.localLastUpdate = Date()
                            
                            try! realm.write {
                                realm.add(o)
                            }
                            
                            var deleteCalled: Bool = false
                            let manager = m
                            manager.deleteBlock = {
                                deleteCalled = true
                            }
                            
                            manager.clearCache()
                            expect(deleteCalled).to(beFalse())
                            
                        }
                    }
                    
                    context("should call delete function") {
                        it("if object has passed cache time") {
                            let manager = m
                            
                            let o = StubCacheObject()
                            o.id = 1
                            
                            let time = m.cacheTime + 100
                            o.localLastUpdate = Calendar.current.date(byAdding: .second, value: -time, to: Date())
                            
                            try! realm.write {
                                realm.add(o)
                            }
                            
                            var deleteCalled: Bool = false
                            manager.deleteBlock = {
                                deleteCalled = true
                            }
                            
                            manager.clearCache()
                            expect(deleteCalled).to(beTrue())
                        }
                    }
                
                }
                
                context("Deleting") {
                    it("should not delete if we can't clear from cache") {
                        let manager = m
                        
                        let o = StubCacheObject()
                        o.id = 1
                        o.clearFromCache = false
                        
                        let time = m.cacheTime + 100
                        o.localLastUpdate = Calendar.current.date(byAdding: .second, value: -time, to: Date())

                        try! realm.write {
                            realm.add(o, update: true)
                        }
           
                        manager.clearCache()
                        expect(StubCacheObject.get(withId: 1)).toNot(beNil())
                    }
                    
                    it("should delete if we can clear it from cache") {
                        let manager = m
                        
                        let o = StubCacheObject()
                        o.id = 1
                        o.clearFromCache = true
                        
                        let time = m.cacheTime + 100
                        o.localLastUpdate = Calendar.current.date(byAdding: .second, value: -time, to: Date())
                        
                        try! realm.write {
                            realm.add(o)
                        }
                        
                        manager.clearCache()
                        expect(StubCacheObject.get(withId: 1)).to(beNil())
                    }
                }
            }
        }
    }
}
