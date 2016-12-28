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
import RealmSwift

private class StubFetchOperation: FetchLibraryOperation {
    
    var fetchCalledAmount: Int = 0
    
    override func fetchNextPage() {
        fetchCalledAmount += 1
        super.fetchNextPage()
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
            }
            
            context("Fetching page") {
                
                it("should not call fetch block if a network error occurs") {
                    var fetchCalled = false
                    var error: Error?
                    let networkError = NetworkClientError.error("test")
                    
                    stub(condition: isHost("kitsu.io")) { _ in
                        return OHHTTPStubsResponse(error: networkError)
                    }
                    
                    let request = PagedKitsuRequest(relativeURL: "/anime")
                    let operation = FetchLibraryOperation(request: request, client: client, onFetch: { _ in
                        fetchCalled = true
                    }, completion: { e in
                        error = e
                    })
                    
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(error).toNot(beNil())
                            expect(error).to(matchError(networkError))
                            expect(fetchCalled).to(beFalse())
                            done()
                        }
                        operation.fetchNextPage()
                    }
                }
                
                it("should complete if there is no next page") {
                    stub(condition: isHost("kitsu.io")) { _ in
                        return OHHTTPStubsResponse(jsonObject: ["data": [["type": LibraryEntry.typeString, "id": 1]], "links": ["first": "yay"]], statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                    }
                    
                    var objects: [Object] = []
                    var error: Error?
                    
                    let request = PagedKitsuRequest(relativeURL: "/anime")
                    let operation = StubFetchOperation(request: request, client: client, onFetch: { f in
                        objects = f
                    }, completion: { e in
                        error = e
                    })
                    
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(objects).to(haveCount(1))
                            expect(error).to(beNil())
                            done()
                        }
                        operation.fetchNextPage()
                    }
                }
                
                context("Cancelling") {
                    it("should not continue fetching if operation was cancelled") {
                        var calledCompletion: Bool = false
                        
                        let request = PagedKitsuRequest(relativeURL: "/anime")
                        let operation = StubFetchOperation(request: request, client: client, onFetch: { _ in }, completion: { _ in
                            calledCompletion = true
                        })
                        
                        stub(condition: isHost("kitsu.io")) { _ in
                            operation.cancel()
                            return OHHTTPStubsResponse(jsonObject: ["data": [["type": "test"]], "links": ["first": "yay"]], statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                        }
                        
                        
                        waitUntil { done in
                            operation.completionBlock = {
                                expect(calledCompletion).to(beFalse())
                                
                                //1 initial call, and then called again to check if operation cancelled
                                expect(operation.fetchCalledAmount).to(equal(2))
                                done()
                            }
                            operation.fetchNextPage()
                        }

                    }
                }
                
            }
        }
    }
}
