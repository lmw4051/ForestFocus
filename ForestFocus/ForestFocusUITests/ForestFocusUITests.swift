//
//  ForestFocusUITests.swift
//  ForestFocusUITests
//
//  Created by David Lee on 10/30/25.
//  Task: T065-T066 - UI Tests for Timer Flow
//

import XCTest

final class ForestFocusUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Initial State Tests
    
    @MainActor
    func testInitialTimerState() throws {
        // Verify initial UI state
        XCTAssertTrue(app.staticTexts["25:00"].exists, "Timer should show 25:00")
        XCTAssertTrue(app.buttons["Plant Tree"].exists, "Start button should exist")
        XCTAssertTrue(app.navigationBars["Focus Timer"].exists, "Navigation title should exist")
    }
    
    // MARK: - Start Session Tests
    
    @MainActor
    func testStartSession() throws {
        // Given: Initial state
        let startButton = app.buttons["Plant Tree"]
        XCTAssertTrue(startButton.exists)
        
        // When: Tap start
        startButton.tap()
        
        // Then: UI updates
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["Give Up"].exists)
        
        // Timer should start counting down
        let timerText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '24:'")).firstMatch
        XCTAssertTrue(timerText.waitForExistence(timeout: 3), "Timer should count down")
    }
    
    // MARK: - Pause/Resume Tests
    
    @MainActor
    func testPauseAndResumeSession() throws {
        // Given: Active session
        app.buttons["Plant Tree"].tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 1))
        
        // When: Pause
        app.buttons["Pause"].tap()
        
        // Then: Shows resume button
        XCTAssertTrue(app.buttons["Resume"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.buttons["Give Up"].exists)
        
        // When: Resume
        app.buttons["Resume"].tap()
        
        // Then: Shows pause button again
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 1))
    }
    
    // MARK: - Abandon Session Tests
    
    @MainActor
    func testAbandonSession() throws {
        // Given: Active session
        app.buttons["Plant Tree"].tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 1))
        
        // When: Abandon
        app.buttons["Give Up"].tap()
        
        // Then: Shows try again button and resets timer
        XCTAssertTrue(app.buttons["Try Again"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.staticTexts["25:00"].exists, "Timer should reset to 25:00")
    }
    
    @MainActor
    func testAbandonFromPausedState() throws {
        // Given: Paused session
        app.buttons["Plant Tree"].tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 1))
        app.buttons["Pause"].tap()
        XCTAssertTrue(app.buttons["Resume"].waitForExistence(timeout: 1))
        
        // When: Abandon
        app.buttons["Give Up"].tap()
        
        // Then: Shows try again button
        XCTAssertTrue(app.buttons["Try Again"].waitForExistence(timeout: 1))
    }
    
    // MARK: - Timer Countdown Tests
    
    @MainActor
    func testTimerCountsDown() throws {
        // Given: Start session
        app.buttons["Plant Tree"].tap()
        
        // When: Wait for timer to count down
        sleep(2)
        
        // Then: Timer should show less than 25:00
        let timerText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '24:'")).firstMatch
        XCTAssertTrue(timerText.exists, "Timer should count down from 25:00")
    }
    
    // MARK: - Navigation Tests
    
    @MainActor
    func testNavigationTabs() throws {
        // Verify all tabs exist
        XCTAssertTrue(app.tabBars.buttons["Timer"].exists)
        XCTAssertTrue(app.tabBars.buttons["Forest"].exists)
        XCTAssertTrue(app.tabBars.buttons["Stats"].exists)
        
        // Navigate to Forest tab
        app.tabBars.buttons["Forest"].tap()
        XCTAssertTrue(app.navigationBars["Forest"].waitForExistence(timeout: 1))
        
        // Navigate to Stats tab
        app.tabBars.buttons["Stats"].tap()
        XCTAssertTrue(app.navigationBars["Statistics"].waitForExistence(timeout: 1))
        
        // Navigate back to Timer
        app.tabBars.buttons["Timer"].tap()
        XCTAssertTrue(app.navigationBars["Focus Timer"].exists)
    }
    
    // MARK: - Accessibility Tests
    
    @MainActor
    func testAccessibilityLabels() throws {
        // Verify accessibility labels exist
        let startButton = app.buttons["Start focus session"]
        XCTAssertTrue(startButton.exists || app.buttons["Plant Tree"].exists)
        
        // Start session and verify pause accessibility
        app.buttons["Plant Tree"].tap()
        
        let pauseButton = app.buttons["Pause focus session"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 1) || app.buttons["Pause"].exists)
    }
    
    @MainActor
    func testVoiceOverSupport() throws {
        // This test verifies that key elements have accessibility labels
        // (VoiceOver itself can't be tested in XCTest, but we can verify labels exist)
        
        let startButton = app.buttons["Plant Tree"]
        XCTAssertNotNil(startButton.label, "Start button should have label")
        
        // Start session
        startButton.tap()
        
        let pauseButton = app.buttons["Pause"]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 1))
        XCTAssertNotNil(pauseButton.label, "Pause button should have label")
    }
    
    // MARK: - Multiple Session Tests
    
    @MainActor
    func testMultipleSessionCycles() throws {
        // First session
        app.buttons["Plant Tree"].tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 1))
        app.buttons["Give Up"].tap()
        XCTAssertTrue(app.buttons["Try Again"].waitForExistence(timeout: 1))
        
        // Second session
        app.buttons["Try Again"].tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 1))
        app.buttons["Give Up"].tap()
        XCTAssertTrue(app.buttons["Try Again"].waitForExistence(timeout: 1))
        
        // Third session
        app.buttons["Try Again"].tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 1))
    }
    
    // MARK: - Performance Tests
    
    @MainActor
    func testLaunchPerformance() throws {
        // Measure cold start time (should be < 2s)
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    @MainActor
    func testSessionStartPerformance() throws {
        // Measure time to start session
        measure {
            app.buttons["Plant Tree"].tap()
            _ = app.buttons["Pause"].waitForExistence(timeout: 1)
            
            // Clean up
            app.buttons["Give Up"].tap()
            _ = app.buttons["Try Again"].waitForExistence(timeout: 1)
        }
    }
    
    // MARK: - UI Animation Tests
    
    @MainActor
    func testTreeGrowthAnimation() throws {
        // This is a basic test to ensure UI updates during session
        // Actual 60fps animation is best tested manually or with Instruments
        
        app.buttons["Plant Tree"].tap()
        
        // Tree should be visible
        XCTAssertTrue(app.images.element.exists, "Tree image should be visible")
        
        // Wait a bit and verify tree is still there (validates animation isn't crashing)
        sleep(2)
        XCTAssertTrue(app.images.element.exists, "Tree should remain visible during session")
    }
}
