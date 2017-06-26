//
//  LibraryEntrySpec.swift
//  Ookami
//
//  Created by Maka on 5/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON
import RealmSwift

class LibraryEntrySpec: QuickSpec {
    override func spec() {
        describe("Anime") {
            
            let entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
            var testRealm: Realm!
            
            beforeEach {
                testRealm = RealmProvider().realm()
            }
            
            afterEach {
                try! testRealm.write {
                    testRealm.deleteAll()
                }
            }
            
            context("Simple Rating") {
                it("should correctly convert ratings to simple ratings") {
                    let ratings = [2, 7, 8, 13, 14, 19, 20]
                    let simpleRatings: [LibraryEntry.SimpleRating] = [.awful, .awful, .meh, .meh, .good, .good, .great]
                    for i in 0..<ratings.count {
                        let simple = LibraryEntry.SimpleRating.from(rating: ratings[i])
                        expect(simple).to(equal(simpleRatings[i]))
                    }
                    
                    let invalidRatings = [0, 1, 21, 22]
                    for i in 0..<invalidRatings.count {
                        let simple = LibraryEntry.SimpleRating.from(rating: invalidRatings[i])
                        expect(simple).to(beNil())
                    }
                }
                
                it("should correctly convert simple ratings to integer rating") {
                    let simpleRatings: [LibraryEntry.SimpleRating] = [.awful, .meh, .good, .great]
                    let ratings = [2, 8, 14, 20]
                    
                    for i in 0..<simpleRatings.count {
                        let r = simpleRatings[i].toRating()
                        expect(r).to(equal(ratings[i]))
                    }
                }
            }
            
            context("Max Progress") {
                it("should return nil if media is not set") {
                    let e = LibraryEntry()
                    expect(e.maxProgress()).to(beNil())
                }
                
                it("should return nil if media counts are invalid") {
                    TestHelper.create(object: Anime.self, inRealm: testRealm, amount: 1) { _, anime in
                        anime.id = 1
                        anime.episodeCount = -200
                    }
                    
                    TestHelper.create(object: Manga.self, inRealm: testRealm, amount: 1) { _, manga in
                        manga.id = 1
                        manga.chapterCount = -200
                    }
                    
                    let e = LibraryEntry()
                    e.id = 1
                    e.media = Media(value: [1, 1, "anime"])
                    expect(e.maxProgress()).to(beNil())
                    
                    e.media = Media(value: [1, 1, "manga"])
                    expect(e.maxProgress()).to(beNil())
                    
                }
                
                it("should return the correct max progress count") {
                    TestHelper.create(object: Anime.self, inRealm: testRealm, amount: 1) { _, anime in
                        anime.id = 1
                        anime.episodeCount = 100
                    }
                    
                    TestHelper.create(object: Manga.self, inRealm: testRealm, amount: 1) { _, manga in
                        manga.id = 1
                        manga.chapterCount = 200
                    }
                    
                    let e = LibraryEntry()
                    e.id = 1
                    e.media = Media(value: [1, 1, "anime"])
                    expect(e.maxProgress()).to(equal(100))
                    
                    e.media = Media(value: [1, 1, "manga"])
                    expect(e.maxProgress()).to(equal(200))
                }
            }
            
            context("Equatable") {
                it("Should be equal to the same entry") {
                    let e = LibraryEntry()
                    e.id = 1
                    e.progress = 0
                    e.reconsuming = true
                    e.reconsumeCount = 1
                    e.rating = 0
                    e.status = .current
                    e.notes = "hi"
                    e.startedAt = Date(timeIntervalSince1970: 0)
                    e.finishedAt = Date(timeIntervalSince1970: 1)
                    
                    
                    let other = LibraryEntry(value: e)
                    
                    expect(e).to(equal(other))
                }
                
                it("Should not be equal to a different entry") {
                    let e = LibraryEntry()
                    e.id = 1
                    e.progress = 0
                    e.reconsuming = true
                    e.reconsumeCount = 1
                    e.rating = 0
                    e.status = .current
                    e.notes = "hi"
                    e.startedAt = Date(timeIntervalSince1970: 0)
                    e.finishedAt = Date(timeIntervalSince1970: 1)
                    
                    let o = LibraryEntry()
                    o.id = 2
                    o.progress = 0
                    o.reconsuming = false
                    o.reconsumeCount = 10
                    o.rating = 5
                    o.status = .completed
                    o.notes = "hi"
                    e.finishedAt = Date(timeIntervalSince1970: 2)
                    
                    expect(e).toNot(equal(o))
                }
            }
            
            context("Cache") {
                it("should not be able to be cleared from cache if it's part of the current users library") {
                    let currentUser = CurrentUser(heimdallr: StubAuthHeimdallr())
                    currentUser.userID = 999
                    
                    let e = LibraryEntry()
                    e.id = 1
                    e.userID = 999
                    e.currentUser = currentUser
                    
                    let bad = LibraryEntry()
                    bad.id = 2
                    bad.userID = 1000
                    bad.currentUser = currentUser
                    
                    expect(e.canClearFromCache()).to(beFalse())
                    expect(bad.canClearFromCache()).to(beTrue())
                }
                
                it("should delete media when being cleared from cache") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 1) { index, entry in
                        entry.id = 1
                        entry.userID = 1
                        let type: Media.MediaType = .anime
                        entry.media = Media(value: [entry.id, 2, type.rawValue])
                    }
                    
                    expect(LibraryEntry.get(withId: 1)?.media).toNot(beNil())
                    LibraryEntry.get(withId: 1)!.willClearFromCache()
                    expect(LibraryEntry.get(withId: 1)?.media).to(beNil())
                }
            }
            
