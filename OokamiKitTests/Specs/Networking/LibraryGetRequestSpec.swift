//
//  LibraryGetRequestSpec.swift
//  Ookami
//
//  Created by Maka on 9/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import Alamofire

class LibraryGETRequestSpec: QuickSpec {
    override func spec() {
        describe("LibraryGETRequest") {
            
            var request: LibraryGETRequest!
            
            beforeEach {
                request = LibraryGETRequest(userID: 1, relativeURL: "/test", headers: ["test": "test"])
            }
            
            context("Building request") {
                it("should build the request correctly") {
                    let r = request.build()
                    expect(r.relativeURL).to(equal(request.url))
                    expect(r.headers).to(equal(request.headers))
                    expect(r.method).to(equal(HTTPMethod.get))
                }
            }
            
            context("Copying") {
                it("should make a clean copy") {
                    request.include(.user)
                    request.page(offset: 1)
                    
                    let r = request.copy() as! LibraryGETRequest
                    request.filter(.user(id: 2))
                    request.exclude(.user)
                    request.page(offset: 0)
                    
                    expect(r.includes).to(contain("user"))
                    expect(r.userID).to(equal(1))
                    expect(r.page.offset).to(equal(1))
                }
            }
            
            context("Filters") {
                it("should correctly modify userID") {
                    request.filter(.user(id: 1))
                    expect(request.userID).to(equal(1))
                    request.filter(.user(id: 2))
                    expect(request.userID).to(equal(2))
                    
                    request.filter([.user(id: 3), .user(id: 4)])
                    expect(request.userID).to(equal(4))
                    expect(request.filters).to(haveCount(0))
                }
                
                it("should correctly add multiple filters") {
                    request.filter([.media(type: .anime), .status(.completed)])
                    expect(request.filters).to(haveCount(2))
                }
                
                it("should apply filters correctly") {
                    request.filter([.user(id: 1), .media(type: .anime), .status(.completed)])
                    var filters = request.applyFilters()
                    expect(filters["user_id"] as? Int).to(equal(1))
                    expect(filters["media_type"] as? String).to(equal("Anime"))
                    expect(filters["status"] as? Int).to(equal(3))
                    
                    request.filter(.statuses([.current, .planned]))
                    filters = request.applyFilters()
                    let statuses = filters["status"] as? [Int]
                    expect(statuses).to(contain([1, 2]))
                }
                
                it("should build the request correctly") {
                    request.filter([.user(id: 1), .media(type: .anime), .status(.completed)])
                    let r = request.build()
                    expect(r.parameters?.keys).to(haveCount(3))
                }
            }
            
            context("Includes") {
                it("should include and exclude info correctly") {
                    request.include([.genres, .user])
                    expect(request.includes).to(contain(["media.genres", "user"]))
                    request.exclude(.genres)
                    request.exclude(.user)
                    
                    request.include(.genres)
                    expect(request.includes).toNot(contain("user"))
                }
                
                it("should build the request correctly") {
                    request.include([.genres, .user])
                    let r = request.build()
                    expect(r.parameters?["include"] as? String).to(equal("media.genres,user"))
                }
            }
            
            context("Page") {
                it("should adjust page info accordingly") {
                    request.page(offset: 1).page(limit: 2)
                    expect(request.page.offset).to(equal(1))
                    expect(request.page.limit).to(equal(2))
                    
                    request.page(offset: -1).page(limit: -1)
                    expect(request.page.offset).to(equal(0))
                    expect(request.page.limit).to(equal(0))
                    
                    request.nextPage()
                    expect(request.page.offset).to(equal(1))
                    
                    request.prevPage()
                    expect(request.page.offset).to(equal(0))
                }
                
                it("should build the request correctly") {
                    request.page(offset: 1).page(limit: 2)
                    let r = request.build()
                    expect(r.parameters?["page"] as? [String: Int]).to(equal(["offset": 1, "limit": 2]))
                }
            }
            
        }
    }
}
