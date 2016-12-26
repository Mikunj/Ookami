//
//  ParserSpec.swift
//  Ookami
//
//  Created by Maka on 26/12/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON

class ParserSpec: QuickSpec {
    
    override func spec() {
        describe("Parser") {
            context("Registering Parsers") {
                it("should register JSONParsables") {
                    let parser = Parser()
                    parser.register(object: StubRealmObject.self)
                    expect(parser.parsers.keys).to(contain(StubRealmObject.typeString))
                }
                
                it("should register regular parsers") {
                    let parser = Parser()
                    parser.register(type: "test") { _ in
                        return nil
                    }
                    expect(parser.parsers.keys).to(contain("test"))
                }
            }
            
            context("Arrays") {
                it("should not parse any other type") {
                    let json = JSON(1)
                    let parsed = Parser().parseArray(json: json)
                    expect(parsed).to(beEmpty())
                }
                
                it("should not parse objects that are not registered") {
                    let json = JSON([["type": "unknown"]])
                    let parsed = Parser().parseArray(json: json)
                    expect(parsed).to(beEmpty())
                }
                
                it("should parse registered objects") {
                    let json = JSON([["type": StubRealmObject.typeString, "id": 1], ["type": "unkown"]])
                    let parser = Parser()
                    parser.register(object: StubRealmObject.self)
                    
                    let parsed = parser.parseArray(json: json)
                    expect(parsed).to(haveCount(1))
                }
            }
            
            context("Dictionaries") {
                it("should not parse any other type") {
                    let json = JSON(1)
                    let parsed = Parser().parseDictionary(json: json)
                    expect(parsed).to(beNil())
                }
                
                it("should not parse objects that are not registered") {
                    let json = JSON(["type": "unknown"])
                    let parsed = Parser().parseDictionary(json: json)
                    expect(parsed).to(beNil())
                }
                
                it("should parse registered objects") {
                    let json = JSON(["type": StubRealmObject.typeString, "id": 1])
                    let parser = Parser()
                    parser.register(object: StubRealmObject.self)
                    
                    let parsed = parser.parseDictionary(json: json)
                    expect(parsed).toNot(beNil())
                }
            }
            
            context("JSON") {
                it("should not parse any non-dictionary objects") {
                    let json = JSON(1)
                    let parsed = Parser().parse(json: json)
                    expect(parsed).to(beEmpty())
                }
                
                it("should only parse data and included objects") {
                    let parser = Parser()
                    parser.register(type: "object") { _ in
                        let object = StubRealmObject()
                        object.id = 1
                        return object
                    }
                    
                    let dataJSON = TestHelper.json(data: ["type": "object"])
                    let includeJSON = TestHelper.json(included: ["type": "object"])
                    let badJSON = JSON(["string": "hi"])
                    
                    let data = parser.parse(json: dataJSON)
                    expect(data).to(haveCount(1))
                    
                    let include = parser.parse(json: includeJSON)
                    expect(include).to(haveCount(1))
                    
                    let bad = parser.parse(json: badJSON)
                    expect(bad).to(beEmpty())
                }
                
                it("should parse only dictionary and array objects") {
                    let parser = Parser()
                    parser.register(type: "object") { _ in
                        let object = StubRealmObject()
                        object.id = 1
                        return object
                    }
                    
                    let dictJSON = TestHelper.json(data: ["type": "object"])
                    let arrayJSON = TestHelper.json(data: [["type": "object"]])
                    let badJSON = TestHelper.json(data: 1)
                    
                    let data = parser.parse(json: dictJSON)
                    expect(data).to(haveCount(1))
                    
                    let include = parser.parse(json: arrayJSON)
                    expect(include).to(haveCount(1))
                    
                    let bad = parser.parse(json: badJSON)
                    expect(bad).to(beEmpty())
                }
            }
            
        }
    }
}
