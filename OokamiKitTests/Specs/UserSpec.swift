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
            let userJSON = TestHelper.loadJSON(fromFile: "user")!
            var testRealm: Realm!
            
            beforeEach {
                testRealm = RealmProvider.realm()
            }
            
            afterEach {
                try! testRealm.write {
                    testRealm.deleteAll()
                }
            }
            
            context("Fetching") {
                it("should be able to fetch a valid user from the database") {
                    let u = User.parse(json: userJSON["data"][0])!
                    try! testRealm.write {
                        testRealm.add(u, update: true)
                    }
                    
                    let another = User.get(withId: u.id)
                    expect(another).toNot(beNil())
                    expect(another?.name).to(equal(u.name))
                }
                
                it("should return a nil user if no id is found") {
                    let another = User.get(withId: 1)
                    expect(another).to(beNil())
                }
            }
            
            context("Parsing") {
                it("should parse a user JSON correctly") {
                    let u = User.parse(json: userJSON["data"][0])
                    expect(u).toNot(beNil())
                    
                    let user = u!;
                    expect(user.id).to(equal(2875))
                    expect(user.id).toNot(equal(0))
                    expect(user.name).to(equal("Jigglyslime"))
                    expect(user.pastNames).to(haveCount(0))
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
            }
        }
    }
}
