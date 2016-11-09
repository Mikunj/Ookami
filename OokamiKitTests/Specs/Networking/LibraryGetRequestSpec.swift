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
                request = LibraryGETRequest(relativeURL: "/test", headers: ["test": "test"])
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
                    request.filter(userID: 1)
                    request.include(.user)
                    request.page(offset: 1)
                    
                    let r = request.copy() as! LibraryGETRequest
                    request.filter(userID: 2)
                    request.exclude(.user)
                    request.page(offset: 0)
                    
                    expect(r.includes).to(contain("user"))
                    expect(r.filters["user_id"] as? Int).to(equal(1))
                    expect(r.page.offset).to(equal(1))
                }
            }
            
            context("Filters") {
                it("should add filters correctly") {
                    request.filter(userID: 1).filter(media: .anime).filter(status: .completed)
                    expect(request.filters["user_id"] as? Int).to(equal(1))
                    expect(request.filters["media_type"] as? String).to(equal("Anime"))
                    expect(request.filters["status"] as? Int).to(equal(3))
                    
                    request.filter(statuses: [.completed, .current])
                    let statuses = request.filters["status"] as? [Int]
                    expect(statuses).to(contain([1, 3]))
                }
                
                it("should build the request correctly") {
                    request.filter(userID: 1).filter(media: .anime).filter(status: .completed)
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
                    request.include(.genres).include(.user)
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
