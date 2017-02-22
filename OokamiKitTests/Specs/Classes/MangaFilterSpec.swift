//
//  MangaFilterSpec.swift
//  Ookami
//
//  Created by Maka on 22/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit

class MangaFilterSpec: QuickSpec {
    
    override func spec() {
        describe("Manga Filter") {
            
            context("Constructing") {
                it("should correctly construct a dictionary") {
                    let f = MangaFilter()
                    
                    let defaultDict = f.construct()
                    expect(defaultDict.keys).toNot(contain("subtype"))
                    
                    f.subtypes = [.manga, .manhua]
                    
                    let dict = f.construct()
                    expect(dict["subtype"] as? [String]).to(contain("manga", "manhua"))
                }
            }
        }
    }
}

