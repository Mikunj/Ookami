//
//  LibraryServiceSpec.swift
//  Ookami
//
//  Created by Maka on 29/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import RealmSwift
import OHHTTPStubs

class LibraryServiceSpec: QuickSpec {
    
    //OHHTTPStubs is getting messed up in these tests. Need to fix.
    override func spec() {
        describe("Library Service") {
            
            var client: NetworkClient!
            var realm: Realm!
            
            beforeEach {
                
                realm = RealmProvider().realm()
                client = NetworkClient(baseURL: "https://kitsu.io", heimdallr: StubAuthHeimdallr())
            }
            
            afterEach {
                OHHTTPStubs.removeAllStubs()
                try! realm.write {
                    realm.deleteAll()
                }
            }
            
            context("Paginated") {
                it("should add all fetched objects except the library entry to the database") {
                    let entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
                    let animeJSON = TestHelper.loadJSON(fromFile: "anime-hunter-hunter")!
                    
                    let entryID = entryJSON["id"].intValue
                    
                    stub(condition: isHost("kitsu.io")) { _ in
                        let data: [String : Any] = ["data": [entryJSON.dictionaryObject!, animeJSON.dictionaryObject!]]
                        return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                    }
                    
                    waitUntil { done in
                        let _ = LibraryService(client: client).getPaginated(userID: 1, type: .anime, status: .current) { _, error in
                            expect(error).to(beNil())
                            expect(LibraryEntry.get(withId: entryID)).to(beNil())
                            expect(Anime.all()).to(haveCount(1))
                            done()
                        }
                    }
                }
                
                it("should pass error if it occured") {
                    waitUntil { done in
                        stub(condition: isHost("kitsu.io")) { _ in
                            return OHHTTPStubsResponse(error: NetworkClientError.error("failed to get page - Paginated test"))
                        }
                        
                        let _ = LibraryService(client: client).getPaginated(userID: 1, type: .anime, status: .current) { _, error in
                            expect(error).toNot(beNil())
                            done()
                        }
                    }
                    
                }
            }
            
            context("Get") {
                it("should add fetched objects to the database") {
                    let entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
                    
                    stub(condition: isHost("kitsu.io")) { _ in
                        let data: [String : Any] = ["data": entryJSON.dictionaryObject!]
                        return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                    }
                    
                    waitUntil { done in
                        LibraryService(client: client).get(userID: 1, type: .anime, status: .current) { error in
                            expect(error).to(beNil())
                            expect(LibraryEntry.all()).to(haveCount(1))
                            done()
                        }
                    }
                }
                
                it("should return errors if they occured") {
                    stub(condition: isHost("kitsu.io")) { _ in
                        return OHHTTPStubsResponse(error: NetworkClientError.error("failed to get page - Get library"))
                    }
                    
                    waitUntil { done in
                        LibraryService(client: client).get(userID: 1, type: .anime, status: .current) { error in
                            expect(error).toNot(beNil())
                            done()
                        }
                    }
                }
            }
            
            context("Get All") {
                it("should add fetched objects to the database") {
                    let entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
                    
                    stub(condition: isHost("kitsu.io")) { _ in
                        let data: [String : Any] = ["data": entryJSON.dictionaryObject!]
                        return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                    }
                    
                    waitUntil { done in
                        LibraryService(client: client).getAll(userID: 1, type: .anime) { errors in
                            expect(errors).to(beEmpty())
                            expect(LibraryEntry.all()).to(haveCount(1))
                            done()
                        }
                    }
                }
                
                it("should return errors if they occured") {
                    stub(condition: isHost("kitsu.io")) { _ in
                        return OHHTTPStubsResponse(error: NetworkClientError.error("failed to get page"))
                    }
                    
                    waitUntil { done in
                        LibraryService(client: client).getAll(userID: 1, type: .anime) { errors in
                            expect(errors).toNot(beEmpty())
                            done()
                        }
                    }
                }
                
                context("Last fetched") {
                    it("should not update last fetched if an error occured") {
                        stub(condition: isHost("kitsu.io")) { _ in
                            return OHHTTPStubsResponse(error: NetworkClientError.error("failed to get page"))
                        }
                        
                        waitUntil { done in
                            LibraryService(client: client).getAll(userID: 1, type: .anime) { errors in
                                expect(LastFetched.get(withId: 1)).to(beNil())
                                done()
                            }
                        }
                    }
                    
                    it("should update last fetched time for anime") {
                        let entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
                        
                        stub(condition: isHost("kitsu.io")) { _ in
                            let data: [String : Any] = ["data": entryJSON.dictionaryObject!]
                            return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                        }
                        
                        waitUntil { done in
                            LibraryService(client: client).getAll(userID: 1, type: .anime) { errors in
                                expect(LastFetched.get(withId: 1)).toNot(beNil())
                                expect(LastFetched.get(withId: 1)?.anime).toNot(equal(Date(timeIntervalSince1970: 0)))
                                expect(LastFetched.get(withId: 1)?.manga).to(equal(Date(timeIntervalSince1970: 0)))
                                done()
                            }
                        }
                    }
                    
                    it("should update last fetched time for manga") {
                        let entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
                        
                        stub(condition: isHost("kitsu.io")) { _ in
                            let data: [String : Any] = ["data": entryJSON.dictionaryObject!]
                            return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                        }
                        
                        waitUntil { done in
                            LibraryService(client: client).getAll(userID: 1, type: .manga) { errors in
                                expect(LastFetched.get(withId: 1)).toNot(beNil())
                                expect(LastFetched.get(withId: 1)?.anime).to(equal(Date(timeIntervalSince1970: 0)))
                                expect(LastFetched.get(withId: 1)?.manga).toNot(equal(Date(timeIntervalSince1970: 0)))
                                done()
                            }
                        }
                    }

                    it("should use exisiting LastFetched if it exists") {
                        let animeDate = Date(timeIntervalSince1970: 100)
                        TestHelper.create(object: LastFetched.self, inRealm: realm, amount: 1) { _, fetched in
                            fetched.userID = 1
                            fetched.anime = animeDate
                        }
                        
                        let entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
                        
                        stub(condition: isHost("kitsu.io")) { _ in
                            let data: [String : Any] = ["data": entryJSON.dictionaryObject!]
                            return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                        }
                        
                        waitUntil { done in
                            LibraryService(client: client).getAll(userID: 1, type: .manga) { errors in
                                expect(LastFetched.get(withId: 1)).toNot(beNil())
                                expect(LastFetched.get(withId: 1)?.anime).to(equal(animeDate))
                                expect(LastFetched.get(withId: 1)?.manga).toNot(equal(Date(timeIntervalSince1970: 0)))
                                done()
                            }
                        }
                        
                    }
                }
                
                
                context("Entry deletion") {
                    
                    it("should delete entries that are not in the response") {
                        TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 1) { _, entry in
                            entry.id = 1
                            entry.userID = 1
                            entry.media = Media(value: [1, 1, "anime"])
                        }
                        
                        var entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
                        entryJSON["relationships"]["user"]["data"]["id"] = 1
                        
                        stub(condition: isHost("kitsu.io")) { _ in
                            let data: [String : Any] = ["data": entryJSON.dictionaryObject!]
                            return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                        }
                        
                        waitUntil { done in
                            LibraryService(client: client).getAll(userID: 1, type: .anime) { errors in
                                expect(errors).to(beEmpty())
                                expect(LibraryEntry.all()).to(haveCount(1))
                                expect(LibraryEntry.get(withId: 1)).to(beNil())
                                done()
                            }
                        }
                    }
                    
                    it("should only delete entries of type that was passed in") {
                        //We don't want it to delete manga entries for example when we get the anime library
                        
                        TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 1) { _, entry in
                            entry.id = 1
                            entry.userID = 1
                            entry.media = Media(value: [1, 1, "manga"])
                        }
                        
                        var entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
                        entryJSON["relationships"]["user"]["data"]["id"] = 1
                        
                        stub(condition: isHost("kitsu.io")) { _ in
                            let data: [String : Any] = ["data": entryJSON.dictionaryObject!]
                            return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                        }
                        
                        waitUntil { done in
                            LibraryService(client: client).getAll(userID: 1, type: .anime) { errors in
                                expect(errors).to(beEmpty())
                                expect(LibraryEntry.all()).to(haveCount(2))
                                expect(LibraryEntry.get(withId: 1)).toNot(beNil())
                                done()
                            }
                        }
                    }
                    
                    it("should not delete entries if any error occured") {
                        var count = 0
                        
                        TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 1) { _, entry in
                            entry.id = 1
                            entry.userID = 1
                            entry.media = Media(value: [1, 1, "anime"])
                        }
                        
                        var entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
                        entryJSON["relationships"]["user"]["data"]["id"] = 1
                        
                        
                        stub(condition: isHost("kitsu.io")) { _ in
                            count += 1
                            if count < 2 {
                                let data: [String : Any] = ["data": entryJSON.dictionaryObject!]
                                return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                            }
                            
                            return OHHTTPStubsResponse(error: NetworkClientError.error("failed to get page - Entry deletion"))
                        }
                        
                        waitUntil { done in
                            LibraryService(client: client).getAll(userID: 1, type: .anime) { errors in
                                
                                
                                expect(errors).toNot(beEmpty())
                                expect(LibraryEntry.all()).to(haveCount(2))
                                expect(LibraryEntry.get(withId: 1)).toNot(beNil())
                                done()
                            }
                        }
                    }
                    
                    it("should not delete entries if since was set") {
                        TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 1) { _, entry in
                            entry.id = 1
                            entry.userID = 1
                            entry.media = Media(value: [1, 1, "anime"])
                        }
                        
                        var entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
                        entryJSON["relationships"]["user"]["data"]["id"] = 1
                        
                        
                        stub(condition: isHost("kitsu.io")) { _ in
                            let data: [String : Any] = ["data": entryJSON.dictionaryObject!]
                            return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                        }
                        
                        waitUntil { done in
                            LibraryService(client: client).getAll(userID: 1, type: .anime, since: Date()) { errors in
                                expect(errors).to(beEmpty())
                                expect(LibraryEntry.all()).to(haveCount(2))
                                expect(LibraryEntry.get(withId: 1)).toNot(beNil())
                                done()
                            }
                        }
                    }
                    
                }
            }
            
        }
    }
}
