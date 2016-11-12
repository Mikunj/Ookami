//
//  FetchLibraryOperationSpec.swift
//  Ookami
//
//  Created by Maka on 10/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON
import OHHTTPStubs

class StubParsingOperation: ParsingOperation {
    override func main() {
        let realm = realmBlock()
        try! realm.write {
            let o = StubRealmObject()
            o.id = 1
            realm.add(o, update: true)
        }
        self.parseComplete(["test": [1]], nil)
        self.completeOperation()
    }
}

class StubFetchOperation: FetchLibraryOperation {
    
    var fetchCalledAmount: Int = 0
    
    override func fetchCurrentPage() {
        fetchCalledAmount += 1
        super.fetchCurrentPage()
    }
    
    override func parsingOperation(forJSON json: JSON) -> ParsingOperation {
        return StubParsingOperation(json: json, realm: RealmProvider.realm) { parsed, _ in
            if parsed != nil {
                self.add(toFetchedObjects: parsed!)
            }
        }
    }
}

class FetchLibraryOperationSpec: QuickSpec {
    override func spec() {
        describe("Fetch Library Operation") {
            
            var client: NetworkClient!
            
            beforeEach {
                client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubAuthHeimdallr())
            }
            
            afterEach {
                OHHTTPStubs.removeAllStubs()
                
                let realm = RealmProvider.realm()
                try! realm.write {
                    realm.deleteAll()
                }
            }
            
            
            context("Combining fetched objects") {
                it("should be able to correctly combine fetched objects dictionary") {
                    let dict1 = ["type": [1], "type2": ["hi"]]
                    let dict2 = ["type": [2, 3], "type2": ["hello", "bye"]]
                    let request = LibraryGETRequest(userID: 1, relativeURL: "/anime")
                    let operation = FetchLibraryOperation(request: request, client: client) { objects, error in
                    }
                    operation.add(toFetchedObjects: dict1)
                    var objects = operation.fetchedObjects
                    expect(objects.keys).to(haveCount(2))
                    expect(objects["type"] as! [Int]?).to(contain(1))
                    expect(objects["type2"] as! [String]?).to(contain("hi"))
                        
                    operation.add(toFetchedObjects: dict2)
                    objects = operation.fetchedObjects
                    expect(objects.keys).to(haveCount(2))
                    expect(objects["type"] as! [Int]?).to(contain([1, 2, 3]))
                    expect(objects["type2"] as! [String]?).to(contain(["hi", "hello", "bye"]))
                }
            }
            
            context("Fetching page") {
                
                it("should pass a failedToFetchPage error if a network error occurs") {
                    var error: FetchLibraryOperationError?
                    let networkError = NetworkClientError.error("test")
                    
                    stub(condition: isHost("kitsu.io")) { _ in
                        return OHHTTPStubsResponse(error: networkError)
                    }
                    
                    let request = LibraryGETRequest(userID: 1, relativeURL: "/anime")
                    let operation = FetchLibraryOperation(request: request, client: client) { objects, e in
                        error = e
                    }
                    
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(error).toNot(beNil())
                            expect(error).to(matchError(FetchLibraryOperationError.failedToFetchPage(offset: 0, error: networkError)))
                            done()
                        }
                        operation.fetchCurrentPage()
                    }
                    
                }
                
                context("Parser") {
                    
                    beforeEach {
                        stub(condition: isHost("kitsu.io")) { _ in
                            return OHHTTPStubsResponse(jsonObject: ["data": ["type": "test"]], statusCode: 200, headers: nil)
                        }
                    }
                    
                    it("should parse the objects and pass back the ids in callback") {
                        var ids: [String: [Any]]?
                        
                        let request = LibraryGETRequest(userID: 1, relativeURL: "/anime")
                        let operation = StubFetchOperation(request: request, client: client) { objects, e in
                            ids = objects
                        }
                        
                        waitUntil { done in
                            operation.completionBlock = {
                                expect(StubRealmObject.all()).to(haveCount(1))
                                expect(ids).toNot(beNil())
                                expect(ids?["test"] as! [Int]?).to(contain(1))
                                done()
                            }
                            operation.fetchCurrentPage()
                        }
                        
                    }
                    
                    it("should not pass back object ids with bad JSON objects") {
                        var ids: [String: [Any]]?
                        
                        let request = LibraryGETRequest(userID: 1, relativeURL: "/anime")
                        let operation = FetchLibraryOperation(request: request, client: client) { objects, e in
                            ids = objects
                        }
                        
                        waitUntil { done in
                            operation.completionBlock = {
                                expect(ids).to(beEmpty())
                                done()
                            }
                            operation.fetchCurrentPage()
                        }
                    }
                }
                
                context("Links") {
                    
                    /// Test that callback is called, and fetchCurrentPage is called `amount` times
                    func checkCompletionCall(expectedFetchCallAmount amount: Int) {
                        var ids: [String: [Any]]?
                        var calledCompletion: Bool?
                        
                        let request = LibraryGETRequest(userID: 1, relativeURL: "/anime")
                        let operation = StubFetchOperation(request: request, client: client) { objects, e in
                            ids = objects
                            calledCompletion = true
                        }
                        
                        waitUntil { done in
                            operation.completionBlock = {
                                expect(ids).toNot(beNil())
                                expect(calledCompletion).to(beTrue())
                                expect(operation.fetchCalledAmount).to(equal(amount))
                                done()
                            }
                            operation.fetchCurrentPage()
                        }

                    }
                    
                    it("should complete the operation if links data is not a dictionary") {
                        stub(condition: isHost("kitsu.io")) { _ in
                            return OHHTTPStubsResponse(jsonObject: ["data": ["type": "test"], "links": "next"], statusCode: 200, headers: nil)
                        }
                        
                        checkCompletionCall(expectedFetchCallAmount: 1)
                    }
                    
                    it("should complete the operation if no next link is found") {
                        stub(condition: isHost("kitsu.io")) { _ in
                            return OHHTTPStubsResponse(jsonObject: ["data": ["type": "test"], "links": ["first": "hi", "prev": "hello"]], statusCode: 200, headers: nil)
                        }
                        
                        checkCompletionCall(expectedFetchCallAmount: 1)
                    }
                    
                    it("should call fetch again if next link is found") {
                        var count = 0
                        stub(condition: isHost("kitsu.io")) { _ in
                            count += 1
                            let linkData = count == 1 ?  ["next": "yay"] : ["first": "oh no"]
                            return OHHTTPStubsResponse(jsonObject: ["data": ["type": "test"], "links": linkData], statusCode: 200, headers: nil)
                        }
                        
                        checkCompletionCall(expectedFetchCallAmount: 2)
                    }
                }
                
                context("Cancelling") {
                    it("should not continue fetching if operation was cancelled") {
                        var calledCompletion: Bool = false
                        
                        let request = LibraryGETRequest(userID: 1, relativeURL: "/anime")
                        let operation = StubFetchOperation(request: request, client: client) { _, _ in
                            calledCompletion = true
                        }
                        
                        stub(condition: isHost("kitsu.io")) { _ in
                            operation.cancel()
                            return OHHTTPStubsResponse(jsonObject: ["data": ["type": "test"], "links": ["next": "yay"]], statusCode: 200, headers: nil)
                        }
                        
                        
                        waitUntil { done in
                            operation.completionBlock = {
                                expect(calledCompletion).to(beFalse())
                                expect(operation.fetchCalledAmount).to(equal(1))
                                done()
                            }
                            operation.fetchCurrentPage()
                        }

                    }
                }
                
            }
        }
    }
}
