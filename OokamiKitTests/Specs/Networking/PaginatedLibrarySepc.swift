//
//  PaginatedLibrarySepc.swift
//  Ookami
//
//  Created by Maka on 14/11/16.
//  Copyright © 2016 Mikunj Varsani. All rights reserved.
//

import Quick
import Nimble
@testable import OokamiKit
import SwiftyJSON
import OHHTTPStubs

private class StubParsingOperation: ParsingOperation {
    override func main() {
        let realm = realmBlock()
        try! realm.write {
            let o = StubRealmObject()
            o.id = 1
            realm.add(o, update: true)
        }
        self.parseComplete(["test": [1]], nil)
        self.completeOperation()
    }
}

private class StubPaginatedLibrary: PaginatedLibrary {
    
    var originalCalledCount = 0
    var nextCalledCount = 0
    var prevCalledCount = 0
    var firstCalledCount = 0
    var lastCalledCount = 0
    
    override func original() {
        originalCalledCount += 1
        super.original()
    }
    
    override func next() {
        nextCalledCount += 1
        super.next()
    }
    
    override func prev() {
        prevCalledCount += 1
        super.prev()
    }
    
    override func first() {
        firstCalledCount += 1
        super.first()
    }
    
    override func last() {
        lastCalledCount += 1
        super.last()
    }
    
    override func parsingOperation(forJSON json: JSON) -> ParsingOperation {
        return StubParsingOperation(json: json, realm: RealmProvider.realm) { [weak self] parsed, badObjects in
            guard let strongSelf = self else { return }
            
            let entries = parsed?["test"] as! [Int]? ?? []
            strongSelf.completion(entries, nil)
            
            //Some other messages
            if let count = badObjects?.count, count > 0{
                print("Paginated Library: Some JSON didn't parse properley!")
            }
        }
    }
}

class PaginatedLibrarySpec: QuickSpec {
    override func spec() {
        
        var client: NetworkClient!
        var request: LibraryGETRequest!
        
        describe("Paginated Library") {
            
            beforeEach {
                
                client = NetworkClient(baseURL: "http://kitsu.io", heimdallr: StubAuthHeimdallr())
                request = LibraryGETRequest(userID: 1, relativeURL: "/library-entry")
                
                //Stub the network to return JSON data
                stub(condition: isHost("kitsu.io")) { _ in
                    return OHHTTPStubsResponse(error: NetworkClientError.error("failed to get json"))
                }
            }
            
            afterEach {
                OHHTTPStubs.removeAllStubs()
            }
            
            context("Requests") {
                it("should immediately call the original request") {
                    let p = StubPaginatedLibrary(request: request, client: client) { _, _ in }
                    expect(p.originalCalledCount).toEventually(equal(1))
                }
                
                it("should call original request if there are no links") {
                    let p = StubPaginatedLibrary(request: request, client: client) { _, _ in }
                    
                    //Called at creation, then once at each of these functions
                    p.next()
                    p.prev()
                    p.first()
                    p.last()
                    expect(p.originalCalledCount).toEventually(equal(5))
                }
                
                it("should correctly build requests for links") {
                    let linkString = "http://abc.io/anime"
                    let p = StubPaginatedLibrary(request: request, client: client) { _, _ in }
                    let request = p.buildRequest(for: linkString)
                    expect(request.url).to(equal(linkString))
                }
                
                it("should return error if link is nil") {
                    var error: Error?
                    
                    let p = StubPaginatedLibrary(request: request, client: client) { _, e in
                        error = e
                    }
                    p.links.first = "hello"
                    p.performRequest(for: nil, nilError: .noNextPage)
                    expect(error).toEventually(matchError(PaginatedLibraryError.noNextPage))
                }
            }
            
            context("Fetching") {
                context("Links") {
                    it("should correctly set links from json") {
                        let data = ["links": ["first": "abc", "last": "def"]]
                        let json = JSON(data)
                        let p = StubPaginatedLibrary(request: request, client: client) { _, _ in }
                        p.updateLinks(fromJSON: json)
                        
                        expect(p.links.hasAnyLinks()).to(beTrue())
                        expect(p.links.first).to(equal("abc"))
                        expect(p.links.next).to(beNil())
                        expect(p.links.previous).to(beNil())
                        expect(p.links.last).to(equal("def"))
                    }
                    
                    it("should set all links to nil if no links exist in json") {
                        let data = ["data": "abc"]
                        let json = JSON(data)
                        let p = StubPaginatedLibrary(request: request, client: client) { _, _ in }
                        p.links.first = "abc"
                        p.links.next = "def"
                        p.links.previous = "ghi"
                        p.links.last = "jkl"
                        p.updateLinks(fromJSON: json)
                        
                        expect(p.links.hasAnyLinks()).to(beFalse())
                        expect(p.links.first).to(beNil())
                        expect(p.links.next).to(beNil())
                        expect(p.links.previous).to(beNil())
                        expect(p.links.last).to(beNil())
                    }
                    
                    it("should set all links to nil if links is not a dictionary in json") {
                        let data = ["links": "abc"]
                        let json = JSON(data)
                        let p = StubPaginatedLibrary(request: request, client: client) { _, _ in }
                        p.links.first = "abc"
                        p.links.next = "def"
                        p.links.previous = "ghi"
                        p.links.last = "jkl"
                        p.updateLinks(fromJSON: json)
                        
                        expect(p.links.hasAnyLinks()).to(beFalse())
                        expect(p.links.first).to(beNil())
                        expect(p.links.next).to(beNil())
                        expect(p.links.previous).to(beNil())
                        expect(p.links.last).to(beNil())
                    }
                }
                
                context("Data") {
                    it("should correctly return fetched ids") {
                        var ids: [Int]?
                        
                        stub(condition: isHost("kitsu.io")) { _ in
                            let data = ["data": "hi"]
                            return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                        }
                        
                        let _ = StubPaginatedLibrary(request: request, client: client) { fetched, _ in
                            ids = fetched
                        }
                        
                        expect(ids).toEventually(haveCount(1))
                        expect(ids).toEventually(contain(1))
                        expect(StubRealmObject.all()).toEventually(haveCount(1))
                    }
                    
                    it("should correctly return data for a link") {
                        var ids: [Int]?
                        var error: Error? = NetworkClientError.error("an error")
                        
                        stub(condition: isHost("abc.io")) { _ in
                            let data = ["data": "hi"]
                            return OHHTTPStubsResponse(jsonObject: data, statusCode: 200, headers: ["Content-Type": "application/vnd.api+json"])
                        }
                        
                        let p = StubPaginatedLibrary(request: request, client: client) { fetched, e in
                            ids = fetched
                            error = e
                        }
                        
                        p.links.next = "http://abc.io/anime"
                        p.next()
                        
                        expect(ids).toEventually(haveCount(1))
                        expect(ids).toEventually(contain(1))
                        expect(error).toEventually(beNil())
                        expect(StubRealmObject.all()).toEventually(haveCount(1))
                    }
                }
            }
        }
    }
}



