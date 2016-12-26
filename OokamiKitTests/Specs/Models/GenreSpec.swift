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
                testRealm = RealmProvider().realm()
            }
            
            afterEach {
                try! testRealm.write {
                    testRealm.deleteAll()
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
