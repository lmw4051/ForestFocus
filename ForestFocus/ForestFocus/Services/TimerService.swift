//
//  TimerService.swift
//  ForestFocus
//
//  Created by AI Assistant on 10/29/25.
//  Task: T031 - Timer service with high-precision timing
//

import Foundation
import QuartzCore

/// Protocol for timer operations (enables testing with mocks)
protocol TimerServiceProtocol {
    func currentTime() -> TimeInterval
    func elapsedTime(since startTime: TimeInterval) -> TimeInterval
}

/// High-precision timer service using CACurrentMediaTime
final class TimerService: TimerServiceProtocol {
    
    /// Get current time in seconds (monotonic, not affected by system clock changes)
    func currentTime() -> TimeInterval {
        return CACurrentMediaTime()
    }
    
    /// Calculate elapsed time since a previous timestamp
    func elapsedTime(since startTime: TimeInterval) -> TimeInterval {
        return CACurrentMediaTime() - startTime
    }
}

/// Mock timer service for testing
final class MockTimerService: TimerServiceProtocol {
    var mockTime: TimeInterval = 0
    
    func currentTime() -> TimeInterval {
        return mockTime
    }
    
    func elapsedTime(since startTime: TimeInterval) -> TimeInterval {
        return mockTime - startTime
    }
    
    /// Advance time by given duration (for testing)
    func advance(by duration: TimeInterval) {
        mockTime += duration
    }
}
