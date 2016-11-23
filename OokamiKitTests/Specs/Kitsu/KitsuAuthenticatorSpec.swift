//
//  KitsuAuthenticatorSpec.swift
//  Ookami
//
//  Created by Maka on 23/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
@testable import Heimdallr
import Result

private class StubRequestHeimdallr: Heimdallr {
    
    var stubError: NSError? = nil
    var token: Bool = false
    
    override public var hasAccessToken: Bool {
        return token
    }
    
    init(stubError: NSError? = nil) {
        super.init(tokenURL: URL(string: "http://kitsu.io")!)
        self.stubError = stubError
    }
    
    override func clearAccessToken() {
        token = false
    }
    
    override func requestAccessToken(username: String, password: String, completion: @escaping (Result<Void, NSError>) -> ()) {
        if stubError == nil {
            token = true
            completion(.success())
        } else {
            completion(.failure(stubError!))
        }
    }
}

class KitsuAuthenticatorSpec: QuickSpec {
    override func spec() {
        describe("Kitsu Authenticator") {
            var authenticator: KitsuAuthenticator?
            
            afterEach {
                if authenticator != nil {
                    UserDefaults.standard.removeObject(forKey: authenticator!.usernameKey)
                    authenticator = nil
                }
            }
            
            context("Authentication") {
                it("should return no error if successful") {
                    authenticator = KitsuAuthenticator(heimdallr: StubRequestHeimdallr())
                    waitUntil { done in
                        authenticator!.authenticate(username: "test", password: "hi") { error in
                            expect(error).to(beNil())
                            done()
                        }
                    }
                }
                
                it("should store the username if successful") {
                    authenticator = KitsuAuthenticator(heimdallr: StubRequestHeimdallr())
                    authenticator!.authenticate(username: "test", password: "hi") { _ in
                    }
                    expect(authenticator!.currentUser).toEventually(equal("test"))
                    expect(authenticator!.isLoggedIn()).toEventually(beTrue())
                }
                
                it("should return error if something went wrong") {
                    let nsError: NSError = NSError(domain: "hi", code: 1, userInfo: nil)
                    authenticator = KitsuAuthenticator(heimdallr: StubRequestHeimdallr(stubError: nsError))
                    waitUntil { done in
                        authenticator!.authenticate(username: "test", password: "hi") { error in
                            expect(error).to(matchError(nsError))
                            done()
                        }
                    }
                }
            }
            
            context("Logout") {
                it("should clear the username and token") {
                    let h = StubRequestHeimdallr()
                    h.token = true
                    
                    authenticator = KitsuAuthenticator(heimdallr: h)
                    UserDefaults.standard.set("test", forKey: authenticator!.usernameKey)
                    
                    expect(authenticator!.currentUser).to(equal("test"))
                    expect(authenticator!.isLoggedIn()).to(beTrue())
                    
                    authenticator!.logout()
                    expect(authenticator!.currentUser).to(beNil())
                    expect(authenticator!.isLoggedIn()).to(beFalse())
                }
            }
        }
    }
}
