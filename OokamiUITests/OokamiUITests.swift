//
//  OokamiUITests.swift
//  OokamiUITests
//
//  Created by Maka on 22/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import XCTest

class OokamiUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        
        
        
        snapshot("01 - Anime library")
        
        app.scrollViews.otherElements.collectionViews.children(matching: .cell).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .image).element.tap()
        
        
        app.tables.buttons["Go To Anime Page"].tap()
        
        snapshot("02 - Anime page")
        
        app.navigationBars.buttons["Stop"].tap()
        app.navigationBars["Ookami.LibraryEntryView"].children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
        
        let ookamiUserlibraryviewNavigationBar = app.navigationBars["Ookami.UserLibraryView"]
        ookamiUserlibraryviewNavigationBar.otherElements.children(matching: .button).element.tap()
        
        app.tables.staticTexts["Manga"].tap()
        
        snapshot("01 - Manga library")
        
        ookamiUserlibraryviewNavigationBar.buttons["Search"].tap()
        
        let enterYourSearchSearchField = app.searchFields["Enter your search"]
        enterYourSearchSearchField.typeText("Attack on titan")
        
        app.buttons["Search"].tap()
        
        snapshot("03 - Search")
    }
    
}
