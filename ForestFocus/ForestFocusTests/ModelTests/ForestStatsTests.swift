//
//  ForestStatsTests.swift
//  ForestFocusTests
//
//  Created by AI Assistant on 10/29/25.
//  Task: T029 - Test ForestStats calculation algorithms
//

import XCTest
@testable import ForestFocus

final class ForestStatsTests: XCTestCase {
    
    // MARK: - Empty State Tests
    
    func testEmptySessionsReturnsZeroStats() {
        // Given: No sessions
        let sessions: [FocusSession] = []
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: All stats are zero
        XCTAssertEqual(stats.totalTrees, 0)
        XCTAssertEqual(stats.totalFocusTime, 0)
        XCTAssertEqual(stats.totalSessions, 0)
        XCTAssertEqual(stats.todaysTrees, 0)
        XCTAssertEqual(stats.currentStreak, 0)
        XCTAssertEqual(stats.longestStreak, 0)
        XCTAssertEqual(stats.abandonedCount, 0)
        XCTAssertEqual(stats.completionRate, 0)
    }
    
    // MARK: - Total Trees Tests
    
    func testTotalTreesCountsOnlyCompletedSessions() {
        // Given: Mixed session states
        let completed1 = FocusSession(state: SessionState.completed.rawValue, duration: 1500)
        let completed2 = FocusSession(state: SessionState.completed.rawValue, duration: 1500)
        let active = FocusSession(state: SessionState.active.rawValue)
        let abandoned = FocusSession(state: SessionState.abandoned.rawValue)
        
        let sessions = [completed1, completed2, active, abandoned]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Only completed sessions counted
        XCTAssertEqual(stats.totalTrees, 2)
    }
    
    // MARK: - Total Focus Time Tests
    
    func testTotalFocusTimeSum() {
        // Given: Completed sessions with different durations
        let session1 = FocusSession(
            state: SessionState.completed.rawValue,
            duration: 1500 // 25 min
        )
        let session2 = FocusSession(
            state: SessionState.completed.rawValue,
            duration: 1200 // 20 min
        )
        let session3 = FocusSession(
            state: SessionState.completed.rawValue,
            duration: 900 // 15 min
        )
        
        let sessions = [session1, session2, session3]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Total is sum of all durations
        XCTAssertEqual(stats.totalFocusTime, 3600) // 60 minutes
    }
    
    func testTotalFocusTimeIgnoresAbandonedSessions() {
        // Given: Mixed sessions
        let completed = FocusSession(
            state: SessionState.completed.rawValue,
            duration: 1500
        )
        let abandoned = FocusSession(
            state: SessionState.abandoned.rawValue,
            duration: 500 // Partial time
        )
        
        let sessions = [completed, abandoned]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Only completed time counted
        XCTAssertEqual(stats.totalFocusTime, 1500)
    }
    
    // MARK: - Today's Trees Tests
    
    func testTodaysTreesCountsOnlyToday() {
        // Given: Sessions from different days
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        let todaySession = FocusSession(
            startTime: today,
            endTime: today,
            state: SessionState.completed.rawValue,
            duration: 1500
        )
        
        let yesterdaySession = FocusSession(
            startTime: yesterday,
            endTime: yesterday,
            state: SessionState.completed.rawValue,
            duration: 1500
        )
        
        let sessions = [todaySession, yesterdaySession]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Only today's session counted
        XCTAssertEqual(stats.todaysTrees, 1)
    }
    
    func testMultipleSessionsToday() {
        // Given: Multiple sessions today
        let now = Date()
        let session1 = FocusSession(
            endTime: now,
            state: SessionState.completed.rawValue,
            duration: 1500
        )
        let session2 = FocusSession(
            endTime: now,
            state: SessionState.completed.rawValue,
            duration: 1500
        )
        let session3 = FocusSession(
            endTime: now,
            state: SessionState.completed.rawValue,
            duration: 1500
        )
        
        let sessions = [session1, session2, session3]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: All today's sessions counted
        XCTAssertEqual(stats.todaysTrees, 3)
    }
    
