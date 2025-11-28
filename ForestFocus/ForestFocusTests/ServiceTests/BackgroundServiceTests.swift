//
//  BackgroundServiceTests.swift
//  ForestFocusTests
//
//  Created by AI Assistant on 10/29/25.
//  Task: T036 - Test background time tracking
//

import XCTest
@testable import ForestFocus

final class BackgroundServiceTests: XCTestCase {
    
    var mockBackgroundService: MockBackgroundService!
    
    override func setUp() {
        mockBackgroundService = MockBackgroundService()
    }
    
    override func tearDown() {
        mockBackgroundService = nil
    }
    
    // MARK: - Initial State Tests
    
    func testInitialStateIsForeground() {
        // Then: Initially not in background
        XCTAssertFalse(mockBackgroundService.isInBackground)
    }
    
    func testCallbacksAreNilInitially() {
        // Then: No callbacks set initially
        XCTAssertNil(mockBackgroundService.onEnterBackground)
        XCTAssertNil(mockBackgroundService.onEnterForeground)
    }
    
    // MARK: - Background Transition Tests
    
    func testEnterBackgroundUpdatesState() {
        // When: Enter background
        mockBackgroundService.simulateEnterBackground()
        
        // Then: State is updated
        XCTAssertTrue(mockBackgroundService.isInBackground)
    }
    
    func testEnterBackgroundCallsCallback() {
        // Given: Callback registered
        var callbackCalled = false
        var callbackDate: Date?
        
        mockBackgroundService.onEnterBackground = { date in
            callbackCalled = true
            callbackDate = date
        }
        
        // When: Enter background
        mockBackgroundService.simulateEnterBackground()
        
        // Then: Callback was called
        XCTAssertTrue(callbackCalled)
        XCTAssertNotNil(callbackDate)
    }
    
    func testEnterBackgroundWithoutCallbackDoesNotCrash() {
        // When: Enter background without callback
        mockBackgroundService.simulateEnterBackground()
        
        // Then: No crash, state still updates
        XCTAssertTrue(mockBackgroundService.isInBackground)
    }
    
    // MARK: - Foreground Transition Tests
    
    func testEnterForegroundUpdatesState() {
        // Given: App in background
        mockBackgroundService.simulateEnterBackground()
        XCTAssertTrue(mockBackgroundService.isInBackground)
        
        // When: Enter foreground
        mockBackgroundService.simulateEnterForeground()
        
        // Then: State is updated
        XCTAssertFalse(mockBackgroundService.isInBackground)
    }
    
    func testEnterForegroundCallsCallback() {
        // Given: Callback registered
        var callbackCalled = false
        var callbackDate: Date?
        
        mockBackgroundService.onEnterForeground = { date in
            callbackCalled = true
            callbackDate = date
        }
        
        // When: Enter foreground
        mockBackgroundService.simulateEnterForeground()
        
        // Then: Callback was called
        XCTAssertTrue(callbackCalled)
        XCTAssertNotNil(callbackDate)
    }
    
    func testEnterForegroundWithoutCallbackDoesNotCrash() {
        // When: Enter foreground without callback
        mockBackgroundService.simulateEnterForeground()
        
        // Then: No crash, state still updates
        XCTAssertFalse(mockBackgroundService.isInBackground)
    }
    
    // MARK: - Multiple Transition Tests
    
    func testMultipleBackgroundForegroundCycles() {
        // When: Multiple cycles
        mockBackgroundService.simulateEnterBackground()
        XCTAssertTrue(mockBackgroundService.isInBackground)
        
        mockBackgroundService.simulateEnterForeground()
        XCTAssertFalse(mockBackgroundService.isInBackground)
        
        mockBackgroundService.simulateEnterBackground()
        XCTAssertTrue(mockBackgroundService.isInBackground)
        
        mockBackgroundService.simulateEnterForeground()
        XCTAssertFalse(mockBackgroundService.isInBackground)
        
        // Then: State correctly tracks each transition
    }
    
    func testBackgroundCallbackCalledMultipleTimes() {
        // Given: Counter
        var callCount = 0
        mockBackgroundService.onEnterBackground = { _ in
            callCount += 1
        }
        
        // When: Enter background multiple times
        mockBackgroundService.simulateEnterBackground()
        mockBackgroundService.simulateEnterForeground()
        mockBackgroundService.simulateEnterBackground()
        mockBackgroundService.simulateEnterForeground()
        mockBackgroundService.simulateEnterBackground()
        
        // Then: Called 3 times
        XCTAssertEqual(callCount, 3)
    }
    
