//
//  MediaFilterSpec.swift
//  Ookami
//
//  Created by Maka on 7/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit

class MediaFilterSpec: QuickSpec {
    
    override func spec() {
        describe("Media Filter") {
            
            context("Additional filters") {
                it("Should correctly add them to the final dictionary") {
                    let filter = MediaFilter()
                    filter.filter(key: "test", value: 1)
                    
                    let dict = filter.construct()
                    expect(dict.keys).to(contain("test"))
                    expect(dict["test"] as? Int).to(equal(1))
                }
            }
            
            context("Year filter") {
                it("should cap the values properley") {
                    let filter = MediaFilter()
                    filter.year = RangeFilter(start: 0, end: 999999)
                    expect(filter.year.start).to(equal(1907))
                    expect(filter.year.end).to(equal(99999))
                    
                    filter.year = RangeFilter(start: 2000, end: 2010)
                    expect(filter.year.start).to(equal(2000))
                    expect(filter.year.end).to(equal(2010))
                }
            }
            
            context("Rating filter") {
                it("should set the end value to 20 if nothing was provided") {
                    let filter = MediaFilter()
                    filter.rating = RangeFilter(start: 2, end: nil)
                    expect(filter.rating.end).to(equal(20))
                }
                
                it("should cap the values properley") {
                    let filter = MediaFilter()
                    filter.rating = RangeFilter(start: 1, end: 29)
                    expect(filter.rating.start).to(equal(2))
                    expect(filter.rating.end).to(equal(20))
                    
                    filter.rating = RangeFilter(start: 3, end: 19)
                    expect(filter.rating.start).to(equal(3))
                    expect(filter.rating.end).to(equal(19))
                }
            }
            
            context("Genre filter") {
                it("Should add genres correctly") {
                    let g = Genre()
                    g.name = "Name"
                    
                    let filter = MediaFilter()
                    expect(filter.genres).to(beEmpty())
                    
                    filter.filter(genres: [g])
                    expect(filter.genres).to(contain("Name"))
                }
            }
            
            context("Construction") {
                it("should correctly output a dictionary") {
                    let filter = MediaFilter()
                    filter.year = RangeFilter(start: 2000, end: nil)
                    filter.rating = RangeFilter(start: 2, end: 20)
                    
                    let defaultDict = filter.construct()
                    
                    expect(defaultDict.keys).to(contain("year"))
                    expect(defaultDict.keys).toNot(contain("averageRating", "genres"))
                    
                    filter.rating = RangeFilter(start: 2, end: 19)
                    let genres: [Genre] = ["Name 1", "Name 2"].map {
                        let g = Genre()
                        g.name = $0
                        return g
                    }
                    
                    filter.filter(genres: genres)
                    
                    let dict = filter.construct()
                    
                    expect(dict.keys).to(contain(["genres", "year", "averageRating"]))
                    expect(dict["year"] as? String).to(equal("2000.."))
                    expect(dict["averageRating"] as? String).to(equal("2..19"))
                    expect(dict["genres"] as? [String]).to(contain("Name 1","Name 2"))
                    
                }
            }
            
        }
    }
}

