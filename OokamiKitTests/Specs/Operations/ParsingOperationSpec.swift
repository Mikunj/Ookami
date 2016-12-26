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
                let realm = RealmProvider().realm()
                
                try! realm.write {
                    realm.deleteAll()
                }
                queue.cancelAllOperations()
            }
            
            context("Adding parsed objects") {
                it("should be able to add object id to a clean dictionary") {
                    let json = JSON(["name": "hi"])
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { failed in
                    }
                    
                    let object = StubRealmObject()
                    object.id = 1
                    
                    operation.add(parsedObject: object, forType: "test")
                    expect(operation.parsedObjects.keys).to(contain("test"))
                    expect(operation.parsedObjects["test"] as! [Int]?).to(contain(1))
                }
                
                it("should be able to add object id to an existing key") {
                    let json = JSON(["name": "hi"])
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { failed in
                    }
                    
                    let object = StubRealmObject()
                    object.id = 1
                    
                    let object2 = StubRealmObject()
                    object2.id = 2
                    
                    
                    operation.add(parsedObject: object, forType: "test")
                    operation.add(parsedObject: object2, forType: "test")
                    expect(operation.parsedObjects.keys).to(contain("test"))
                    expect(operation.parsedObjects["test"] as! [Int]?).to(contain([1, 2]))
                }
            }
            
            context("Registering parsers") {
                it("should correctly register new parsers") {
                    let json = JSON(["name": "hi"])
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { failed in
                    }
                    
                    let t: ParsingOperation.ParserBlock = { json in
                        return nil
                    }
                    operation.register(type: "generic", parser: t)
                    expect(operation.parsers.keys).to(contain("generic"))
                }
                
                it("should correctly register default parsers") {
                    let json = JSON(["name": "hi"])
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { failed in
                    }
                    
                    operation.registerParsers()
                    expect(operation.parsers).to(haveCount(4))
                    expect(operation.parsers.keys).to(contain([Anime.typeString, Genre.typeString, User.typeString, LibraryEntry.typeString]))
                }
            }
            
            context("Parse Array Function") {
                it("should only accept array values") {
                    let arrayJSON = JSON([1])
                    let intJSON = JSON(1)
                    let operation = ParsingOperation(json: arrayJSON, realm: RealmProvider().realm) { failed in
                    }
                    
                    let arrayResult = operation.parseArray(json: arrayJSON, realm: RealmProvider().realm())
                    expect(arrayResult).toNot(beNil())
                    
                    let result = operation.parseArray(json: intJSON, realm: RealmProvider().realm())
                    expect(result).to(beNil())
                }
            }
            
            context("Parse Dictionary Function") {
                it("should only accept dictionary values") {
                    let dictJSON = JSON(["id": 1])
                    let intJSON = JSON(1)
                    let operation = ParsingOperation(json: dictJSON, realm: RealmProvider().realm) { failed in
                    }
                    
                    let dictResult = operation.parseDictionary(json: dictJSON, realm: RealmProvider().realm())
                    expect(dictResult).to(beFalse())
                    
                    let result = operation.parseArray(json: intJSON, realm: RealmProvider().realm())
                    expect(result).to(beNil())
                }
            }
            
            context("Parse Function") {
                //We can safely call these tests without worrying about asynchronous code as the .parse function itself is synchronous
                context("JSON Values") {
                    it("should accept array values") {
                        let arrayJSON = JSON([1])
                        let operation = ParsingOperation(json: arrayJSON, realm: RealmProvider().realm) { failed in
                        }
                        
                        let arrayResult = operation.parse(json: arrayJSON)
                        expect(arrayResult).toNot(beNil())
                    }
                    
                    it("should accept dictionary values") {
                        let dictJSON = JSON(["id": 1])
                        let operation = ParsingOperation(json: dictJSON, realm: RealmProvider().realm) { failed in
                        }
                        
                        let dictResult = operation.parse(json: dictJSON)
                        expect(dictResult).toNot(beNil())
                    }
                    
                    it("should not accept other values") {
                        let intJSON = JSON(1)
                        let operation = ParsingOperation(json: intJSON, realm: RealmProvider().realm) { failed in
                        }
                        
                        let result = operation.parse(json: intJSON)
                        expect(result).to(beNil())
                    }
                    
                }
                
                it("should return the object if no parser exists") {
                    let object = ["type": "parseF", "name": "1"]
                    let arrayJSON = JSON([object])
                    let operation = ParsingOperation(json: arrayJSON, realm: RealmProvider().realm) { failed in
                    }
                    
                    let result = operation.parse(json: arrayJSON)
                    expect(result).toNot(beNil())
                    expect(result).to(contain(JSON(object)))
                }
                
                it("should return empty array if object parsed") {
                    let object = ["type": "parseF"]
                    let json = JSON([object])
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { failed in
                    }
                    
                    operation.register(type: "parseF") { _ in
                        let a = StubRealmObject()
                        a.id = 1
                        return a
                    }
                    
                    let result = operation.parse(json: json)
                    expect(result).toNot(beNil())
                    expect(result).to(beEmpty())
                    expect(StubRealmObject.get(withId: 1)).toEventuallyNot(beNil())
                }
                
                it("should call the correct parser") {
                    let object = ["type": "parseF"]
                    let other = ["type": "another", "name": "other"]
                    var parseFCalled = false
                    
                    let json = JSON([object, other])
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { failed in
                    }
                    
                    operation.register(type: "parseF") { _ in
                        parseFCalled = true
                        let a = StubRealmObject()
                        a.id = 1
                        return a
                    }
                    
                    let result = operation.parse(json: json)
                    expect(result).toNot(beNil())
                    expect(result).to(haveCount(1))
                    expect(result).to(contain(JSON(other)))
                    expect(parseFCalled).to(beTrue())
                    expect(StubRealmObject.get(withId: 1)).toEventuallyNot(beNil())
                }
                
                it("should be able to parse multiple objects from different parsers") {
                    let object = ["type": "parseF"]
                    let other = ["type": "another", "name": "other"]
                    
                    let json = JSON([object, other])
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { failed in
                    }
                    
                    operation.register(type: "parseF") { _ in
                        let a = StubRealmObject()
                        a.id = 1
                        return a
                    }
                    
                    operation.register(type: "another") { _ in
                        let a = StubRealmObject()
                        a.id = 2
                        return a
                    }
                    
                    let result = operation.parse(json: json)
                    expect(result).toNot(beNil())
                    expect(result).to(beEmpty())
                    expect(StubRealmObject.get(withIds: [1, 2])).toEventually(haveCount(2))
                }
                
            }
            
            context("Parsed Objects Dictionary") {
                it("should return nil if a non-dictionary json is passed") {
                    var ids: [String: [Any]]? = [:]
                    let json = JSON(1)
                    
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { parsed, _ in
                        ids = parsed
                    }
                    queue.addOperation(operation)
                    expect(ids).toEventually(beNil())
                }
                
                it("should return nil if JSON object has no 'data' or 'included' field") {
                    var ids: [String: [Any]]? = [:]
                    let json = JSON(["name": "test"])
                    
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { parsed, _ in
                        ids = parsed
                    }
                    
                    queue.addOperation(operation)
                    expect(ids).toEventually(beNil())
                }
                
                it("should return ids of parsed objects") {
                    let object = ["type": "object"]
                    let json = JSON(["data": [object]])
                    var ids: [String: [Any]]?
                    
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { parsed, _ in
                        ids = parsed
                    }
                    
                    operation.register(type: "object") { _ in
                        let a = StubRealmObject()
                        a.id = 1
                        return a
                    }
                    
                    queue.addOperation(operation)
                    expect(ids).toEventuallyNot(beNil())
                    expect(ids?.keys).toEventually(contain("object"))
                    expect(ids?["object"] as! [Int]?).toEventually(contain(1))
                }
                
                it("should not add ids to parsed objects if object is nil") {
                    let object = ["type": "object"]
                    let json = JSON(["data": [object]])
                    var ids: [String: [Any]]?
                    
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { parsed, _ in
                        ids = parsed
                    }
                    
                    operation.register(type: "object") { _ in
                        return nil
                    }
                    
                    queue.addOperation(operation)
                    expect(ids).toEventuallyNot(beNil())
                    expect(ids).toEventually(beEmpty())
                    expect(ids?.keys).toEventuallyNot(contain("object"))
                }
                
                it("should not add ids to parsed objects if parser not found") {
                    let object = ["type": "object"]
                    let json = JSON(["data": [object]])
                    var ids: [String: [Any]]?
                    
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { parsed, _ in
                        ids = parsed
                    }
                    
                    queue.addOperation(operation)
                    expect(ids).toEventuallyNot(beNil())
                    expect(ids).toEventually(beEmpty())
                    expect(ids?.keys).toEventuallyNot(contain("object"))
                }
            }
            
            context("Operation") {
                it ("should only parse dictionary values") {
                    let object = ["type": "object"]
                    let json = JSON(["data": [object]])
                    var response: [JSON]? = []
                    
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { _, failed in
                        response = failed
                    }
                    
                    operation.register(type: "object") { _ in
                        let a = StubRealmObject()
                        a.id = 1
                        return a
                    }
                    
                    queue.addOperation(operation)
                    expect(response).toEventually(beNil())
                    expect(StubRealmObject.get(withId: 1)).toEventuallyNot(beNil())
                }
                
                it ("should not parse any other values") {
                    var response: [JSON]?
                    let json = JSON(1)
                    
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { _, failed in
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
                    
                    let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { _, failed in
                        response = failed
                    }
                    
                    queue.addOperation(operation)
                    expect(response).toEventuallyNot(beNil())
                    expect(response).toEventually(haveCount(1))
                    expect(response).toEventually(contain(json))
                }
                
                context("Cancel") {
                    it("should not call the callback block") {
                        var blockCalled: Bool = false
                        let json = JSON(["name": "hi"])
                        
                        //Make it so we can actually call cancel on the parser
                        class StubParse: ParsingOperation {
                            override func main() {
                                Thread.sleep(forTimeInterval: 2.0)
                                super.main()
                            }
                        }
                        
                        let operation = StubParse(json: json, realm: RealmProvider().realm) { _, failed in
                            blockCalled = true
                        }
                        
                        waitUntil(timeout: 3.0) { done in
                            operation.completionBlock = {
                                expect(blockCalled).to(beFalse())
                                done()
                            }
                            queue.addOperation(operation)
                            operation.cancel()
                        }
                        
                    }
                    
                    it("should not parse any objects") {
                        let json = JSON(["data":[["type": "test"]]])
                        
                        let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { _, _ in
                        }
                        operation.register(type: "test") { json in
                            let o = StubRealmObject()
                            o.id = 1
                            return o
                        }
                        
                        waitUntil { done in
                            operation.completionBlock = {
                                let realm = RealmProvider().realm()
                                expect(realm.objects(StubRealmObject.self)).to(haveCount(0))
                                done()
                            }
                            queue.addOperation(operation)
                            operation.cancel()
                        }
                    }
                }
                
                context("Parsers") {
                    
                    it("should return object in failed array if parser returns nil") {
                        var parserCalled = false
                        var response: [JSON]?
                        
                        let other = ["type": "another", "name": "other"]
                        let json = JSON(["data": [other]])
                        let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { parsed, failed in
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
                        var response: [JSON]?
                        
                        let other = ["type": "another", "name": "bad"]
                        let json = JSON(["data": [other]])
                        let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { parsed, failed in
                            response = failed
                        }
                        
                        queue.addOperation(operation)
                        expect(response).toEventuallyNot(beNil())
                        expect(response).toEventually(contain(JSON(other)))
                    }
                }
                
                context("Included objects") {
                    it("should parse included objects correctly") {
                        var response: [JSON]? = []
                        
                        let object = ["type": "generic"]
                        let json = JSON(["included": [object]])
                        let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { _, failed in
                            response = failed
                        }
                        operation.register(type: "generic") { json -> Object? in
                            let a = StubRealmObject()
                            a.id = 1
                            return a
                        }
                        
                        queue.addOperation(operation)
                        expect(response).toEventually(beNil())
                        expect(StubRealmObject.get(withId: 1)).toEventuallyNot(beNil())
                    }
                    
                    it("should not parse `included` if it's not an array") {
                        var response: [JSON]? = nil
                        
                        let json = JSON(["included": "hi"])
                        let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { _, failed in
                            response = failed
                        }
                        
                        queue.addOperation(operation)
                        expect(response).toEventuallyNot(beNil())
                        expect(response).toEventually(contain("hi"))
                    }
                }
                
                context("Data objects") {
                    it("should parse data objects correctly") {
                        var response: [JSON]? = []
                        
                        let object = ["type": "generic"]
                        let json = JSON(["data": [object]])
                        let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { _, failed in
                            response = failed
                        }
                        operation.register(type: "generic") { json -> Object? in
                            let a = StubRealmObject()
                            a.id = 1
                            return a
                        }
                        
                        queue.addOperation(operation)
                        expect(response).toEventually(beNil())
                        expect(StubRealmObject.get(withId: 1)).toEventuallyNot(beNil())
                    }
                    
                    it("should not parse `data` if it's not an array") {
                        var response: [JSON]? = nil
                        
                        let json = JSON(["data": "hi"])
                        let operation = ParsingOperation(json: json, realm: RealmProvider().realm) { _, failed in
                            response = failed
                        }
                        
                        queue.addOperation(operation)
                        expect(response).toEventuallyNot(beNil())
                        expect(response).toEventually(contain(["hi"]))
                    }
                }
                
                context("Actual JSON Data") {
                    
                    it("should parse everything!") {
                        self.testParse(forFile: "anime-hunter-hunter", queue: queue, realmObject: Anime.self, count: 1)
                        self.testParse(forFile: "user-jigglyslime", queue: queue, realmObject: User.self, count: 1)
                        self.testParse(forFile: "genre-adventure", queue: queue, realmObject: Genre.self, count: 1)
                        self.testParse(forFile: "entry-anime-jigglyslime", queue: queue, realmObject: LibraryEntry.self, count: 1)
                    }
                }
            }
            
        }
    }
    
    /// Test the parsing operation on JSON from a file and check the count of a realm class
    ///
    /// - Parameters:
    ///   - file: The file name.
    ///   - queue: The operation queue
    ///   - realmObject: The object class
    ///   - count: The amount of objects to expect after parsing
    func testParse<T: Object>(forFile file: String, queue: OperationQueue, realmObject: T.Type, count: Int) {
        self.testParse(forFile: file, queue: queue, testBlock: { operation, response, error in
            DispatchQueue.main.sync {
                let realm = RealmProvider().realm()
                expect(error).to(beFalse())
                
                realm.refresh()
                expect(realm.objects(realmObject)).to(haveCount(count))
                
                //Remove parsed objects
                try! realm.write {
                    realm.deleteAll()
                }
            }
        })
    }
    
    /// Test the parsing operation on JSON from a file
    ///
    /// - Parameters:
    ///   - file: The file name. Make sure the JSON in the file is of 1 raw object because this function will append it to { "data": [ <file contents ] } JSON
    ///   - queue: The operation queue which to run the operation on
    ///   - testBlock: The test block which passes the operation, result, and a bool which determines if it errored.
    func testParse(forFile file: String, queue: OperationQueue, testBlock: @escaping (ParsingOperation?, [JSON]?, Bool) -> Void) {
        var response: [JSON]? = nil
        guard let json = TestHelper.loadJSON(fromFile: file) else {
            testBlock(nil, nil, true)
            return
        }
        
        let data = JSON(["data": [json.dictionaryObject]])
        
        let operation = ParsingOperation(json: data, realm: RealmProvider().realm) { _, failed in
            response = failed
        }
        
        waitUntil { done in
            operation.completionBlock = {
                testBlock(operation, response, false)
                done()
            }
            queue.addOperation(operation)
        }
    }
}