            context("Get") {
                it("should return entries that belong to a user correctly") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 2) { index, object in
                        object.id = index
                        object.userID = 1
                    }
                    
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 2) { index, object in
                        object.id = 10 + index
                        object.userID = 2
                    }
                    
                    expect(LibraryEntry.belongsTo(user: 1)).to(haveCount(2))
                }
                
                it("Should return entries that belong to a user and are of a given type") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 1) { index, object in
                        object.id = index
                        object.userID = 1
                        object.media = Media(value: [object.id, 1, Media.MediaType.anime.rawValue])
                    }
                    
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 1) { index, object in
                        object.id = 10 + index
                        object.userID = 1
                        object.media = Media(value: [object.id, 1, Media.MediaType.manga.rawValue])
                    }
                    
                    expect(LibraryEntry.belongsTo(user: 1, type: .anime)).to(haveCount(1))
                }
                
                it("Should return entries that belong to a user and have a specific status") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 1) { index, object in
                        object.id = index
                        object.userID = 1
                        object.status = .current
                    }
                    
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 1) { index, object in
                        object.id = 10 + index
                        object.userID = 1
                        object.status = .dropped
                    }
                    
                    expect(LibraryEntry.belongsTo(user: 1, status: .current)).to(haveCount(1))

                }
            }
            
            context("Storing") {
                it("should be able to store if no other entry exists in the database") {
                    let e = LibraryEntry()
                    e.id = 1
                    expect(e.canBeStored()).to(beTrue())
                }
                
                it("should only store entry if the one in the database is old") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 1) { _, object in
                        object.id = 1
                        object.updatedAt = Date(timeIntervalSince1970: 100)
                    }
                    
                    let e = LibraryEntry()
                    e.id = 1
                    e.updatedAt = Date(timeIntervalSince1970: 150)
                    expect(e.canBeStored()).to(beTrue())
                }
                
                it("should store entry with the same update date") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 1) { _, object in
                        object.id = 1
                        object.updatedAt = Date(timeIntervalSince1970: 100)
                    }
                    
                    let e = LibraryEntry()
                    e.id = 1
                    e.updatedAt = Date(timeIntervalSince1970: 100)
                    expect(e.canBeStored()).to(beTrue())
                }
                
            }
            
            context("Modifying") {
                
                it("should correctly change the status") {
                    let e = LibraryEntry()
                    expect(e.status).to(beNil())
                    expect(e.rawStatus).to(equal(""))
                    
                    e.status = .current
                    expect(e.status).to(equal(LibraryEntry.Status.current))
                    expect(e.rawStatus).to(equal("current"))
                }
                
                it("should correctly return user with userID") {
                    let e = LibraryEntry()
                    
                    //Defaults to no user
                    expect(e.user).to(beNil())
                    
                    //Set the id
                    e.userID = 1
                    expect(e.user).to(beNil())
                    
                    //Add the user
                    TestHelper.create(object: User.self, inRealm: testRealm, amount: 1) { index, user in
                        user.id = 1
                        user.name = "bob"
                    }
                    expect(e.user).toNot(beNil())
                    expect(e.user?.name).to(equal("bob"))
                }
                
                it("should correctly return media and retain only 1 copy") {
                    let media = [Media(value: [1, 0, "hi"]), Media(value: [1, 1, "hello"])]
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 2) { index, entry in
                        entry.id = 1
                        entry.media = media[index]
                    }
                    
                    let entry = LibraryEntry.get(withId: 1)
                    expect(entry).toNot(beNil())
                    expect(entry?.media?.id).to(equal(1))
                    
                    //Check to see that only 1 copy has been made
                    expect(testRealm.objects(Media.self)).to(haveCount(1))
                }
            }
            
            context("Parsing") {
                it("should parse an entry JSON correctly") {
                    let e = LibraryEntry.parse(json: entryJSON)
                    expect(e).toNot(beNil())
                    
                    let entry = e!
                    expect(entry.id).to(equal(340253))
                    expect(entry.rawStatus).to(equal("current"))
                    expect(entry.status).to(equal(LibraryEntry.Status.current))
                    expect(entry.progress).to(equal(131))
                    expect(entry.reconsuming).to(beTrue())
                    expect(entry.reconsumeCount).to(equal(0))
                    expect(entry.notes).to(equal(""))
                    expect(entry.isPrivate).to(beTrue())
                    
                    expect(entry.rating).to(equal(20))
                    
                    let d = DateFormatter()
                    d.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
                    let updatedAt = d.date(from: "2016-08-15T11:01:29.181Z")
                    expect(entry.updatedAt).to(equal(updatedAt))
                    
                    let progressedAt = d.date(from: "2017-06-24T14:59:22.951Z")
                    expect(entry.progressedAt).to(equal(progressedAt))
                    
                    let startedAt = d.date(from: "2017-06-23T07:22:43.932Z")
                    expect(entry.startedAt).to(equal(startedAt))
                    
                    let finishedAt = d.date(from: "2017-06-24T14:59:22.951Z")
                    expect(entry.finishedAt).to(equal(finishedAt))
                    
                    expect(entry.userID).to(equal(2875))
                    expect(entry.media).toNot(beNil())
                    expect(entry.media?.id).to(equal(6448))
                    expect(entry.media?.rawType).to(equal("anime"))
                    
                }
                
                it("should not parse a bad JSON") {
                    let j = JSON("bad JSON")
                    let entry = LibraryEntry.parse(json: j)
                    expect(entry).to(beNil())
                }
            }
        }
    }

}