    // MARK: - Current Streak Tests
    
    func testCurrentStreakWithConsecutiveDays() {
        // Given: Sessions on consecutive days (including today)
        let today = Date()
        let sessions = (0..<5).map { daysAgo in
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: today)!
            return FocusSession(
                endTime: date,
                state: SessionState.completed.rawValue,
                duration: 1500
            )
        }
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Streak is 5 days
        XCTAssertEqual(stats.currentStreak, 5)
    }
    
    func testCurrentStreakBreaksWithGap() {
        // Given: Sessions with a gap
        let today = Date()
        let todaySession = FocusSession(
            endTime: today,
            state: SessionState.completed.rawValue,
            duration: 1500
        )
        
        // Gap: no session yesterday
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let oldSession = FocusSession(
            endTime: twoDaysAgo,
            state: SessionState.completed.rawValue,
            duration: 1500
        )
        
        let sessions = [todaySession, oldSession]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Streak is only today (gap broke it)
        XCTAssertEqual(stats.currentStreak, 1)
    }
    
    func testCurrentStreakIsZeroWithNoRecentSessions() {
        // Given: Session from 2 days ago (not today or yesterday)
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let oldSession = FocusSession(
            endTime: twoDaysAgo,
            state: SessionState.completed.rawValue,
            duration: 1500
        )
        
        let sessions = [oldSession]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: No current streak
        XCTAssertEqual(stats.currentStreak, 0)
    }
    
    func testMultipleSessionsSameDayCountOnce() {
        // Given: Multiple sessions on same day
        let today = Date()
        let session1 = FocusSession(endTime: today, state: SessionState.completed.rawValue, duration: 1500)
        let session2 = FocusSession(endTime: today, state: SessionState.completed.rawValue, duration: 1500)
        let session3 = FocusSession(endTime: today, state: SessionState.completed.rawValue, duration: 1500)
        
        let sessions = [session1, session2, session3]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Streak is 1 day (not 3)
        XCTAssertEqual(stats.currentStreak, 1)
    }
    
    // MARK: - Longest Streak Tests
    
    func testLongestStreakFindsMaximum() {
        // Given: Two separate streaks with gap
        let today = Date()
        
        // Recent streak: 2 days
        let recentSessions = (0..<2).map { daysAgo in
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: today)!
            return FocusSession(endTime: date, state: SessionState.completed.rawValue, duration: 1500)
        }
        
        // Gap of 2 days (no sessions on -3 and -4)
        
        // Older streak: 5 days
        let olderSessions = (5..<10).map { daysAgo in
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: today)!
            return FocusSession(endTime: date, state: SessionState.completed.rawValue, duration: 1500)
        }
        
        let sessions = recentSessions + olderSessions
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Longest streak is 5 (not current streak of 2)
        XCTAssertEqual(stats.currentStreak, 2)
        XCTAssertEqual(stats.longestStreak, 5)
    }
    
    func testLongestStreakEqualsCurrentWhenNoBreaks() {
        // Given: Continuous streak
        let today = Date()
        let sessions = (0..<7).map { daysAgo in
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: today)!
            return FocusSession(endTime: date, state: SessionState.completed.rawValue, duration: 1500)
        }
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Current and longest are equal
        XCTAssertEqual(stats.currentStreak, 7)
        XCTAssertEqual(stats.longestStreak, 7)
    }
    
    // MARK: - Abandoned Count Tests
    
    func testAbandonedCountOnlyCountsAbandoned() {
        // Given: Mixed sessions
        let completed = FocusSession(state: SessionState.completed.rawValue)
        let abandoned1 = FocusSession(state: SessionState.abandoned.rawValue)
        let abandoned2 = FocusSession(state: SessionState.abandoned.rawValue)
        let active = FocusSession(state: SessionState.active.rawValue)
        
        let sessions = [completed, abandoned1, abandoned2, active]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Only abandoned counted
        XCTAssertEqual(stats.abandonedCount, 2)
    }
    
    // MARK: - Completion Rate Tests
    
    func testCompletionRateCalculation() {
        // Given: 3 completed, 1 abandoned (75% completion)
        let completed1 = FocusSession(state: SessionState.completed.rawValue)
        let completed2 = FocusSession(state: SessionState.completed.rawValue)
        let completed3 = FocusSession(state: SessionState.completed.rawValue)
        let abandoned = FocusSession(state: SessionState.abandoned.rawValue)
        
        let sessions = [completed1, completed2, completed3, abandoned]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Completion rate is 75%
        XCTAssertEqual(stats.completionRate, 75.0, accuracy: 0.01)
    }
    
    func testCompletionRateWithNoCompletedSessions() {
        // Given: Only abandoned sessions
        let abandoned1 = FocusSession(state: SessionState.abandoned.rawValue)
        let abandoned2 = FocusSession(state: SessionState.abandoned.rawValue)
        
        let sessions = [abandoned1, abandoned2]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Completion rate is 0%
        XCTAssertEqual(stats.completionRate, 0.0)
    }
    
    func testCompletionRatePerfectScore() {
        // Given: All completed sessions
        let completed1 = FocusSession(state: SessionState.completed.rawValue)
        let completed2 = FocusSession(state: SessionState.completed.rawValue)
        
        let sessions = [completed1, completed2]
        
        // When: Calculate stats
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Completion rate is 100%
        XCTAssertEqual(stats.completionRate, 100.0)
    }
    
    // MARK: - Computed Properties Tests
    
    func testFormattedTotalFocusTimeHoursAndMinutes() {
        // Given: Sessions totaling 90 minutes (1h 30m)
        let session1 = FocusSession(state: SessionState.completed.rawValue, duration: 3600) // 60 min
        let session2 = FocusSession(state: SessionState.completed.rawValue, duration: 1800) // 30 min
        
        let sessions = [session1, session2]
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Formatted as "1h 30m"
        XCTAssertEqual(stats.formattedTotalFocusTime, "1h 30m")
    }
    
    func testFormattedTotalFocusTimeMinutesOnly() {
        // Given: Session less than 1 hour
        let session = FocusSession(state: SessionState.completed.rawValue, duration: 1500) // 25 min
        
        let sessions = [session]
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Formatted as "25m"
        XCTAssertEqual(stats.formattedTotalFocusTime, "25m")
    }
    
    func testTotalFocusHoursCalculation() {
        // Given: 7200 seconds (2 hours)
        let session = FocusSession(state: SessionState.completed.rawValue, duration: 7200)
        
        let sessions = [session]
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Hours is 2.0
        XCTAssertEqual(stats.totalFocusHours, 2.0, accuracy: 0.01)
    }
    
    func testAverageSessionsPerDay() {
        // Given: 10 trees over 5-day streak
        let today = Date()
        let sessions = (0..<5).flatMap { daysAgo in
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: today)!
            // 2 sessions per day
            return [
                FocusSession(endTime: date, state: SessionState.completed.rawValue, duration: 1500),
                FocusSession(endTime: date, state: SessionState.completed.rawValue, duration: 1500)
            ]
        }
        
        let stats = ForestStats.from(sessions: sessions)
        
        // Then: Average is 2 sessions per day
        XCTAssertEqual(stats.averageSessionsPerDay, 2.0, accuracy: 0.01)
    }
    
    // MARK: - Performance Tests
    
    func testStatsCalculationPerformanceWith1000Sessions() {
        // Given: 1000 sessions
        let sessions = (0..<1000).map { _ in
            FocusSession(state: SessionState.completed.rawValue, duration: 1500)
        }
        
        // When: Measure stats calculation
        measure {
            _ = ForestStats.from(sessions: sessions)
        }
        
        // Then: Should complete in < 20ms (measured by XCTest)
    }
}
