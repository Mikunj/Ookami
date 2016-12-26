//
//  FetchAllLibraryOperationSpec.swift
//  Ookami
//
//  Created by Maka on 12/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON
import RealmSwift
import OHHTTPStubs

private class StubFetchAllOperation: FetchAllLibraryOperation {
    var didCallDeleteOperation: Bool = false
    
    override func deleteOperation(withEntryIds ids: [Int]) -> DeleteEntryOperation {
        didCallDeleteOperation = true
        return super.deleteOperation(withEntryIds: ids)
    }
}

class FetchAllLibraryOperationSpec: QuickSpec {
    override func spec() {
        describe("Fetch All Library Operation") {
            var client: NetworkClient!
            var queue: OperationQueue!
            
            beforeEach {
                client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubAuthHeimdallr())
                queue = OperationQueue()
                queue.maxConcurrentOperationCount = 1
            }
            
            afterEach {
                queue.cancelAllOperations()
                OHHTTPStubs.removeAllStubs()
                
                let realm = RealmProvider().realm()
                try! realm.write {
                    realm.deleteAll()
                }
            }
            
            context("Deleting entries") {
                it("should not delete entries if any status was not successful") {
                    let operation = StubFetchAllOperation(relativeURL: "/entries", userID: 1, type: .anime, client: client) { _ in}
                    operation.failed.append((.completed, NetworkClientError.error("failed to get status")))
                    
                    let bOperation = operation.deleteBlockOperation()
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(operation.didCallDeleteOperation).to(beFalse())
                            done()
                        }
                        queue.addOperation(bOperation)
                    }
                }
                
                it("should delete entries not in ids array") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: RealmProvider().realm(), amount: 3) { index, object in
                        object.id = index
                        object.userID = 1
                        
                        let m = Media()
                        m.entryID = index
                        m.id = index
                        m.rawType = Media.MediaType.anime.rawValue
                        
                        object.media = m
                    }
                    
                    let operation = StubFetchAllOperation(relativeURL: "/entries", userID: 1, type: .anime, client: client) { _ in}
                    operation.ids = [0]
                    
                    let bOperation = operation.deleteBlockOperation()
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(operation.didCallDeleteOperation).to(beTrue())
                            expect(LibraryEntry.all()).to(haveCount(1))
                            expect(LibraryEntry.get(withId: 0)).toNot(beNil())
                            done()
                        }
                        queue.addOperation(bOperation)
                    }
                }
            }
            
            
            context("cancelling") {
                it("should not call the callback function") {
                    var called: Bool = false
                    let operation = StubFetchAllOperation(relativeURL: "/entries", userID: 1, type: .anime, client: client) { _ in
                        called = true
                    }
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(called).to(beFalse())
                            done()
                        }
                        queue.addOperation(operation)
                        operation.cancel()
                    }

                }
            }
            
            context("Main") {
                
                it("should correctly fetch and parse data for each status") {
                    stub(condition: isHost("kitsu.io")) { _ in
                        let data: [String : Any] = ["data": [["type": LibraryEntry.typeString, "id": 1]], "links": ["first": "need this so FetchLibraryOperation won't wonk out"]]
                        return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                    }
                    
                    let operation = StubFetchAllOperation(relativeURL: "/entries", userID: 1, type: .anime, client: client) { _ in
                    }
                    
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(LibraryEntry.all()).to(haveCount(1))
                            expect(operation.failed).to(beEmpty())
                            done()
                        }
                        queue.addOperation(operation)
                    }
                    
                }
                
                it("should add status to failed when errors occur") {
                    stub(condition: isHost("kitsu.io")) { _ in
                        return OHHTTPStubsResponse(error: NetworkClientError.error("failed to get page"))
                    }
                    
                    let operation = StubFetchAllOperation(relativeURL: "/entries", userID: 1, type: .anime, client: client) { _ in
                    }
                    
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(LibraryEntry.all()).to(haveCount(0))
                            expect(operation.failed).to(haveCount(LibraryEntry.Status.all.count))
                            done()
                        }
                        queue.addOperation(operation)
                    }
                }
                
            }
        }
    }
}
