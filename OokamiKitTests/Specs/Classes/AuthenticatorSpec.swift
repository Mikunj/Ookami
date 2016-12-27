//
//  AuthenticatorSpec.swift
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

private class StubAuthenticator: Authenticator {
    
    override func updateInfo(completion: @escaping (Error?) -> Void) {
        self.currentUserID = 1
        completion(nil)
    }
    
}

class AuthenticatorSpec: QuickSpec {
    override func spec() {
        describe("Authenticator") {
            var authenticator: Authenticator?
            
            afterEach {
                if authenticator != nil {
                    UserDefaults.standard.removeObject(forKey: authenticator!.usernameKey)
                    authenticator = nil
                }
            }
            
            context("Updating user info") {
                class StubUserService: UserService {
                    let e: Error?
                    init(error: Error? = nil) {
                        self.e = error
                        super.init()
                    }
                    override func getSelf(_ completion: @escaping UserService.UserCompletion) {
                        guard e == nil else {
                            completion(nil, e)
                            return
                        }
                        
                        let u = User()
                        u.id = 1
                        u.name = "test"
                        completion(u, nil)
                    }
                }
                
                class StubLibraryService: LibraryService {
                    override func getAll(userID: Int, type: Media.MediaType, completion: @escaping ([(LibraryEntry.Status, Error)]) -> Void) {
                        completion([])
                    }
                }
                
                it("should not pass error if user is found") {
                    authenticator = Authenticator(heimdallr: StubRequestHeimdallr())
                    authenticator!.userService = StubUserService()
                    authenticator!.libraryService = StubLibraryService()
                    waitUntil { done in
                        authenticator!.updateInfo { error in
                            expect(error).to(beNil())
                            expect(authenticator?.currentUserID).to(equal(1))
                            done()
                        }
                    }
                }
                
                it("should pass error if no user is found") {
                    authenticator = Authenticator(heimdallr: StubRequestHeimdallr())
                    let e = NetworkClientError.error("generic error")
                    authenticator?.userService = StubUserService(error: e)
                    authenticator?.libraryService = StubLibraryService()
                    waitUntil { done in
                        authenticator?.updateInfo { error in
                            expect(error).toNot(beNil())
                            expect(error).to(matchError(e))
                            done()
                        }
                    }
                }
            }
            
            context("Authentication") {
                it("should return no error if successful") {
                    authenticator = StubAuthenticator(heimdallr: StubRequestHeimdallr())
                    waitUntil { done in
                        authenticator!.authenticate(username: "test", password: "hi") { error in
                            expect(error).to(beNil())
                            done()
                        }
                    }
                }
                
                it("should store the user id if successful") {
                    authenticator = StubAuthenticator(heimdallr: StubRequestHeimdallr())
                    authenticator!.authenticate(username: "test", password: "hi") { _ in
                    }
                    expect(authenticator!.currentUserID).toEventually(equal(1))
                    expect(authenticator!.isLoggedIn()).toEventually(beTrue())
                }
                
                it("should return error if something went wrong") {
                    let nsError: NSError = NSError(domain: "hi", code: 1, userInfo: nil)
                    authenticator = StubAuthenticator(heimdallr: StubRequestHeimdallr(stubError: nsError))
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
                    
                    authenticator = Authenticator(heimdallr: h)
                    UserDefaults.standard.set(1, forKey: authenticator!.usernameKey)
                    
                    expect(authenticator!.currentUserID).to(equal(1))
                    expect(authenticator!.isLoggedIn()).to(beTrue())
                    
                    authenticator!.logout()
                    expect(authenticator!.currentUser).to(beNil())
                    expect(authenticator!.isLoggedIn()).to(beFalse())
                }
            }
        }
    }
}
