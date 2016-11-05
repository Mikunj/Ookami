//
//  GenreSpec.swift
//  Ookami
//
//  Created by Maka on 5/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
import RealmSwift
import SwiftyJSON
@testable import OokamiKit


class GenreSpec: QuickSpec {
    
    override func spec() {
        describe("Genre") {
            let genreJSON = TestHelper.loadJSON(fromFile: "genre-adventure")!
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
                it("should be able to fetch a valid genre from the database") {
                    let genre = Genre.parse(json: genreJSON)
                    try! testRealm.write {
                        testRealm.add(genre!, update: true)
                    }
                    let g = Genre.get(withId: 2)
                    expect(g).toNot(beNil())
                    expect(g?.name).to(equal("Adventure"))
                }
                
                it("should be able to fetch multiple genres from the database") {
                    var ids: [Int] = []
                    TestHelper.create(object: Genre.self, inRealm: testRealm, amount: 3) { index, genre in
                        genre.id = index
                        ids.append(index)
                    }
                    
                    let genres = Genre.get(withIds: ids)
                    expect(genres).to(haveCount(3))
                }
                
                it("should return a nil genre if no id is found") {
                    let genre = Genre.get(withId: 2)
                    expect(genre).to(beNil())
                }
            }
            
            context("Parsing") {
                it("should parse a genre JSON correctly") {
                    let g = Genre.parse(json: genreJSON)
                    expect(g).toNot(beNil())
                    
                    let genre = g!
                    expect(genre.id).to(equal(2))
                    expect(genre.name).to(equal("Adventure"))
                    expect(genre.slug).to(equal("adventure"))
                    expect(genre.genreDescription).to(equal(""))
                    
                }
                
                it("should return nil on bad JSON") {
                    let json = JSON("badJSON")
                    let genre = Genre.parse(json: json)
                    expect(genre).to(beNil())
                }
            }
        }
    }
}
