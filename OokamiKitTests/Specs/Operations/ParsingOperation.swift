//
//  ParsingOperation.swift
//  Ookami
//
//  Created by Maka on 7/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON
import OHHTTPStubs
import RealmSwift

class ParsingOperationSpec: QuickSpec {
    
    override func spec() {
        
        describe("ParsingOperation") {
            //Take care of cases where you add 2 operations to a queue, the tests may return unknown results because the operation wasn't started
            var queue: OperationQueue = OperationQueue()
            
            beforeEach {
                
                queue = OperationQueue()
                queue.maxConcurrentOperationCount = 1
            }
            
            afterEach {
                let realm = RealmProvider.realm()
                try! realm.write {
                    realm.deleteAll()
                }
                queue.cancelAllOperations()
            }
            
            context("Registering parsers") {
                it("should correctly register new parsers") {
                    let json = JSON(["name": "hi"])
                    let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                    }
                    
                    let t: ParsingOperation.ParserBlock = { json in
                        return nil
                    }
                    operation.register(type: "generic", parser: t)
                    expect(operation.parsers.keys).to(contain("generic"))
                }
                
                it("should correctly register default parsers") {
                    let json = JSON(["name": "hi"])
                    let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                    }
                    
                    operation.registerParsers()
                    expect(operation.parsers).to(haveCount(4))
                    expect(operation.parsers.keys).to(contain([Anime.typeString, Genre.typeString, User.typeString, LibraryEntry.typeString]))
                }
            }
            
            context("Parse Function") {
                //We can safely call these tests without worrying about asynchronous code as the .parse function itself is synchronous
                
                it("should only accept array values") {
                    let intJSON = JSON(1)
                    let arrayJSON = JSON([intJSON])
                    let operation = ParsingOperation(json: intJSON, realm: RealmProvider.realm) { failed in
                    }
                    
                    let result = operation.parse(objectArray: intJSON)
                    expect(result).to(beNil())
                    
                    let arrayResult = operation.parse(objectArray: arrayJSON)
                    expect(arrayResult).toNot(beNil())
                }
                
                it("should return the object if no parser exists") {
                    let object = ["type": "parseF", "name": "1"]
                    let arrayJSON = JSON([object])
                    let operation = ParsingOperation(json: arrayJSON, realm: RealmProvider.realm) { failed in
                    }
                    
                    let result = operation.parse(objectArray: arrayJSON)
                    expect(result).toNot(beNil())
                    expect(result).to(contain(JSON(object)))
                }
                
                it("should return empty array if object parsed") {
                    let object = ["type": "parseF"]
                    let json = JSON([object])
                    let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                    }
                    
                    operation.register(type: "parseF") { _ in
                        let a = Anime()
                        a.id = 1
                        return a
                    }
                    
                    let result = operation.parse(objectArray: json)
                    expect(result).toNot(beNil())
                    expect(result).to(beEmpty())
                    expect(Anime.get(withId: 1)).toEventuallyNot(beNil())
                }
                
                it("should call the correct parser") {
                    let object = ["type": "parseF"]
                    let other = ["type": "another", "name": "other"]
                    var parseFCalled = false
                    
                    let json = JSON([object, other])
                    let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                    }
                    
                    operation.register(type: "parseF") { _ in
                        parseFCalled = true
                        let a = Anime()
                        a.id = 1
                        return a
                    }
                    
