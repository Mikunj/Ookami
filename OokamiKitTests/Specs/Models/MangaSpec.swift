//
//  MangaSpec.swift
//  Ookami
//
//  Created by Maka on 30/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON
import RealmSwift

class MangaSpec: QuickSpec {
    override func spec() {
        describe("Manga") {
            
            let mangaJSON = TestHelper.loadJSON(fromFile: "manga-one-punch-man")!
            var testRealm: Realm!
            
            beforeEach {
                UserHelper.currentUser = CurrentUser(heimdallr: StubAuthHeimdallr(), userIDKey: "manga-spec-key")
                testRealm = RealmProvider().realm()
            }
            
            afterEach {
                UserHelper.currentUser.userID = nil
                try! testRealm.write {
                    testRealm.deleteAll()
                }
            }
            
            context("Cacheable") {
                it("should not clear from cache if manga is in users library") {
                    TestHelper.create(object: LibraryEntry.self, inRealm: testRealm, amount: 1) { _, entry in
                        entry.id = 1
                        entry.userID = 1
                        entry.media = Media(value: [entry.id, 1, Media.MediaType.manga.rawValue])
                    }
                    
                    UserHelper.currentUser.userID = 1
                    
                    let manga = Manga()
                    manga.id = 1
                    
                    let bad = Manga()
                    bad.id = 2
                    
                    expect(manga.canClearFromCache()).to(beFalse())
                    expect(bad.canClearFromCache()).to(beTrue())
                }
                
                it("should delete its titles when clearing from cache") {
                    TestHelper.create(object: Manga.self, inRealm: testRealm, amount: 1) { _, manga in
                        manga.id = 1
                        
                        for key in ["en", "jp"] {
                            let title = MediaTitle()
                            title.key = key
                            title.mediaID = manga.id
                            title.mediaType = Media.MediaType.manga.rawValue
                            manga.titles.append(title)
                        }
                    }
                    
                    expect(Manga.get(withId: 1)?.titles).to(haveCount(2))
                    Manga.get(withId: 1)!.willClearFromCache()
                    expect(Manga.get(withId: 1)?.titles).to(haveCount(0))
                }
            }
            
            context("Parsing") {
                it("should parse a manga JSON correctly") {
                    let m = Manga.parse(json: mangaJSON)
                    expect(m).toNot(beNil())
                    
                    let manga = m!
                    expect(manga.id).to(equal(24147))
                    expect(manga.slug).to(equal("one-punch-man"))
                    expect(manga.synopsis).to(equal("Everything about a young man named Saitama screams \"AVERAGE,” from his lifeless expression, to his bald head, to his unimpressive physique. However, this average-looking fellow doesn't have your average problem... He's actually a superhero that's looking for tough opponents! The problem is, every time he finds a promising candidate he beats the snot out of them in one punch. Can Saitama finally find an evil villain strong enough to challenge him? Follow Saitama through his hilarious romps as he searches for new bad guys to challenge!\n\n(Source: Viz)"))
                    expect(manga.canonicalTitle).to(equal("One Punch-Man"))
                    expect(manga.titles).to(haveCount(2))
                    expect(manga.averageRating).to(equal(4.49896219123721))
                    expect(manga.posterImage).to(equal("https://media.kitsu.io/manga/poster_images/24147/small.jpg?1434302168"))
                    expect(manga.coverImage).to(equal("https://media.kitsu.io/manga/cover_images/24147/original.jpg?1430793546"))
                    expect(manga.chapterCount).to(equal(-1))
                    expect(manga.volumeCount).to(equal(0))
                    expect(manga.mangaTypeRaw).to(equal("manga"))

                    let d = DateFormatter()
                    d.dateFormat = "YYYY-MM-dd"
                    
                    let startDate = d.date(from: "2012-06-14")
                    expect(manga.startDate).to(equal(startDate))
                    expect(manga.endDate).to(beNil())
                    
                    expect(manga.genres).to(haveCount(6))
                }
                
                it("should not parse a bad JSON") {
                    let j = JSON("bad JSON")
                    let m = Manga.parse(json: j)
                    expect(m).to(beNil())
                }
                
                it("Should not cause redundant Objects to be present in the database") {
                    let a = Manga.parse(json: mangaJSON)
                    let b = Manga.parse(json: mangaJSON)
                    try! testRealm.write {
                        testRealm.add(a!, update: true)
                        
                        //Check to see if genres were added
                        expect(testRealm.objects(Genre.self)).to(haveCount(6))
                        
                        testRealm.add(b!, update: true)
                    }
                    
                    //The number of objects should be the same even if we add more than 1 object with the same info
                    expect(testRealm.objects(MediaTitle.self)).to(haveCount(a!.titles.count))
                    expect(testRealm.objects(Genre.self)).to(haveCount(a!.genres.count))
                }
            }
        }
    }
}

