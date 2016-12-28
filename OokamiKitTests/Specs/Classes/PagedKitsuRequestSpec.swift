//
//  PagedKitsuRequestSpec.swift
//  Ookami
//
//  Created by Maka on 28/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit

class PagedKitsuRequestSpec: QuickSpec {
    
    override func spec() {
        describe("Paged Kitsu Request") {
            
            context("Modifiers") {
                it("should correctly modify page limit") {
                    let request = PagedKitsuRequest(relativeURL: "/test")
                    request.page(limit: 1)
                    expect(request.page.limit).to(equal(1))
                    
                    request.page(limit: -1)
                    expect(request.page.limit).to(equal(0))
                }
                
                it("should correctly modify page offset") {
                    let request = PagedKitsuRequest(relativeURL: "/test")
                    request.page(offset: 1)
                    expect(request.page.offset).to(equal(1))
                    
                    request.page(offset: -1)
                    expect(request.page.offset).to(equal(0))
                }
            }
            
            context("Building") {
                it("should correctly return the parameters") {
                    let request = PagedKitsuRequest(relativeURL: "/test")
               
                    request.page(limit: 1)
                    request.page(offset: 1)
                    
                    let params = request.parameters()
                    let page = params["page"] as! [String: Any]
                    let offset = page["offset"] as? Int
                    let limit = page["limit"] as? Int
                    
                    expect(offset).to(equal(1))
                    expect(limit).to(equal(1))
                }
                
                
            }
            
            context("Copying") {
                it("should make a clean copy") {
                    let original = PagedKitsuRequest(relativeURL: "/test")
                    let request = original.copy() as! PagedKitsuRequest
                    request.filter(key: "abc", value: 1)
                    request.include("abc")
                    request.sort(by: "bob")
                    request.page(limit: 1)
                    request.page(offset: 1)
                    
                    expect(original.filters).to(beEmpty())
                    expect(original.includes).to(beEmpty())
                    expect(original.sort).to(beNil())
                    expect(original.page.offset).toNot(equal(request.page.offset))
                    expect(original.page.limit).toNot(equal(request.page.limit))
                }
            }
        }
    }
    
}

