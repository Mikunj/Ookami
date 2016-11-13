//
//  LibraryGetRequestSpec.swift
//  Ookami
//
//  Created by Maka on 9/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import Alamofire
import RealmSwift

class LibraryGETRequestSpec: QuickSpec {
    override func spec() {
        describe("LibraryGETRequest") {
            
            var request: LibraryGETRequest!
            var realm: Realm!
            
            beforeEach {
                realm = RealmProvider.realm()
                request = LibraryGETRequest(userID: 1, relativeURL: "/test", headers: ["test": "test"])
            }
            
            afterEach {
                let realm = RealmProvider.realm()
                try! realm.write {
                    realm.deleteAll()
                }
            }
            
            context("Entries") {
                it("should correctly return entries from the latest filters") {
                    var index = 1
                    
                    //Completed, anime
                    TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 3) { i, object in
                        object.id = index
                        object.media = Media(value: [object.id, 1, "anime"])
                        object.status = .completed
                        object.userID = 1
                        index += 1
                    }
                    
                    //Current, manga
                    TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 2) { i, object in
                        object.id = index
                        object.media = Media(value: [object.id, 2, "manga"])
                        object.status = .current
                        object.userID = 2
                        index += 1
                    }
                    
                    let r = (request.copy() as! LibraryGETRequest)
                    
                    r.filter([.user(id: 1), .media(type: .anime), .status(.completed)])
                    expect(r.getEntries()).to(haveCount(3))
                    
                    r.filter([.user(id: 2), .media(type: .manga), .status(.current)])
                    expect(r.getEntries()).to(haveCount(2))
                }
                
                it("Should correctly return entries that match request criteria") {
                    //let
                    //request.filter([.user(id: 1), .media(type: .anime), .status(.completed)])
                    var index = 1
                    
                    //Completed, anime
                    TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 4) { i, object in
                        object.id = index
                        object.media = Media(value: [object.id, 1, "anime"])
                        object.status = .completed
                        object.userID = 1
                        index += 1
                    }
                    
                    //Current, manga
                    TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 3) { i, object in
                        object.id = index
                        object.media = Media(value: [object.id, 2, "manga"])
                        object.status = .current
                        object.userID = 1
                        index += 1
                    }
                    
                    //Completed
                    TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 2) { i, object in
                        object.id = index
                        object.status = .completed
                        object.userID = 1
                        index += 1
                    }
                    
                    //Completed, different user
                    TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 5) { i, object in
                        object.id = index
                        object.status = .current
                        object.userID = 2
                        index += 1
                    }
                    
                    //Test with no filters
                    let rUser = (request.copy() as! LibraryGETRequest)
                    rUser.filter(.user(id: 1))
                    expect(rUser.getEntries()).to(haveCount(9))
                    rUser.filter(.user(id: 2))
                    expect(rUser.getEntries()).to(haveCount(5))
                    
                    //Testing media filters + status
                    let rAnimeCompleted = (request.copy() as! LibraryGETRequest)
                    rAnimeCompleted.filter([.user(id: 1), .media(type: .anime), .status(.completed)])
                    expect(rAnimeCompleted.getEntries()).to(haveCount(4))
                    
                    let rMangaCurrent = (request.copy() as! LibraryGETRequest)
                    rMangaCurrent.filter([.user(id: 1), .media(type: .manga), .status(.current)])
                    expect(rMangaCurrent.getEntries()).to(haveCount(3))
                    
                    //Testing only status filter
                    let rStatus = (request.copy() as! LibraryGETRequest)
                    rStatus.filter(.status(.completed))
                    expect(rStatus.getEntries()).to(haveCount(6))
                    
                    //Test media only
                    let rMediaFilter = request.copy() as! LibraryGETRequest
                    rMediaFilter.filter(.media(type: .manga))
                    expect(rMediaFilter.getEntries()).to(haveCount(3))
                    
                    rMediaFilter.filter(.media(type: .anime))
                    expect(rMediaFilter.getEntries()).to(haveCount(4))
                }
            }
            
            context("Building request") {
                it("should build the request correctly") {
                    let r = request.build()
                    expect(r.relativeURL).to(equal(request.url))
                    expect(r.headers).to(equal(request.headers))
                    expect(r.method).to(equal(HTTPMethod.get))
                }
            }
            
            context("Copying") {
                it("should make a clean copy") {
                    request.include(.user)
                    request.page(offset: 1)
                    
                    let r = request.copy() as! LibraryGETRequest
                    request.filter(.user(id: 2))
                    request.exclude(.user)
                    request.page(offset: 0)
                    
                    expect(r.includes).to(contain("user"))
                    expect(r.userID).to(equal(1))
                    expect(r.page.offset).to(equal(1))
                }
            }
            
            context("Filters") {
                it("should correctly modify userID") {
                    request.filter(.user(id: 1))
                    expect(request.userID).to(equal(1))
                    request.filter(.user(id: 2))
                    expect(request.userID).to(equal(2))
                    
                    request.filter([.user(id: 3), .user(id: 4)])
                    expect(request.userID).to(equal(4))
                    expect(request.filters).to(haveCount(0))
                }
                
                it("should correctly add multiple filters") {
                    request.filter([.media(type: .anime), .status(.completed)])
                    expect(request.filters).to(haveCount(2))
                }
                
                it("should return filters correctly") {
                    request.filter([.user(id: 1), .media(type: .anime), .status(.completed)])
                    var filters = request.getFilters()
                    expect(filters["user_id"] as? Int).to(equal(1))
                    expect(filters["media_type"] as? String).to(equal("Anime"))
                    expect(filters["status"] as? Int).to(equal(3))
                }
                
                it("should build the request correctly") {
                    request.filter([.user(id: 1), .media(type: .anime), .status(.completed)])
                    let r = request.build()
                    expect(r.parameters?.keys).to(haveCount(3))
                }
            }
            
            context("Includes") {
                it("should include and exclude info correctly") {
                    request.include([.genres, .user])
                    expect(request.includes).to(contain(["media.genres", "user"]))
                    request.exclude(.genres)
                    request.exclude(.user)
                    
                    request.include(.genres)
                    expect(request.includes).toNot(contain("user"))
                }
                
                it("should build the request correctly") {
                    request.include([.genres, .user])
                    let r = request.build()
                    expect(r.parameters?["include"] as? String).to(equal("media.genres,user"))
                }
            }
            
            context("Page") {
                it("should adjust page info accordingly") {
                    request.page(offset: 1).page(limit: 2)
                    expect(request.page.offset).to(equal(1))
                    expect(request.page.limit).to(equal(2))
                    
                    request.page(offset: -1).page(limit: -1)
                    expect(request.page.offset).to(equal(0))
                    expect(request.page.limit).to(equal(0))
                }
                
                it("should adjust offests correctly") {
                    request.page(limit: 50)
                    request.nextPage()
                    expect(request.page.offset).to(equal(50))
                    
                    request.page(limit: 20)
                    request.prevPage()
                    expect(request.page.offset).to(equal(30))
                    
                    request.page(offset: 0)
                    request.page(limit: 50)
                    request.nextPage(maxOffset: 40)
                    expect(request.page.offset).to(equal(40))
                    
                    request.page(offset: 100)
                    request.page(limit: 50)
                    request.prevPage(maxOffset: 40)
                    expect(request.page.offset).to(equal(40))
                }
                
                it("should build the request correctly") {
                    request.page(offset: 1).page(limit: 2)
                    let r = request.build()
                    expect(r.parameters?["page"] as? [String: Int]).to(equal(["offset": 1, "limit": 2]))
                }
            }
            
        }
    }
}
