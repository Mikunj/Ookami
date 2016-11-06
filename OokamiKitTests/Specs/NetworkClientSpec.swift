//
//  NetworkClientSpec.swift
//  Ookami
//
//  Created by Maka on 6/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON
import Heimdallr
import Result
import OHHTTPStubs

private class StubHeimdallr: Heimdallr {
    
    typealias VoidClosure = () -> ()
    
    var stubError: NSError?
    var authBlock: VoidClosure?
    
    init(stubError: NSError? = nil, authenticationBlock: VoidClosure? = nil) {
        super.init(tokenURL: URL(string: "http://kitsu.io")!)
        self.stubError = stubError
        self.authBlock = authenticationBlock
    }
    
    //A stub authenticate request that return a stub error or the request if stubError is not set
    //Also calls the callback block
    override func authenticateRequest(_ request: URLRequest, completion: @escaping (Result<URLRequest, NSError>) -> ()) {
        
        authBlock?()
        
        if stubError != nil {
            completion(.failure(stubError!))
        } else {
            completion(.success(request))
        }
    }
}

class NetworkClientSpec: QuickSpec {
    override func spec() {
        
        var client: NetworkClient?
        
        describe("NetworkClient") {
            
            beforeEach {
                
                client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubHeimdallr())
                
                //Stub the network to return JSON data
                stub(condition: isHost("kitsu.io")) { _ in
                    let obj = ["data": "hi"]
                    return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
                }
            }
            
            afterEach {
                OHHTTPStubs.removeAllStubs()
            }
            
            context("Authentication") {
                
                context("Request needs authentication") {
                    
                    it("Should call the authentication function") {
                        var authenticationCalled = false
                        var requestExecuted = false
                        
                        client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubHeimdallr() {
                            authenticationCalled = true
                        })
                        
                        let request = NetworkRequest(method: .get, parameters: nil, headers: nil, needsAuth: true, relativeURL: "/user")
                        client?.execute(request: request) { data, e in
                            requestExecuted = true
                        }
                        
                        expect(authenticationCalled).toEventually(beTrue())
                        expect(requestExecuted).toEventually(beTrue())
                    }
                    
                    it("Should authenticate if user is logged in") {
                        
                        var error: Error? = NetworkClientError.error("defaultError")
                        var data: JSON? = nil
                        
                        //Set the stubError to nil to simulate a signing success
                        client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubHeimdallr())
                        
                        let request = NetworkRequest(method: .get, parameters: nil, headers: nil, needsAuth: true, relativeURL: "/user")
                        client?.execute(request: request) { d, e in
                            data = d
                            error = e
                        }
                        
                        expect(data).toEventuallyNot(beNil())
                        expect(error).toEventually(beNil())
                    }
                    
                    it("Should give an error if user is not logged in") {
                        var authenticationError = false
                        
                        //Set the stubError to nil to simulate a signing success
                        client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubHeimdallr(stubError: NSError(domain: "client", code: 400, userInfo: nil)))
                        
                        let request = NetworkRequest(method: .get, parameters: nil, headers: nil, needsAuth: true, relativeURL: "/user")
                        client?.execute(request: request) { data, e in
                            if let error = e {
                                if case NetworkClientError.authenticationError(_) = error {
                                    authenticationError = true
                                }
                            
                            }
                        }
                        
                        expect(authenticationError).toEventually(beTrue())
                    }
                }
                
                context("Request doesn't need authentication") {
                    it("Should not call the authentication function") {
                        var authenticationCalled = false
                        var requestExecuted = false
                        
                        client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubHeimdallr() {
                            authenticationCalled = true
                        })
                        
                        let request = NetworkRequest(method: .get, parameters: nil, headers: nil, needsAuth: false, relativeURL: "/user")
                        client?.execute(request: request) { data, e in
                            requestExecuted = true
                        }
                        
                        expect(authenticationCalled).toEventually(beFalse())
                        expect(requestExecuted).toEventually(beTrue())
                    }
                }
                
            }
            
            context("Executing") {
                it("should correctly build a URLRequest") {
                    
                    var data: JSON? = nil
                    
                    let request = NetworkRequest(method: .get, parameters: nil , headers: ["header": "1"], needsAuth: false, relativeURL: "/user")
                    
                    stub(condition: isHost("kitsu.io")) { _ in
                        return OHHTTPStubsResponse(error: NetworkClientError.error("Failed to get stuff"))
                    }
                    
                    //This does not produce error if the passingTest return true
                    OHHTTPStubs.stubRequests(passingTest: { request -> Bool in
                        
                        return request.httpMethod == "GET" &&
                            request.url?.path == "/user" &&
                            request.value(forHTTPHeaderField: "header") == "1"
                    }, withStubResponse: { request -> OHHTTPStubsResponse in
                        let obj = ["data": "hi"]
                        return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
                    })
                    
                    client?.execute(request: request) { d, e in
                        data = d
                    }
                    
                    expect(data).toEventuallyNot(beNil())
                }
                
                it("should correctly return JSON") {
                    var dataSaysHi = false
                    var didError = false
                    
                    let request = NetworkRequest(method: .get, parameters: nil , headers: nil, needsAuth: false, relativeURL: "/user")
                    client?.execute(request: request) { data, error in
                        if data?["data"].stringValue == "hi" {
                                dataSaysHi = true
                        }
                        if error != nil {
                            didError = true
                        }
                    }
                    
                    expect(dataSaysHi).toEventually(beTrue())
                    expect(didError).toEventually(beFalse())
                }
                
                it("should not allow bad status codes") {
                    var didError = false
                    
                    let request = NetworkRequest(method: .get, parameters: nil , headers: nil, needsAuth: false, relativeURL: "/user")
                    
                    stub(condition: isHost("kitsu.io")) { _ in
                        let obj = ["name": "test"]
                        return OHHTTPStubsResponse(jsonObject: obj, statusCode: 400, headers: nil)
                    }
                    
                    client?.execute(request: request) { d, e in
                        if e != nil {
                            didError = true
                        }
                    }
                    
                    expect(didError).toEventually(beTrue())
                }
                
                it("should propogate network error") {
                    var hasData = false
                    var didError = false
                    
                    let request = NetworkRequest(method: .get, parameters: nil , headers: ["header": "1"], needsAuth: false, relativeURL: "/user")
                    
                    stub(condition: isHost("kitsu.io")) { _ in
                        return OHHTTPStubsResponse(error: NetworkClientError.error("Failed to get stuff"))
                    }
                    
                    client?.execute(request: request) { d, e in
                        if d != nil { hasData = true }
                        if e != nil { didError = true }
                    }
                    
                    expect(hasData).toEventually(beFalse())
                    expect(didError).toEventually(beTrue())

                }
            }
        }
    }
}
