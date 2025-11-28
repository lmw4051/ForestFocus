//
//  TimerServiceTests.swift
//  ForestFocusTests
//
//  Created by AI Assistant on 10/29/25.
//  Task: T034 - Test timer service accuracy
//

import XCTest
@testable import ForestFocus

final class TimerServiceTests: XCTestCase {
    
    var timerService: TimerService!
    var mockTimerService: MockTimerService!
    
    override func setUp() {
        timerService = TimerService()
        mockTimerService = MockTimerService()
    }
    
    override func tearDown() {
        timerService = nil
        mockTimerService = nil
    }
    
    // MARK: - Real Timer Tests
    
    func testCurrentTimeReturnsNonZeroValue() {
        // When: Get current time
        let time = timerService.currentTime()
        
        // Then: Time is positive and non-zero
        XCTAssertGreaterThan(time, 0)
    }
    
    func testCurrentTimeIsMonotonic() {
        // Given: First time reading
        let time1 = timerService.currentTime()
        
        // When: Wait a tiny bit and read again
        Thread.sleep(forTimeInterval: 0.001) // 1ms
        let time2 = timerService.currentTime()
        
        // Then: Time always increases
        XCTAssertGreaterThan(time2, time1)
    }
    
    func testElapsedTimeCalculation() {
        // Given: Start time
        let startTime = timerService.currentTime()
        
        // When: Wait 100ms
        Thread.sleep(forTimeInterval: 0.1)
        let elapsed = timerService.elapsedTime(since: startTime)
        
        // Then: Elapsed time is approximately 100ms (±20ms tolerance)
        XCTAssertEqual(elapsed, 0.1, accuracy: 0.02)
    }
    
    func testTimerAccuracyOver1Second() {
        // Given: Start time
        let startTime = timerService.currentTime()
        
        // When: Wait 1 second
        Thread.sleep(forTimeInterval: 1.0)
        let elapsed = timerService.elapsedTime(since: startTime)
        
        // Then: Elapsed time is approximately 1 second (±50ms tolerance)
        XCTAssertEqual(elapsed, 1.0, accuracy: 0.05)
    }
    
    // MARK: - Mock Timer Tests
    
    func testMockTimerStartsAtZero() {
        // When: Get initial mock time
        let time = mockTimerService.currentTime()
        
        // Then: Time is zero
        XCTAssertEqual(time, 0)
    }
    
    func testMockTimerAdvance() {
        // Given: Mock timer at 0
        XCTAssertEqual(mockTimerService.currentTime(), 0)
        
        // When: Advance by 10 seconds
        mockTimerService.advance(by: 10)
        
        // Then: Current time is 10
        XCTAssertEqual(mockTimerService.currentTime(), 10)
    }
    
    func testMockTimerMultipleAdvances() {
        // When: Advance multiple times
        mockTimerService.advance(by: 5)
        mockTimerService.advance(by: 3)
        mockTimerService.advance(by: 2)
        
        // Then: Time accumulates
        XCTAssertEqual(mockTimerService.currentTime(), 10)
    }
    
    func testMockElapsedTime() {
        // Given: Start time at 5
        mockTimerService.mockTime = 5
        let startTime = mockTimerService.currentTime()
        
        // When: Advance to 25
        mockTimerService.advance(by: 20)
        let elapsed = mockTimerService.elapsedTime(since: startTime)
        
        // Then: Elapsed is 20 seconds
        XCTAssertEqual(elapsed, 20)
    }
    
    func testMockTimerSimulates25MinuteSession() {
        // Given: Session starts at 0
        let startTime = mockTimerService.currentTime()
        
        // When: Simulate 25 minutes (1500 seconds)
        mockTimerService.advance(by: 1500)
        let elapsed = mockTimerService.elapsedTime(since: startTime)
        
        // Then: Exactly 25 minutes elapsed
        XCTAssertEqual(elapsed, 1500)
    }
    
    // MARK: - Performance Tests
    
    func testTimerPerformance() {
        // Measure performance of 1000 timer reads
        measure {
            for _ in 0..<1000 {
                _ = timerService.currentTime()
            }
        }
        // Should complete in < 1ms
    }
    
    func testElapsedTimePerformance() {
        let startTime = timerService.currentTime()
        
        // Measure performance of 1000 elapsed time calculations
        measure {
            for _ in 0..<1000 {
                _ = timerService.elapsedTime(since: startTime)
            }
        }
        // Should complete in < 1ms
    }
    
    // MARK: - Edge Cases
    
    func testElapsedTimeWithFutureStartTime() {
        // Given: Start time in the future (shouldn't happen, but test anyway)
        let futureTime = timerService.currentTime() + 100
        
        // When: Calculate elapsed
        let elapsed = timerService.elapsedTime(since: futureTime)
        
        // Then: Elapsed is negative
        XCTAssertLessThan(elapsed, 0)
    }
    
    func testMockTimerCanBeReset() {
        // Given: Timer advanced
        mockTimerService.advance(by: 100)
        XCTAssertEqual(mockTimerService.currentTime(), 100)
        
        // When: Reset to 0
        mockTimerService.mockTime = 0
        
        // Then: Time is 0
        XCTAssertEqual(mockTimerService.currentTime(), 0)
    }
}
