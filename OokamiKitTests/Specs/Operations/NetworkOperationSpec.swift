//
//  NetworkOperationSpec.swift
//  Ookami
//
//  Created by Maka on 7/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON
import OHHTTPStubs

class NetworkOperationSpec: QuickSpec {
    
    override func spec() {
        
        describe("NetworkOperation") {
            
            let queue: OperationQueue = OperationQueue()
            var client: NetworkClient?
            
            beforeEach {
                queue.maxConcurrentOperationCount = 1
                queue.cancelAllOperations()
                
                client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubAuthHeimdallr())
                
            }
            
            it("should return network data correctly") {
                var recievedData: Bool? = nil
                var didError: Bool? = nil
                var blockCalled: Bool? = nil
                
                //Stub the network to return JSON data
                stub(condition: isHost("kitsu.io")) { _ in
                    let obj = ["message": "hi"]
                    return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                }
                
                let request = NetworkRequest(relativeURL: "/test", method: .get)
                let operation = NetworkOperation(request: request, client: client!) { data, error in
                    blockCalled = true
                    recievedData = data?["message"].stringValue == "hi"
                    didError = error != nil
                }
                
                queue.addOperation(operation)
                expect(blockCalled).toEventually(beTrue())
                expect(recievedData).toEventually(beTrue())
                expect(didError).toEventually(beFalse())
            }
            
            it("should return errors correctly") {
                var recievedData: Bool? = nil
                var didError: Bool? = nil
                
                //Stub the network to return JSON data
                stub(condition: isHost("kitsu.io")) { _ in
                    return OHHTTPStubsResponse(error: NetworkClientError.error("error"))
                }
                
                let request = NetworkRequest(relativeURL: "/test", method: .get)
                let operation = NetworkOperation(request: request, client: client!) { data, error in
                    recievedData = data != nil
                    didError = error != nil
                }
                
                queue.addOperation(operation)
                expect(recievedData).toEventually(beFalse())
                expect(didError).toEventually(beTrue())
            }
            
            it("should not call the completion block if it was cancelled") {
                var blockCalled = false
                
                //Stub the network to return JSON data
                stub(condition: isHost("kitsu.io")) { _ in
                    let obj = ["message": "hi"]
                    return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"]).responseTime(0.5)
                }
                
                let request = NetworkRequest(relativeURL: "/test", method: .get)
                let operation = NetworkOperation(request: request, client: client!) { data, error in
                    blockCalled = true
                }
                
                queue.addOperation(operation)
                operation.cancel()
                
                //Wait until we get the request to check if the completion block was called
                waitUntil(timeout: 3.0) { done in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        expect(operation.isCancelled).to(beTrue())
                        expect(blockCalled).to(beFalse())
                        done()
                    }
                }
            }
        }
    }
    
}
