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
            
            context("JSON") {
                it("should not parse any non-dictionary objects") {
                    let json = JSON(1)
                    
                    waitUntil { done in
                        Parser().parse(json: json) { parsed in
                            expect(parsed).to(beEmpty())
                            done()
                        }
                    }
                }
                
                context("JSON") {
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
                        
                        waitUntil { done in
                            parser.parse(json: dataJSON) { data in
                                expect(data).to(haveCount(1))
                                done()
                            }
                        }
                        
                        waitUntil { done in
                            parser.parse(json: includeJSON) { include in
                                expect(include).to(haveCount(1))
                                done()
                            }
                        }
                        
                        waitUntil { done in
                            parser.parse(json: badJSON) { bad in
                                expect(bad).to(beEmpty())
                                done()
                            }
                        }
                        
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
                        
                        waitUntil { done in
                            parser.parse(json: dictJSON) { dict in
                                expect(dict).to(haveCount(1))
                                done()
                            }
                        }
                        
                        waitUntil { done in
                            parser.parse(json: arrayJSON) { array in
                                expect(array).to(haveCount(1))
                                done()
                            }
                        }
                        
                        waitUntil { done in
                            parser.parse(json: badJSON) { bad in
                                expect(bad).to(beEmpty())
                                done()
                            }
                        }
                    }
                    
                    it("should not parse an object if they are not registered") {
                        let unregistred = ["type": "unregistered"]
                        
                        let dictJSON = TestHelper.json(data: unregistred)
                        waitUntil { done in
                            Parser().parse(json: dictJSON) { data in
                                expect(data).to(beEmpty())
                                done()
                            }
                        }
                        
                        
                        let arrayJSON = TestHelper.json(data: [unregistred])
                        
                        waitUntil { done in
                            Parser().parse(json: arrayJSON) { data in
                                expect(data).to(beEmpty())
                                done()
                            }
                        }
                    }
                    
                }
                
            }
            
        }
    }
}
