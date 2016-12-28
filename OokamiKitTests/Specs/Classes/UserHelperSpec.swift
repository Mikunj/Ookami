//
//  UserHelperSpec.swift
//  Ookami
//
//  Created by Maka on 28/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import RealmSwift


class UserHelperSpec: QuickSpec {
    
    override func spec() {
        describe("User Helper") {
            
            var authenticator: Authenticator!
            var realm: Realm!
            
            beforeEach {
                realm = RealmProvider().realm()
                authenticator = Authenticator(heimdallr: StubAuthHeimdallr(), userIDKey: "user-helper-spec-key")
                
                UserHelper.authenticator = authenticator!
            }
            
            afterEach {
                UserDefaults.standard.removeObject(forKey: authenticator!.userIDKey)
                try! realm.write {
                    realm.deleteAll()
                }
            }
            
            it("should return false if user is not logged in") {
                authenticator.currentUserID = nil
                expect(UserHelper.currentUserHas(media: .anime, id: 1)).to(beFalse())
                expect(UserHelper.currentUserHas(media: .manga, id: 1)).to(beFalse())
            }
            
            it("should return correclty if media is/isn't in users library") {
                
                TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 2) { index, entry in
                    entry.id = index
                    entry.userID = 1
                    let type: Media.MediaType = index % 2 == 0 ? .anime : .manga
                    entry.media = Media(value: [entry.id, 2, type.rawValue])
                }
                
                authenticator.currentUserID = 1
                expect(UserHelper.currentUserHas(media: .anime, id: 1)).to(beFalse())
                expect(UserHelper.currentUserHas(media: .manga, id: 1)).to(beFalse())
                
                expect(UserHelper.currentUserHas(media: .anime, id: 2)).to(beTrue())
                expect(UserHelper.currentUserHas(media: .manga, id: 2)).to(beTrue())
            }
            
            
        }
    }
}
