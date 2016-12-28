//
//  KitsuRequestSpec.swift
//  Ookami
//
//  Created by Maka on 28/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import Alamofire

class KitsuRequestSpec: QuickSpec {
    
    override func spec() {
        describe("Kitsu Request") {
            
            context("Modifiers") {
                it("should correctly add filters") {
                    let request = KitsuRequest(relativeURL: "/test")
                    request.filter(key: "test", value: 1)
                    expect(request.filters["test"] as? Int).to(equal(1))
                }
                
                it("should correctly add includes") {
                    let request = KitsuRequest(relativeURL: "/test")
                    request.include("test", "test2")
                    expect(request.includes).to(contain("test", "test2"))
                }
                
                it("should correct apply sort") {
                    let request = KitsuRequest(relativeURL: "/test")
                    
                    request.sort(by: "test", ascending: true)
                    expect(request.sort).to(equal("test"))
                    
                    request.sort(by: "test", ascending: false)
                    expect(request.sort).to(equal("-test"))
                    
                    request.sort(by: nil)
                    expect(request.sort).to(beNil())
                }
            }
            
            context("Building") {
                it("should correctly return the parameters") {
                    let request = KitsuRequest(relativeURL: "/test")
                    request.filter(key: "name", value: "a")
                    request.include("test", "test2")
                    request.sort(by: "abc")
                    
                    let params = request.parameters()
                    let filter = params["filter"] as! [String: Any]
                    let name: String? = filter["name"] as? String
                    
                    expect(name).to(equal("a"))
                    expect(params["include"] as? String).to(equal("test,test2"))
                    expect(params["sort"] as? String).to(equal("abc"))
                    
                    request.sort(by: nil)
                    
                    let newParams = request.parameters()
                    expect(newParams.keys).toNot(contain("sort"))
                }
                
                
                it("should build the request correctly") {
                    let url = "/test"
                    let headers: HTTPHeaders = ["test": "1"]
                    let needsAuth = true
                    
                    let request = KitsuRequest(relativeURL: url, headers: headers, needsAuth: needsAuth)
                    request.filter(key: "name", value: "a")
                    request.include("test")
                    request.sort(by: "abc")
                    
                    let r = request.build()
                    expect(r.url).to(equal(url))
                    expect(r.headers).to(equal(headers))
                    expect(r.needsAuth).to(equal(needsAuth))
                    expect(r.method).to(equal(HTTPMethod.get))
                }
            }
            
            context("Copying") {
                it("should make a clean copy") {
                    let original = KitsuRequest(relativeURL: "/test")
                    let request = original.copy()
                    request.filter(key: "abc", value: 1)
                    request.include("abc")
                    request.sort(by: "bob")
                    
                    expect(original.filters).to(beEmpty())
                    expect(original.includes).to(beEmpty())
                    expect(original.sort).to(beNil())
                }
            }
        }
    }
    
}

