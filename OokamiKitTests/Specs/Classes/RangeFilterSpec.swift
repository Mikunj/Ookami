//
//  RangeFilterSpec.swift
//  Ookami
//
//  Created by Maka on 7/2/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit

class RangeFilterSpec: QuickSpec {
    
    override func spec() {
        describe("Range Filter") {
            context("Value correction") {
                it("should always make start < end") {
                    var f = RangeFilter<Int>(start: 9, end: 2)
                    f.applyCorrection()
                    expect(f.start).to(equal(2))
                    expect(f.end).to(equal(9))
                    
                    var withoutEnd = RangeFilter<Int>(start: 9, end: nil)
                    withoutEnd.applyCorrection()
                    expect(withoutEnd.start).to(equal(9))
                    expect(withoutEnd.end).to(beNil())
                }
            }
            
            context("Value capping") {
                it("should cap the start and end correctly") {
                    var f1 = RangeFilter<Int>(start: 1, end: 5)
                    f1.capValues(min: 2, max: 4)
                    expect(f1.start).to(equal(2))
                    expect(f1.end).to(equal(4))
                    
                    var f2 = RangeFilter<Int>(start: 2, end: 4)
                    f2.capValues(min: 1, max: 5)
                    expect(f2.start).to(equal(2))
                    expect(f2.end).to(equal(4))
                    
                    var f3 = RangeFilter<Int>(start: 1, end: nil)
                    f3.capValues(min: 2, max: 4)
                    expect(f3.start).to(equal(2))
                    expect(f3.end).to(beNil())
                }
            }
            
            context("Description") {
                it("should append the end value if it's set") {
                    let f = RangeFilter<Int>(start: 10, end: 11)
                    expect(f.description).to(equal("10..11"))
                }
                
                it("should not append the end value if it's nil") {
                    let f = RangeFilter<Int>(start: 10, end: nil)
                    expect(f.description).to(equal("10.."))
                }
            }
        }
    }
}
