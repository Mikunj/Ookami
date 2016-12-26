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

class NetworkClientSpec: QuickSpec {
    override func spec() {
        
        var client: NetworkClient?
        
        describe("NetworkClient") {
            
            beforeEach {
                
                client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubAuthHeimdallr())
                
                //Stub the network to return JSON data
                stub(condition: isHost("kitsu.io")) { _ in
                    let obj = ["data": "hi"]
                    return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                }
            }
            
            afterEach {
                OHHTTPStubs.removeAllStubs()
                
            }
            
            context("Authentication") {
                
                context("Request needs authentication") {
                    
                    it("Should call the authentication function") {
                        var authenticationCalled: Bool? = nil
                        var requestExecuted: Bool? = nil
                        
                        client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubAuthHeimdallr() {
                            authenticationCalled = true
                        })
                        
                        let request = NetworkRequest(relativeURL: "/user", method: .get, needsAuth: true)
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
                        client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubAuthHeimdallr())
                        
                        let request = NetworkRequest(relativeURL: "/user", method: .get, needsAuth: true)
                        client?.execute(request: request) { d, e in
                            data = d
                            error = e
                        }
                        
                        expect(data).toEventuallyNot(beNil())
                        expect(error).toEventually(beNil())
                    }
                    
                    it("Should give an error if user is not logged in") {
                        var authenticationError: Bool? = nil
                        
                        //Set the stubError to nil to simulate a signing success
                        client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubAuthHeimdallr(stubError: NSError(domain: "client", code: 400, userInfo: nil)))
                        
                        let request = NetworkRequest(relativeURL: "/user", method: .get, needsAuth: true)
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
                        
                        client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubAuthHeimdallr() {
                            authenticationCalled = true
                        })
                        
                        let request = NetworkRequest(relativeURL: "/user", method: .get)
                        client?.execute(request: request) { data, e in
                            requestExecuted = true
                        }
                        
                        //We use waitUntil so that we can check if the values were set, as using expect(authcalled)toEventually(beFalse()) will automatically resolve as its default value is false
                        waitUntil { done in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                expect(authenticationCalled).to(beFalse())
                                expect(requestExecuted).to(beTrue())
                                done()
                            }
                        }
                        
                    }
                }
                
            }
            
            context("Executing") {
                it("should correctly build a relative url URLRequest") {
                    
                    var data: JSON? = nil
                    
                    let request = NetworkRequest(relativeURL: "/user", method: .get, headers: ["header": "1"])
                    
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
                        return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                    })
                    
                    client?.execute(request: request) { d, e in
                        data = d
                    }
                    
                    expect(data).toEventuallyNot(beNil())
                }
                
                it("should correctly build a full url URLRequest") {
                    var data: JSON? = nil
                    
                    let request = NetworkRequest(absoluteURL: "http://abc.io/anime", method: .get, headers: ["header": "1"])
                    
                    stub(condition: isHost("abc.io")) { _ in
                        return OHHTTPStubsResponse(error: NetworkClientError.error("Failed to get stuff"))
                    }
                    
                    //This does not produce error if the passingTest return true
                    OHHTTPStubs.stubRequests(passingTest: { request -> Bool in           
                        return request.httpMethod == "GET" &&
                            request.url?.absoluteString == "http://abc.io/anime" &&
                            request.value(forHTTPHeaderField: "header") == "1"
                    }, withStubResponse: { request -> OHHTTPStubsResponse in
                        let obj = ["data": "hi"]
                        return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                    })
                    
                    client?.execute(request: request) { d, e in
                        data = d
                    }
                    
                    expect(data).toEventuallyNot(beNil())
                }
                
                it("should correctly return JSON") {
                    var dataSaysHi: Bool? = nil
                    var didError: Bool? = nil
                    
                    let request = NetworkRequest(relativeURL: "/user", method: .get)
                    client?.execute(request: request) { data, error in
                        dataSaysHi = data?["data"].stringValue == "hi"
                        didError = error != nil
                    }
                    
                    expect(dataSaysHi).toEventually(beTrue())
                    expect(didError).toEventually(beFalse())
                }
                
                it("should not allow bad status codes") {
                    var didError: Bool? = nil
                    
                    let request = NetworkRequest(relativeURL: "/user", method: .get)
                    
                    stub(condition: isHost("kitsu.io")) { _ in
                        let obj = ["name": "test"]
                        return OHHTTPStubsResponse(jsonObject: obj, statusCode: 400, headers: ["Content-Type": "application/vnd.api+json"])
                    }
                    
                    client?.execute(request: request) { d, e in
                        didError = e != nil
                    }
                    
                    expect(didError).toEventually(beTrue())
                }
                
                it("should propogate network error") {
                    var hasData: Bool? = nil
                    var didError: Bool? = nil
                    
                    let request = NetworkRequest(relativeURL: "/user", method: .get, headers: ["header": "1"])
                    
                    stub(condition: isHost("kitsu.io")) { _ in
                        return OHHTTPStubsResponse(error: NetworkClientError.error("Failed to get stuff"))
                    }
                    
                    client?.execute(request: request) { d, e in
                        hasData = d != nil
                        didError = e != nil
                    }
                    
                    expect(hasData).toEventually(beFalse())
                    expect(didError).toEventually(beTrue())

                }
            }
        }
    }
}
