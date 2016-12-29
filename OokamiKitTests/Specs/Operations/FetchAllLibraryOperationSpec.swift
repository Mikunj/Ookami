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
            }
            
            
            context("cancelling") {
                it("should not call the callback function") {
                    var called: Bool = false
                    let operation = FetchAllLibraryOperation(client: client, request: { _ in
                        return KitsuLibraryRequest(userID: 1, type: .anime)
                    }, onFetch: { _ in }, completion: { _ in
                        called = true
                    })
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
                        let data: [String : Any] = ["data": [["type": LibraryEntry.typeString, "id": 1]]]
                        return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                    }
                    
                    var objects: [Object] = []
                    
                    let operation = FetchAllLibraryOperation(client: client, request: { _ in
                        return KitsuLibraryRequest(userID: 1, type: .anime)
                    }, onFetch: {
                        objects.append(contentsOf: $0)
                    }, completion: { _ in })
                    
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(objects).to(haveCount(LibraryEntry.Status.all.count))
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
                    
                    var objects: [Object] = []
                    
                    
                    let operation = FetchAllLibraryOperation(client: client, request: { _ in
                        return KitsuLibraryRequest(userID: 1, type: .anime)
                    }, onFetch: {
                        objects.append(contentsOf: $0)
                    }, completion: { _ in })
                    
                    waitUntil { done in
                        operation.completionBlock = {
                            expect(objects).to(haveCount(0))
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
