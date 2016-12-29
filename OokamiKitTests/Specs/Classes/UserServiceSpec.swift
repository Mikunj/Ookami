//
//  UserServiceSpec.swift
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

class UserServiceSpec: QuickSpec {
    
    override func spec() {
        describe("User Service") {
            
            var client: NetworkClient!
            
            beforeEach {
                client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubAuthHeimdallr())
            }
            
            afterEach {
                OHHTTPStubs.removeAllStubs()
            }
            
            it("should pass the network error") {
                stub(condition: isHost("kitsu.io")) { _ in
                    return OHHTTPStubsResponse(error: NetworkClientError.error("failed to get page"))
                }
                
                
                waitUntil { done in
                    let request = NetworkRequest(relativeURL: "/user/1", method: .get)
                    UserService(client: client).get(request: request) { user, error in
                        expect(error).toNot(beNil())
                        expect(user).to(beNil())
                        done()
                    }
                }
            }
            
            it("should add the user to the database and pass it back") {
                let userJSON = TestHelper.loadJSON(fromFile: "user-jigglyslime")!
                
                stub(condition: isHost("kitsu.io")) { _ in
                    let data: [String : Any] = ["data": userJSON.dictionaryObject!]
                    return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                }
                
                
                waitUntil { done in
                    let request = NetworkRequest(relativeURL: "/user/1", method: .get)
                    UserService(client: client).get(request: request) { user, error in
                        expect(error).to(beNil())
                        expect(user?.name).to(equal("Jigglyslime"))
                        expect(User.get(withId: 2875)).toNot(beNil())
                        done()
                    }
                }
            }
        }
    }
}
