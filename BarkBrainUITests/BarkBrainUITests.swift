//
//  BarkBrainUITests.swift
//  BarkBrainUITests
//
//  Created by YouXinyu on 2025/7/13.
//

import XCTest

final class BarkBrainUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testAppLaunchAndBasicNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Verify app launches successfully with correct navigation title
        XCTAssertTrue(app.navigationBars["Bark Brain"].waitForExistence(timeout: 10.0))
        
        // Check for main UI sections
        XCTAssertTrue(app.staticTexts["Today's Stats"].waitForExistence(timeout: 5.0))
        XCTAssertTrue(app.staticTexts["Learning Method"].exists)
        XCTAssertTrue(app.staticTexts["Learning Progress"].exists)
        
        // Check for quick stats elements
        XCTAssertTrue(app.staticTexts["Best Streak"].exists)
        XCTAssertTrue(app.staticTexts["Current Streak"].exists)
        XCTAssertTrue(app.staticTexts["Total Questions"].exists)
    }
    
    @MainActor
    func testTrainingFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for main screen to load
        XCTAssertTrue(app.staticTexts["Learning Method"].waitForExistence(timeout: 5.0))
        
        // Tap Image to Name Training button
        let trainingButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Image to Name Training'")).firstMatch
        XCTAssertTrue(trainingButton.waitForExistence(timeout: 5.0))
        trainingButton.tap()
        
        // Wait for training view to load
        let trainingNavBar = app.navigationBars["Image To Name"]
        XCTAssertTrue(trainingNavBar.waitForExistence(timeout: 20.0))
        
        // Check for Exit button and test navigation back
        let exitButton = app.buttons["Exit"]
        XCTAssertTrue(exitButton.exists)
        exitButton.tap()
        
        // Should return to main screen
        XCTAssertTrue(app.staticTexts["Learning Method"].waitForExistence(timeout: 5.0))
    }
    
    @MainActor
    func testBrowseBreedsFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for main screen to load
        XCTAssertTrue(app.staticTexts["Learning Method"].waitForExistence(timeout: 5.0))
        
        // Tap Browse Breeds button
        let browseBreedsButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Browse Breeds'")).firstMatch
        XCTAssertTrue(browseBreedsButton.waitForExistence(timeout: 5.0))
        XCTAssertTrue(browseBreedsButton.isHittable)
        browseBreedsButton.tap()
        
        // Wait for breeds list to load
        let breedsListIndicator = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'breed' OR label CONTAINS 'Breed'")).firstMatch
        XCTAssertTrue(breedsListIndicator.waitForExistence(timeout: 10.0))
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