    func testForegroundCallbackCalledMultipleTimes() {
        // Given: Counter
        var callCount = 0
        mockBackgroundService.onEnterForeground = { _ in
            callCount += 1
        }
        
        // When: Enter foreground multiple times
        mockBackgroundService.simulateEnterForeground()
        mockBackgroundService.simulateEnterBackground()
        mockBackgroundService.simulateEnterForeground()
        mockBackgroundService.simulateEnterBackground()
        mockBackgroundService.simulateEnterForeground()
        
        // Then: Called 3 times
        XCTAssertEqual(callCount, 3)
    }
    
    // MARK: - Use Case Tests
    
    func testSessionBackgroundingFlow() {
        // Scenario: Active session, user backgrounds app
        
        var backgroundTime: Date?
        var foregroundTime: Date?
        
        // 1. Setup callbacks
        mockBackgroundService.onEnterBackground = { date in
            backgroundTime = date
            // In real app: Save current timer state
        }
        
        mockBackgroundService.onEnterForeground = { date in
            foregroundTime = date
            // In real app: Calculate time elapsed, update session
        }
        
        // 2. User backgrounds app
        mockBackgroundService.simulateEnterBackground()
        XCTAssertNotNil(backgroundTime)
        
        // 3. User returns to app
        mockBackgroundService.simulateEnterForeground()
        XCTAssertNotNil(foregroundTime)
        
        // 4. Verify sequence
        XCTAssertTrue(foregroundTime! >= backgroundTime!)
    }
    
    func testMultipleQuickTransitions() {
        // Scenario: User quickly switches apps (spam app switcher)
        
        var transitionCount = 0
        
        mockBackgroundService.onEnterBackground = { _ in
            transitionCount += 1
        }
        mockBackgroundService.onEnterForeground = { _ in
            transitionCount += 1
        }
        
        // When: Quick transitions
        for _ in 0..<10 {
            mockBackgroundService.simulateEnterBackground()
            mockBackgroundService.simulateEnterForeground()
        }
        
        // Then: All transitions tracked (20 total)
        XCTAssertEqual(transitionCount, 20)
    }
    
    // MARK: - Callback Replacement Tests
    
    func testCallbackCanBeReplaced() {
        // Given: First callback
        var firstCallbackCalled = false
        mockBackgroundService.onEnterBackground = { _ in
            firstCallbackCalled = true
        }
        
        // When: Replace with second callback
        var secondCallbackCalled = false
        mockBackgroundService.onEnterBackground = { _ in
            secondCallbackCalled = true
        }
        
        mockBackgroundService.simulateEnterBackground()
        
        // Then: Only second callback called
        XCTAssertFalse(firstCallbackCalled)
        XCTAssertTrue(secondCallbackCalled)
    }
    
    func testCallbackCanBeCleared() {
        // Given: Callback set
        var callbackCalled = false
        mockBackgroundService.onEnterBackground = { _ in
            callbackCalled = true
        }
        
        // When: Clear callback
        mockBackgroundService.onEnterBackground = nil
        mockBackgroundService.simulateEnterBackground()
        
        // Then: Callback not called
        XCTAssertFalse(callbackCalled)
    }
    
    // MARK: - Edge Cases
    
    func testEnterBackgroundTwiceInRow() {
        // When: Enter background twice without foreground
        mockBackgroundService.simulateEnterBackground()
        mockBackgroundService.simulateEnterBackground()
        
        // Then: Still in background (idempotent)
        XCTAssertTrue(mockBackgroundService.isInBackground)
    }
    
    func testEnterForegroundTwiceInRow() {
        // When: Enter foreground twice without background
        mockBackgroundService.simulateEnterForeground()
        mockBackgroundService.simulateEnterForeground()
        
        // Then: Still in foreground (idempotent)
        XCTAssertFalse(mockBackgroundService.isInBackground)
    }
    
    func testCallbackReceivesCorrectTimestamp() {
        // Given: Capture timestamps
        var backgroundTimestamp: Date?
        mockBackgroundService.onEnterBackground = { date in
            backgroundTimestamp = date
        }
        
        // When: Enter background
        let beforeCall = Date()
        mockBackgroundService.simulateEnterBackground()
        let afterCall = Date()
        
        // Then: Timestamp is between before and after
        XCTAssertNotNil(backgroundTimestamp)
        XCTAssertTrue(backgroundTimestamp! >= beforeCall)
        XCTAssertTrue(backgroundTimestamp! <= afterCall)
    }
}
