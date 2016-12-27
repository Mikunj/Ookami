//
//  UserSpec.swift
//  Ookami
//
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON
import RealmSwift

class UserSpec: QuickSpec {
    
    override func spec() {
        describe("User") {
            let userJSON = TestHelper.loadJSON(fromFile: "user-jigglyslime")!
            var testRealm: Realm!
            
            beforeEach {
                testRealm = RealmProvider().realm()
            }
            
            afterEach {
                try! testRealm.write {
                    testRealm.deleteAll()
                }
            }
            
            context("Cache") {
                it("should not clear from cache if it is the current user") {
                    let authenticator = Authenticator(heimdallr: StubAuthHeimdallr())
                    authenticator.currentUserID = 1
                    
                    let u = User()
                    u.id = 1
                    u.authenticator = authenticator
                    
                    let bad = User()
                    bad.id = 2
                    bad.authenticator = authenticator
                    
                    expect(u.canClearFromCache()).to(beFalse())
                    expect(bad.canClearFromCache()).to(beTrue())
                }
            }
            
            context("Parsing") {
                it("should parse a user JSON correctly") {
                    let u = User.parse(json: userJSON)
                    expect(u).toNot(beNil())
                    
                    let user = u!;
                    expect(user.id).to(equal(2875))
                    expect(user.id).toNot(equal(0))
                    expect(user.name).to(equal("Jigglyslime"))
                    expect(user.pastNames).to(haveCount(2))
                    expect(user.about).to(equal(""))
                    expect(user.bio).to(equal("( ͡° ͜ʖ ͡°) Eᴠᴇʀʏ 60 sᴇᴄᴏɴᴅs ɪɴ Aғʀɪᴄᴀ, ᴀ ᴍɪɴᴜᴛᴇ ᴘᴀssᴇs. Tᴏɢᴇᴛʜᴇʀ ᴡᴇ ᴄᴀɴ sᴛᴏᴘ ᴛʜɪs. Pʟᴇᴀsᴇ sᴘʀᴇᴀᴅ ᴛʜᴇ ᴡᴏʀᴅ ( ͡° ͜ʖ ͡°)"))
                    expect(user.location).to(equal(""))
                    expect(user.website).to(equal(""))
                    expect(user.waifuOrHusbando).to(equal("Waifu"))
                    expect(user.followersCount).to(equal(55))
                    expect(user.followingCount).to(equal(13))
                    expect(user.lifeSpentOnAnime).to(equal(129205))
                    expect(user.birthday).to(equal(""))
                    expect(user.gender).to(equal(""))
                    expect(user.avatarImage).to(equal("https://static.hummingbird.me/users/avatars/000/002/875/original/114367.jpg?1392948358"))
                    expect(user.coverImage).to(equal("https://static.hummingbird.me/users/cover_images/000/002/875/original/2875-rainbowish_fb_cover_by_n3x0n-d5fqohg.png?1389986097"))
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    let createdAt = dateFormatter.date(from: "2013-05-17T06:10:09.481Z")
                    expect(createdAt).toNot(beNil())
                    expect(user.createdAt).to(equal(createdAt!))
                    
                    let updatedAt = dateFormatter.date(from: "2016-10-31T02:11:12.727Z")
                    expect(updatedAt).toNot(beNil())
                    expect(user.updatedAt).to(equal(updatedAt!))
                }
                
                it("should return nil on bad JSON") {
                    let json = JSON("badJSON")
                    let u = User.parse(json: json)
                    expect(u).to(beNil())
                }
                
                it("Should not cause redundant Objects to be present in the database") {
                    let a = User.parse(json: userJSON)
                    let b = User.parse(json: userJSON)
                    try! testRealm.write {
                        testRealm.add(a!)
                        testRealm.add(b!, update: true)
                    }
                    expect(testRealm.objects(UserPastName.self)).to(haveCount(a!.pastNames.count))
                }
            }
        }
    }
}
