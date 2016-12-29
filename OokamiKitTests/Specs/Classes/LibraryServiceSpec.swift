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
//    override func spec() {
//        describe("Library Service") {
//            
//            var client: NetworkClient!
//            var realm: Realm!
//            
//            beforeEach {
//                
//                realm = RealmProvider().realm()
//                client = NetworkClient(baseURL: "https://kitsu.io", heimdallr: StubAuthHeimdallr())
//            }
//            
//            afterEach {
//                OHHTTPStubs.removeAllStubs()
//                try! realm.write {
//                    realm.deleteAll()
//                }
//            }
//            
//            context("Get All") {
//                it("should add fetched objects to the database") {
//                    let entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
//                    
//                    stub(condition: isHost("kitsu.io")) { _ in
//                        let data: [String : Any] = ["data": entryJSON.dictionaryObject!, "links": []]
//                        return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
//                    }
//                    
//                    waitUntil { done in
//                        LibraryService(client: client).getAll(userID: 1, type: .anime) { errors in
//                            expect(errors).to(beEmpty())
//                            expect(LibraryEntry.all()).to(haveCount(1))
//                            done()
//                        }
//                    }
//                }
//                
//                it("should return errors if they occured") {
//                    stub(condition: isHost("kitsu.io")) { _ in
//                        return OHHTTPStubsResponse(error: NetworkClientError.error("failed to get page"))
//                    }
//                    
//                    waitUntil { done in
//                        LibraryService(client: client).getAll(userID: 1, type: .anime) { errors in
//                            expect(errors).toNot(beEmpty())
//                            done()
//                        }
//                    }
//                }
//                
//                it("should delete entries that are not in the response") {
//                    TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 1) { _, entry in
//                        entry.id = 1
//                        entry.userID = 1
//                        entry.media = Media(value: [1, 1, "anime"])
//                    }
//                    
//                    var entryJSON = TestHelper.loadJSON(fromFile: "entry-anime-jigglyslime")!
//                    entryJSON["relationships"]["user"]["data"]["id"] = 1
//                    
//                    stub(condition: isHost("kitsu.io")) { _ in
//                        let data: [String : Any] = ["data": entryJSON.dictionaryObject!]
//                        return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
//                    }
//                    
//                    waitUntil { done in
//                        LibraryService(client: client).getAll(userID: 1, type: .anime) { errors in
//                            expect(errors).to(beEmpty())
//                            expect(LibraryEntry.all()).to(haveCount(1))
//                            expect(LibraryEntry.get(withId: 1)).to(beNil())
//                            done()
//                        }
//                    }
//                }
//            }
//            
//        }
//    }
}
