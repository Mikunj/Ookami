//
//  OokamiUITests.swift
//  OokamiUITests
//
//  Created by Maka on 22/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import XCTest
@testable import OokamiKit
@testable import Heimdallr
import Result

private class StubHeimdallr: Heimdallr {
    
    override public var hasAccessToken: Bool {
        return true
    }
    
    init() {
        super.init(tokenURL: URL(string: "http://uiTest.kitsu.io")!)
    }
    
    override func clearAccessToken() {
    }
    
    override func requestAccessToken(username: String, password: String, completion: @escaping (Result<Void, NSError>) -> ()) {
        completion(.success())
    }
    
    override func authenticateRequest(_ request: URLRequest, completion: @escaping (Result<URLRequest, NSError>) -> ()) {
        completion(.success(request))
    }
    
}

class OokamiUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        //Populate the data
        //We need to make sure we have the data there so that the screenshots remain consistent
        let anime = expectation(description: "Anime Current")
        LibraryService().get(userID: 2875, type: .anime, status: .current) { _ in
            anime.fulfill()
        }
        
        let manga = expectation(description: "Manga Current")
        LibraryService().get(userID: 2875, type: .manga, status: .current) { _ in
            manga.fulfill()
        }
        
        //Wait for them
        waitForExpectations(timeout: 60, handler: nil)
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        let app = XCUIApplication()
        app.launchArguments = ["UITest"]
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSnapshot() {
        
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        let trendingButton = tabBarsQuery.buttons["Trending"]
        trendingButton.tap()
        
        let discoverButton = tabBarsQuery.buttons["Discover"]
        discoverButton.tap()
        discoverButton.tap()
        tabBarsQuery.buttons["Library"].tap()
        
        snapshot("01 - Anime Library")
        
        app.navigationBars["Ookami.UserLibraryView"].otherElements.children(matching: .button).element.tap()
        app.tables.staticTexts["Manga"].tap()
        
        snapshot("02 - Manga Library")
        
        trendingButton.tap()
        
        snapshot("05 - Trending")
        
        discoverButton.tap()
        
        snapshot("04 - Discover")
        
        app.collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .image).element.tap()
        
        snapshot("03 - Media")
        
        app.navigationBars.buttons["Stop"].tap()
        
        
    }
    
//    func testSnapshot() {
//        
//        let app = XCUIApplication()
//        
//        let ookamiUserlibraryviewNavigationBar = app.navigationBars["Ookami.UserLibraryView"]
//        ookamiUserlibraryviewNavigationBar.buttons["Search"].tap()
//        app.searchFields["Enter your search"].typeText("One punch man")
//        
//        let tablesQuery = app.tables
//        tablesQuery.staticTexts["12 episodes ᛫ 24 minutes"].tap()
//        
//        snapshot("03 - Anime page")
//        
//        app.navigationBars.buttons["Stop"].tap()
//        
//        snapshot("04 - Search")
//        
//        let cancelButton = app.buttons["Cancel"]
//        cancelButton.tap()
//        cancelButton.tap()
//        
//        snapshot("01 - Anime library")
//        
//        ookamiUserlibraryviewNavigationBar.otherElements.children(matching: .button).element.tap()
//        tablesQuery.staticTexts["Manga"].tap()
//        
//        snapshot("02 - Manga library")
//        
//    }
    
}
