//
//  CurrentUserSpec.swift
//  Ookami
//
//  Created by Maka on 1/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
@testable import Heimdallr
import Result
import RealmSwift

private class StubClearHeim: Heimdallr {
    public var token = false
    
    override public var hasAccessToken: Bool {
        return token
    }
    
    init(stubError: NSError? = nil) {
        super.init(tokenURL: URL(string: "http://kitsu.io")!)
    }
    
    override func clearAccessToken() {
        token = false
    }
}

class CurrentUserSpec: QuickSpec {
    override func spec() {
        describe("Current User") {
            
            let heim = StubClearHeim()
            let currentUser = CurrentUser(heimdallr: heim, userIDKey: "auth-spec-user")
            
            context("Current user id") {
                it("should correctly store values") {
                    currentUser.userID = 1
                    expect(currentUser.userID).to(equal(1))
                    
                    currentUser.userID = nil
                    expect(currentUser.userID).to(beNil())
                }
            }
            
            context("Logout") {
                it("should clear the user id and token") {
        
                    UserDefaults.standard.set(1, forKey: currentUser.userIDKey)
                    heim.token = true
                    
                    expect(currentUser.userID).to(equal(1))
                    expect(currentUser.isLoggedIn()).to(beTrue())
                    
                    currentUser.logout()
                    expect(currentUser.userID).to(beNil())
                    expect(currentUser.isLoggedIn()).to(beFalse())
                }
            }
            
        }
        
    }
}
