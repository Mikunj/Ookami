//
//  AnimeSpec.swift
//  Ookami
//
//  Created by Maka on 5/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON
import RealmSwift

class AnimeSpec: QuickSpec {
    override func spec() {
        describe("Anime") {
            
            let animeJSON = TestHelper.loadJSON(fromFile: "anime-hunter-hunter")!
            var testRealm: Realm!
            
            beforeEach {
                UserHelper.currentUser = CurrentUser(heimdallr: StubAuthHeimdallr(), userIDKey: "anime-spec-key")
                testRealm = RealmProvider().realm()
            }
            
            afterEach {
                UserHelper.currentUser.userID = nil
                try! testRealm.write {
                    testRealm.deleteAll()
                }
            }
            
            context("Airing") {
                it("should return false if it's a movie") {
                    let a = Anime()
                    a.subtypeRaw = Anime.SubType.movie.rawValue
                    
                    expect(a.isAiring()).to(beFalse())
                }
                
                it("should return false if start date is nil") {
                    let a = Anime()
                    a.subtypeRaw = Anime.SubType.tv.rawValue
                    
                    expect(a.isAiring()).to(beFalse())
                }
                
                it("should return false if the start date if after the current date") {
                    let a = Anime()
                    a.subtypeRaw = Anime.SubType.tv.rawValue
                    a.startDate = Date().addingTimeInterval(999999)
                    
                    expect(a.isAiring()).to(beFalse())
                }
                
                it("should return false if end date is before the current date") {
                    let a = Anime()
                    a.subtypeRaw = Anime.SubType.tv.rawValue
                    a.startDate = Date(timeIntervalSince1970: 0)
                    a.endDate = Date(timeIntervalSince1970: 2)
                    
                    expect(a.isAiring()).to(beFalse())
                }
                
                it("should return true if end date is nil") {
                    let a = Anime()
                    a.subtypeRaw = Anime.SubType.tv.rawValue
                    a.startDate = Date(timeIntervalSince1970: 0)
                    
                    expect(a.isAiring()).to(beTrue())
                }
                
                it("should return true if end date is after current date") {
                    let a = Anime()
                    a.subtypeRaw = Anime.SubType.tv.rawValue
                    a.startDate = Date(timeIntervalSince1970: 0)
                    a.endDate = Date().addingTimeInterval(999999)
                    
                    expect(a.isAiring()).to(beTrue())
                }
            }
            
            context("Cacheable") {
                it("should not clear from cache if anime is in users library") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 1) { _, entry in
                        entry.id = 1
                        entry.userID = 1
                        entry.media = Media(value: [entry.id, 1, Media.MediaType.anime.rawValue])
                    }
                    
                    UserHelper.currentUser.userID = 1
                    
                    let anime = Anime()
                    anime.id = 1
                    
                    let bad = Anime()
                    bad.id = 2
                    
                    expect(anime.canClearFromCache()).to(beFalse())
                    expect(bad.canClearFromCache()).to(beTrue())
                }
                
                it("should delete its titles when clearing from cache") {
                    TestHelper.create(object: Anime.self, inRealm: testRealm, amount: 1) { _, anime in
                        anime.id = 1
                        
                        for key in ["en", "jp"] {
                            let title = MediaTitle()
                            title.key = key
                            title.mediaID = anime.id
                            title.mediaType = Media.MediaType.anime.rawValue
                            anime.titles.append(title)
                        }
                    }
                    
                    expect(Anime.get(withId: 1)?.titles).to(haveCount(2))
                    Anime.get(withId: 1)!.willClearFromCache()
                    expect(Anime.get(withId: 1)?.titles).to(haveCount(0))
                }
                
                it("should delete its media genres when clearing from cache") {
                    TestHelper.create(object: Anime.self, inRealm: testRealm, amount: 1) { _, anime in
                        anime.id = 1
                        
                        for id in [1, 2] {
                            let genre = MediaGenre()
                            genre.genreID = id
                            genre.mediaID = anime.id
                            genre.mediaType = Media.MediaType.anime.rawValue
                            anime.mediaGenres.append(genre)
                        }
                    }
                    
                    expect(Anime.get(withId: 1)?.mediaGenres).to(haveCount(2))
                    Anime.get(withId: 1)!.willClearFromCache()
                    expect(Anime.get(withId: 1)?.mediaGenres).to(haveCount(0))
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
                    expect(anime.titles).to(haveCount(3))
                    expect(anime.averageRating).to(equal(4.4999011528989))
                    expect(anime.posterImage).to(equal("https://media.kitsu.io/anime/poster_images/6448/small.jpg?1431828590"))
                    expect(anime.coverImage).to(equal("https://media.kitsu.io/anime/cover_images/6448/original.jpg?1435367957"))
                    expect(anime.episodeCount).to(equal(148))
                    expect(anime.episodeLength).to(equal(-1))
                    expect(anime.youtubeVideoId).to(equal("5Vy0Hzkxndc"))
                    expect(anime.ageRating).to(equal("R"))
                    expect(anime.ageRatingGuide).to(equal("Violence, Profanity"))
                    expect(anime.subtypeRaw).to(equal("TV"))
                    expect(anime.nsfw).to(beTrue())
                    expect(anime.popularityRank).to(equal(25))
                    expect(anime.ratingRank).to(equal(4))
                    
                    let d = DateFormatter()
                    d.dateFormat = "YYYY-MM-dd"
                    
                    let startDate = d.date(from: "2011-10-02")
                    expect(anime.startDate).to(equal(startDate))
                    expect(anime.endDate).to(beNil())
                    
                    expect(anime.mediaGenres).to(haveCount(3))
                }
                
                it("should not parse a bad JSON") {
                    let j = JSON("bad JSON")
                    let a = Anime.parse(json: j)
                    expect(a).to(beNil())
                }
                
                it("Should not cause redundant Objects to be present in the database") {
                    let a = Anime.parse(json: animeJSON)
                    let b = Anime.parse(json: animeJSON)
                    try! testRealm.write {
                        testRealm.add(a!, update: true)
                        
                        //Check to see if genres were added
                        expect(testRealm.objects(MediaGenre.self)).to(haveCount(3))
                        
                        testRealm.add(b!, update: true)
                    }
                    
                    //The number of objects should be the same even if we add more than 1 object with the same info
                    expect(testRealm.objects(MediaTitle.self)).to(haveCount(a!.titles.count))
                    expect(testRealm.objects(MediaGenre.self)).to(haveCount(a!.mediaGenres.count))
                }
            }
        }
    }
}