                    let result = operation.parse(objectArray: json)
                    expect(result).toNot(beNil())
                    expect(result).to(haveCount(1))
                    expect(result).to(contain(JSON(other)))
                    expect(parseFCalled).to(beTrue())
                    expect(Anime.get(withId: 1)).toEventuallyNot(beNil())
                }
                
            }
            
            context("Operation") {
                it ("should only parse dictionary values") {
                    let object = ["type": "object"]
                    let json = JSON(["data": [object]])
                    var response: [JSON]? = []
                    let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                        response = failed
                    }
                    operation.register(type: "object") { _ in
                        let a = Anime()
                        a.id = 1
                        return a
                    }
                    
                    queue.addOperation(operation)
                    expect(response).toEventually(beEmpty())
                    expect(Anime.get(withId: 1)).toEventuallyNot(beNil())
                }
                
                it ("should not parse any other values") {
                    var response: [JSON]?
                    let json = JSON(1)
                    
                    let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                        response = failed
                    }
                    
                    queue.addOperation(operation)
                    expect(response).toEventuallyNot(beNil())
                    expect(response).toEventually(haveCount(1))
                    expect(response).toEventually(contain(json))
                }
                
                it("should not parse a JSON object without `data` or `included` fields") {
                    var response: [JSON]?
                    let json = JSON(["name": "hi"])
                    
                    let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                        response = failed
                    }
                    
                    queue.addOperation(operation)
                    expect(response).toEventuallyNot(beNil())
                    expect(response).toEventually(haveCount(1))
                    expect(response).toEventually(contain(json))
                }
                
                context("Parsers") {
                    
                    it("should return object in failed array if parser returns nil") {
                        var parserCalled = false
                        var response: [JSON]?
                        
                        let other = ["type": "another", "name": "other"]
                        let json = JSON(["data": [other]])
                        let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                            response = failed
                        }
                        operation.register(type: "another") { json -> Object? in
                            parserCalled = true
                            return nil
                        }
                        
                        queue.addOperation(operation)
                        expect(parserCalled).toEventually(beTrue())
                        expect(response).toEventuallyNot(beNil())
                        expect(response).toEventually(contain(JSON(other)))
                    }
                    
                    it("should return object in failed array if no parser exists") {
                        var response: [JSON]? = nil
                        
                        let other = ["type": "another", "name": "bad"]
                        let json = JSON(["data": [other]])
                        let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                            response = failed
                        }
                        
                        queue.addOperation(operation)
                        expect(response).toEventuallyNot(beNil())
                        expect(response).toEventually(contain(JSON(other)))
                    }
                }
                
                context("Included objects") {
                    it("should parse included objects correctly") {
                        var response: [JSON]?
                        
                        let object = ["type": "generic"]
                        let json = JSON(["included": [object]])
                        let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                            response = failed
                        }
                        operation.register(type: "generic") { json -> Object? in
                            let a = Anime()
                            a.id = 1
                            return a
                        }
                        
                        queue.addOperation(operation)
                        expect(response).toEventually(beEmpty())
                        expect(Anime.get(withId: 1)).toEventuallyNot(beNil())
                    }
                    
                    it("should not parse `included` if it's not an array") {
                        var response: [JSON]? = nil
                        
                        let json = JSON(["included": "hi"])
                        let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                            response = failed
                        }
                        
                        queue.addOperation(operation)
                        expect(response).toEventuallyNot(beNil())
                        expect(response).toEventually(contain("hi"))
                    }
                }
                
                context("Data objects") {
                    it("should parse data objects correctly") {
                        var response: [JSON]?
                        
                        let object = ["type": "generic"]
                        let json = JSON(["data": [object]])
                        let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                            response = failed
                        }
                        operation.register(type: "generic") { json -> Object? in
                            let a = Anime()
                            a.id = 1
                            return a
                        }
                        
                        queue.addOperation(operation)
                        expect(response).toEventually(beEmpty())
                        expect(Anime.get(withId: 1)).toEventuallyNot(beNil())
                    }
                    
                    it("should not parse `data` if it's not an array") {
                        var response: [JSON]? = nil
                        
                        let json = JSON(["data": "hi"])
                        let operation = ParsingOperation(json: json, realm: RealmProvider.realm) { failed in
                            response = failed
                        }
                        
                        queue.addOperation(operation)
                        expect(response).toEventuallyNot(beNil())
                        expect(response).toEventually(contain(["hi"]))
                    }
                }
                
                context("Actual JSON Data") {
                    it("should parse everything!") {
                        var response: [JSON]? = nil
                        let realm = RealmProvider.realm()
                        let json = TestHelper.loadJSON(fromFile: "mix-anime-user-entry-genre")
                        expect(json).toNot(beNil())
                        
                        let operation = ParsingOperation(json: json!, realm: RealmProvider.realm) { failed in
                            response = failed
                        }
                        
                        queue.addOperation(operation)
                        expect(response).toEventually(beEmpty())
                        expect(realm.objects(User.self)).toEventually(haveCount(1))
                        expect(realm.objects(Anime.self)).toEventually(haveCount(1))
                        expect(realm.objects(Genre.self)).toEventually(haveCount(1))
                        expect(realm.objects(LibraryEntry.self)).toEventually(haveCount(1))
                    }
                }
            }
            
        }
    }
}
