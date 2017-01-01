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
            
            var currentUser: CurrentUser!
            var realm: Realm!
            
            beforeEach {
                realm = RealmProvider().realm()
                currentUser = CurrentUser(heimdallr: StubAuthHeimdallr(), userIDKey: "user-helper-spec-key")
                
                UserHelper.currentUser = currentUser
            }
            
            afterEach {
                UserDefaults.standard.removeObject(forKey: currentUser.userIDKey)
                try! realm.write {
                    realm.deleteAll()
                }
            }
            
            it("should return false if user is not logged in") {
                currentUser.userID = nil
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
                
                currentUser.userID = 1
                expect(UserHelper.currentUserHas(media: .anime, id: 1)).to(beFalse())
                expect(UserHelper.currentUserHas(media: .manga, id: 1)).to(beFalse())
                
                expect(UserHelper.currentUserHas(media: .anime, id: 2)).to(beTrue())
                expect(UserHelper.currentUserHas(media: .manga, id: 2)).to(beTrue())
            }
            
            it("should delete entries whos ids were not given") {
                TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 2) { index, entry in
                    entry.id = index
                    entry.userID = 1
                    let type: Media.MediaType = .anime
                    entry.media = Media(value: [entry.id, 2, type.rawValue])
                }
                
                TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 1) { index, entry in
                    entry.id = 10 + index
                    entry.userID = 1
                    let type: Media.MediaType = .manga
                    entry.media = Media(value: [entry.id, 2, type.rawValue])
                }
                
                TestHelper.create(object: LibraryEntry.self, inRealm: realm, amount: 1) { index, entry in
                    entry.id = 20 + index
                    entry.userID = 2
                    let type: Media.MediaType = .anime
                    entry.media = Media(value: [entry.id, 2, type.rawValue])
                }
                
                expect(LibraryEntry.all()).to(haveCount(4))
                UserHelper.deleteEntries(notIn: [1], type: .anime, forUser: 1)
                expect(LibraryEntry.all()).to(haveCount(3))
                expect(LibraryEntry.belongsTo(user: 1)).to(haveCount(2))
            }
            
            
        }
    }
}
