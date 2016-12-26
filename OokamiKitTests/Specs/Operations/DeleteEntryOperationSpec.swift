//
//  DeleteEntryOperationSpec.swift
//  Ookami
//
//  Created by Maka on 12/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import RealmSwift

class DeleteEntryOperationSpec: QuickSpec {
    override func spec() {
        describe("DeleteEntryOperation") {
            var queue: OperationQueue!
            var realm: Realm = RealmProvider().realm()
            
            beforeEach {
                queue = OperationQueue()
                queue.maxConcurrentOperationCount = 1
            }
            
            afterEach {
                try! realm.write {
                    realm.deleteAll()
                }
                queue.cancelAllOperations()
            }
            
            context("Deletion Type") {
                it("should not delete entries of a different media type") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 3) { index, object in
                        object.id = index
                        object.userID = 1
                        
                        let m = Media()
                        m.entryID = index
                        m.id = index
                        m.rawType = Media.MediaType.anime.rawValue
                        
                        object.media = m
                    }
                    let operation = DeleteEntryOperation(userID: 1, type: .manga, ids: [0, 1], mode: .inArray, realm: RealmProvider().realm)
                    
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(LibraryEntry.all()).to(haveCount(3))
                            done()
                        }
                        queue.addOperation(operation)
                    }
                }
            }
            
            context("Array modes") {
                
                //Small function that helps with testing methods below
                func testArray(mode: DeleteEntryArrayMode, withUserID id: Int, ids: [Int] = [0, 1], expectedEntryCount: Int) {
                    TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 3) { index, object in
                        object.id = index
                        object.userID = 1
                        
                        let m = Media()
                        m.entryID = index
                        m.id = index
                        m.rawType = Media.MediaType.anime.rawValue
                        
                        object.media = m
                    }
                    let operation = DeleteEntryOperation(userID: id, type: .anime, ids: ids, mode: mode, realm: RealmProvider().realm)
                    
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(LibraryEntry.all()).to(haveCount(expectedEntryCount))
                            done()
                        }
                        queue.addOperation(operation)
                    }
                }

                context("In Array") {
                    
                    it("should delete entries with ids in array") {
                        testArray(mode: .inArray, withUserID: 1, expectedEntryCount: 1)
                    }
                    
                    it("should not delete entries with ids in array that belong to another user") {
                        testArray(mode: .inArray, withUserID: 2, expectedEntryCount: 3)
                    }
                }
                
                context("Not In Array") {
                    
                    it("should delete entries with ids not in array") {
                        testArray(mode: .notInArray, withUserID: 1, expectedEntryCount: 2)
                    }
                
                    it("should not delete entries with ids that don't belong to the user") {
                        testArray(mode: .notInArray, withUserID: 2, expectedEntryCount: 3)
                    }
                }
            }
            
            context("Time Interval") {
                it("should not delete entries before specified time interval") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 5) { index, object in
                        object.id = index
                        object.userID = 1
                        
                        let m = Media()
                        m.entryID = index
                        m.id = index
                        m.rawType = Media.MediaType.anime.rawValue
                        
                        object.media = m
                        
                        let interval = Double(index) * -60.0 //Each entry is a minute apart
                        object.updatedAt = Date(timeIntervalSinceNow: interval)
                    }
                    
                    //Delete any entries that are 2 minutes or older
                    let operation = DeleteEntryOperation(userID: 1, type: .anime, timeInterval: 120, realm: RealmProvider().realm)
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(LibraryEntry.all()).to(haveCount(2))
                            done()
                        }
                        queue.addOperation(operation)
                    }
                }
                
                it("should not delete entries of a different user") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 5) { index, object in
                        object.id = index
                        object.userID = 1
                        
                        let m = Media()
                        m.entryID = index
                        m.id = index
                        m.rawType = Media.MediaType.anime.rawValue
                        
                        object.media = m
                        
                        let interval = Double(index) * -60.0 //Each entry is a minute apart
                        object.updatedAt = Date(timeIntervalSinceNow: interval)
                    }
                    
                    //Delete any entries that are 2 minutes or older
                    let operation = DeleteEntryOperation(userID: 2, type: .anime, timeInterval: 120, realm: RealmProvider().realm)
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(LibraryEntry.all()).to(haveCount(5))
                            done()
                        }
                        queue.addOperation(operation)
                    }
                }
                
            }
            
            
        }
    }
}
