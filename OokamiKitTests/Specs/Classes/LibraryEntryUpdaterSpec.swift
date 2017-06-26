//
//  LibraryEntryUpdaterSpec.swift
//  Ookami
//
//  Created by Maka on 11/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
@testable import OokamiKit

class LibraryEntryUpdaterSpec: QuickSpec {
    
    override func spec() {
        describe("Library Entry Editor") {
            var testRealm: Realm!
            
            beforeEach {
                testRealm = RealmProvider().realm()
            }
            
            afterEach {
                try! testRealm.write {
                    testRealm.deleteAll()
                }
            }
            
            context("Updating") {
                context("Progress") {
                    
                    var entryWithAnime: LibraryEntry!
                    
                    beforeEach {
                        TestHelper.create(object: Anime.self, inRealm: testRealm, amount: 1) { _, anime in
                            anime.id = 1
                            anime.episodeCount = 10
                        }
                        
                        entryWithAnime = LibraryEntry()
                        entryWithAnime.id = 1
                        entryWithAnime.media = Media(value: [1, 1, "anime"])
                    }
                    
                    it("should update if media doesn't have max") {
                        TestHelper.create(object: Anime.self, inRealm: testRealm, amount: 1) { _, anime in
                            anime.id = 2
                        }
                        let e = LibraryEntry()
                        e.id = 2
                        e.media = Media(value: [2, 2, "anime"])
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        
                        updater.update(progress: 9999)
                        expect(updater.entry.progress).to(equal(9999))
                        
                    }
                    
                    it("should update progress and cap the values") {
                        
                        let updater = LibraryEntryUpdater(entry: entryWithAnime)
                        
                        updater.update(progress: 5)
                        expect(updater.entry.progress).to(equal(5))
                        
                        updater.update(progress: 0)
                        expect(updater.entry.progress).to(equal(0))
                        
                        updater.update(progress: -1)
                        expect(updater.entry.progress).to(equal(0))
                        
                        updater.update(progress: 10)
                        expect(updater.entry.progress).to(equal(10))
                        
                        updater.update(progress: 11)
                        expect(updater.entry.progress).to(equal(10))
                    }
                    
                    it("should set the status to completed if progress hit max") {
                        let updater = LibraryEntryUpdater(entry: entryWithAnime)
                        updater.update(progress: 10)
                        expect(updater.entry.status).to(equal(LibraryEntry.Status.completed))
                    }
                }
                
                context("Status") {
                    it("should correctly change the status") {
                        let e = LibraryEntry()
                        e.progress = 0
                        e.status = .planned
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        
                        updater.update(status: .current)
                        expect(updater.entry.status).to(equal(LibraryEntry.Status.current))
                        expect(updater.entry.progress).to(equal(0))
                    }
                    
                    it("should set the progress to max if set to completed") {
                        
                        TestHelper.create(object: Anime.self, inRealm: testRealm, amount: 1) { _, anime in
                            anime.id = 1
                            anime.episodeCount = 10
                        }
                        
                        let e = LibraryEntry()
                        e.id = 1
                        e.media = Media(value: [1, 1, "anime"])
                        e.progress = 0
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        updater.update(status: .completed)
                        expect(updater.entry.progress).to(equal(10))
                    }
                    
                    it("should set the started at time if not set when moving to current") {
                        let e = LibraryEntry()
                        e.id = 1
                        e.startedAt = nil
                        e.status = .planned
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        updater.update(status: .current)
                        expect(updater.entry.startedAt).toNot(beNil())
                    }
                    
                    it("should not set start time if it has been set when moving to current") {
                        let date = Date()
                        let e = LibraryEntry()
                        e.id = 1
                        e.startedAt = date
                        e.status = .planned
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        updater.update(status: .current)
                        expect(updater.entry.startedAt).to(equal(date))
                    }
                    
                    it("should set the started at and finished at time if moving to completed") {
                        let e = LibraryEntry()
                        e.id = 1
                        e.startedAt = nil
                        e.finishedAt = nil
                        e.status = .planned
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        updater.update(status: .completed)
                        expect(updater.entry.startedAt).toNot(beNil())
                        expect(updater.entry.finishedAt).toNot(beNil())
                    }
                    
                    it("should update reconsume count if set to completed and entry was being reconsumed") {
                        let e = LibraryEntry()
                        e.id = 1
                
                        e.reconsumeCount = 0
                        e.reconsuming = true
                        
                        var updater = LibraryEntryUpdater(entry: e)
                        
                        //Shouldn't be set if not completed
                        updater.update(status: .current)
                        expect(updater.entry.reconsumeCount).to(equal(0))
                        expect(updater.entry.reconsuming).to(beTrue())
                        
                        //should be set if reconsuming
                        updater.update(status: .completed)
                        expect(updater.entry.reconsumeCount).to(equal(1))
                        expect(updater.entry.reconsuming).to(beFalse())
                        
                        //Shouldn't be set if not reconsuming
                        e.reconsumeCount = 0
                        e.reconsuming = false
                        
                        updater = LibraryEntryUpdater(entry: e)
                        
                        updater.update(status: .completed)
                        expect(updater.entry.reconsumeCount).to(equal(0))
                        expect(updater.entry.reconsuming).to(beFalse())
                    }
                }
                
                context("Rating") {
                    it("should not update ratings if not valid") {
                        let e = LibraryEntry()
                        e.rating = 3
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        
                        let invalid = [1, 21]
                        for value in invalid {
                            updater.update(rating: value)
                            expect(updater.entry.rating).to(equal(3))
                        }
                    }
                    
                    it("should update rating if it's valid") {
                        let e = LibraryEntry()
                        e.rating = 1
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        
                        let valid = [0, 2, 10, 20]
                        for value in valid {
                            updater.update(rating: value)
                            expect(updater.entry.rating).to(equal(value))
                        }
                    }
                }
                
                context("Notes") {
                    it("should update the notes") {
                        let e = LibraryEntry()
                        e.notes = ""
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        
                        updater.update(notes: "hi")
                        expect(updater.entry.notes).to(equal("hi"))
                    }
                }
                
                context("Reconsuming") {
                    it("should update reconsuming") {
                        let e = LibraryEntry()
                        e.reconsuming = false
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        updater.update(reconsuming: true)
                        expect(updater.entry.reconsuming).to(beTrue())
                    }
                    
                    it("should reset the entry if reconsuming is set to true and the status is completed") {
                        let e = LibraryEntry()
                        e.progress = 5
                        e.status = .planned
                        
                        var updater = LibraryEntryUpdater(entry: e)
                        updater.update(reconsuming: true)
                        
                        expect(updater.entry.progress).to(equal(5))
                        expect(updater.entry.status).to(equal(LibraryEntry.Status.planned))
                        
                        e.status = .completed
                        updater = LibraryEntryUpdater(entry: e)
                        
                        updater.update(reconsuming: true)
                        expect(updater.entry.progress).to(equal(0))
                        expect(updater.entry.status).to(equal(LibraryEntry.Status.current))
                    }
                }
                
                context("Reconume count") {
                    it("should update the count correctly") {
                        let e = LibraryEntry()
                        e.reconsumeCount = 0
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        updater.update(reconsumeCount: 1)
                        expect(updater.entry.reconsumeCount).to(equal(1))
                    }
                }
                
                context("Private") {
                    it("should update the private bool correctly") {
                        let e = LibraryEntry()
                        e.isPrivate = false
                        
                        let updater = LibraryEntryUpdater(entry: e)
                        updater.update(isPrivate: true)
                        expect(updater.entry.isPrivate).to(beTrue())
                    }
                }
            }

        }
    }
}
