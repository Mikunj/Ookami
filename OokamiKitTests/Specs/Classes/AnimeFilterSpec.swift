//
//  AnimeFilterSpec.swift
//  Ookami
//
//  Created by Maka on 7/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit

class AnimeFilterSpec: QuickSpec {
    
    override func spec() {
        describe("Anime Filter") {
            context("Episode filter") {
                it("should cap the episodes properley") {
                    let f = AnimeFilter()
                    f.episodes = RangeFilter(start: -1, end: 999999)
                    expect(f.episodes.start).to(equal(1))
                    expect(f.episodes.end).to(equal(99999))
                    
                    f.episodes = RangeFilter(start: 2, end: 10)
                    expect(f.episodes.start).to(equal(2))
                    expect(f.episodes.end).to(equal(10))
                }
            }
            
            context("Constructing") {
                it("should correctly construct a dictionary") {
                    let f = AnimeFilter()
                    f.episodes = RangeFilter(start: 1, end: nil)
                    
                    let defaultDict = f.construct()
                    expect(defaultDict.keys).toNot(contain("episodeCount", "ageRating", "streamers", "season"))
                    
                    f.ageRatings = [.g, .r18]
                    f.streamers = [.netflix, .hulu]
                    f.seasons = [.spring, .summer]
                    f.episodes = RangeFilter(start: 1, end: 10)
                    
                    let dict = f.construct()
                    expect(dict["episodeCount"] as? String).to(equal("..10"))
                    expect(dict["ageRating"] as? [String]).to(contain("G", "R18"))
                    expect(dict["streamers"] as? [String]).to(contain("Netflix", "Hulu"))
                    expect(dict["season"] as? [String]).to(contain("spring", "summer"))
                    
                    f.episodes = RangeFilter(start: 2, end: 10)
                    expect(f.construct()["episodeCount"] as? String).to(equal("2..10"))
                }
            }
        }
    }
}
