//
//  AnimeSpec.swift
//  Ookami
//
//  Created by Maka on 5/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON
import RealmSwift

class AnimeSpec: QuickSpec {
    override func spec() {
        describe("Anime") {
            
            let animeJSON = TestHelper.loadJSON(fromFile: "hunter-hunter")!
            var testRealm: Realm!
            
            beforeEach {
                testRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "anime-spec-realm"))
            }
            
            afterEach {
                try! testRealm.write {
                    testRealm.deleteAll()
                }
            }

            context("Fetching") {
                it("should be able to fetch a valid anime from the database") {
                    let a = Anime.parse(json: animeJSON)!
                    try! testRealm.write {
                        testRealm.add(a, update: true)
                    }
                    
                    let another = Anime.get(withId: a.id, realm: testRealm)
                    expect(another).toNot(beNil())
                    expect(another?.canonicalTitle).to(equal(a.canonicalTitle))
                }
                
                it("should return a nil user if no id is found") {
                    let another = Anime.get(withId: 1, realm: testRealm)
                    expect(another).to(beNil())
                }
            }
            
            context("Parsing") {
                it("should parse an anime JSON correctly") {
                    let a = Anime.parse(json: animeJSON)
                    expect(a).toNot(beNil())
                    
                    let anime = a!
                    expect(anime.id).to(equal(6448))
                    expect(anime.slug).to(equal("hunter-x-hunter-2011"))
                    expect(anime.synopsis).to(equal("A remake of the 1999 TV series of Hunter x Hunter based on the manga by Togashi Yoshihiro.\r\n\r\nA Hunter is one who travels the world doing all sorts of dangerous tasks. From capturing criminals to searching deep within uncharted lands for any lost treasures. Gon is a young boy whose father disappeared long ago, being a Hunter. He believes if he could also follow his father's path, he could one day reunite with him.\r\n\r\nAfter becoming 12, Gon leaves his home and takes on the task of entering the Hunter exam, notorious for its low success rate and high probability of death to become an official Hunter. He befriends the revenge-driven Kurapika, the doctor-to-be Leorio and the rebellious ex-assassin Killua in the exam, with their friendship prevailing throughout the many trials and threats they come upon taking on the dangerous career of a Hunter."))
                    expect(anime.canonicalTitle).to(equal("Hunter x Hunter (2011)"))
                    expect(anime.titles.count).to(equal(3))
                    expect(anime.averageRating).to(equal(4.4999011528989))
                    expect(anime.posterImage).to(equal("https://static.hummingbird.me/anime/poster_images/000/006/448/original/QxC5cby.png?1431828590"))
                    expect(anime.coverImage).to(equal("https://static.hummingbird.me/anime/cover_images/000/006/448/original/kANsAC1.jpg?1435367957"))
                    expect(anime.episodeCount).to(equal(148))
                    expect(anime.episodeLength).to(equal(-1))
                    expect(anime.youtubeVideoId).to(equal("5Vy0Hzkxndc"))
                    expect(anime.ageRating).to(equal("R"))
                    expect(anime.ageRatingGuide).to(equal("Violence, Profanity"))
                    
                    let d = DateFormatter()
                    d.dateFormat = "YYYY-MM-dd"
                    
                    let startDate = d.date(from: "2011-10-02")
                    expect(anime.startDate).to(equal(startDate))
                    expect(anime.endDate).to(beNil())
                }
                
                it("should not parse a bad JSON") {
                    let j = JSON("bad JSON")
                    let a = Anime.parse(json: j)
                    expect(a).to(beNil())
                }
            }
        }
    }
}
