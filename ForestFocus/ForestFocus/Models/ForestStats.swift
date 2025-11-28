//
//  ForestStats.swift
//  ForestFocus
//
//  Created by AI Assistant on 10/29/25.
//

import Foundation

/// Aggregate statistics computed from focus sessions (not persisted)
struct ForestStats {
    // Totals
    let totalTrees: Int
    let totalFocusTime: TimeInterval
    let totalSessions: Int // Including abandoned
    
    // Today's metrics
    let todaysTrees: Int
    let todaysFocusTime: TimeInterval
    
    // Streaks
    let currentStreak: Int // Consecutive days with ≥1 completed session
    let longestStreak: Int // Historical best
    
    // Abandoned tracking
    let abandonedCount: Int
    let completionRate: Double // Percentage of completed sessions
    
    // MARK: - Computed Properties
    
    var totalFocusHours: Double {
        totalFocusTime / 3600.0
    }
    
    var averageSessionsPerDay: Double {
        guard currentStreak > 0 else { return 0 }
        return Double(totalTrees) / Double(currentStreak)
    }
    
    var formattedTotalFocusTime: String {
        let hours = Int(totalFocusTime) / 3600
        let minutes = (Int(totalFocusTime) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Factory Method

extension ForestStats {
    /// Compute statistics from array of sessions
    static func from(sessions: [FocusSession]) -> ForestStats {
        let completedSessions = sessions.filter { $0.state == SessionState.completed.rawValue }
        let abandonedSessions = sessions.filter { $0.state == SessionState.abandoned.rawValue }
        
        let totalTrees = completedSessions.count
        let totalFocusTime = completedSessions.reduce(0) { $0 + $1.duration }
        let totalSessions = sessions.count
        
        // Today's metrics
        let todaysSessions = completedSessions.filter { session in
            Calendar.current.isDateInToday(session.endTime ?? session.startTime)
        }
        let todaysTrees = todaysSessions.count
        let todaysFocusTime = todaysSessions.reduce(0) { $0 + $1.duration }
        
        // Streak calculation
        let currentStreak = calculateCurrentStreak(from: completedSessions)
        let longestStreak = calculateLongestStreak(from: completedSessions)
        
        // Abandoned tracking
        let abandonedCount = abandonedSessions.count
        let completionRate = totalSessions > 0 ? Double(totalTrees) / Double(totalSessions) * 100 : 0
        
        return ForestStats(
            totalTrees: totalTrees,
            totalFocusTime: totalFocusTime,
            totalSessions: totalSessions,
            todaysTrees: todaysTrees,
            todaysFocusTime: todaysFocusTime,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            abandonedCount: abandonedCount,
            completionRate: completionRate
        )
    }
    
    /// Calculate current streak (consecutive days with ≥1 completed session)
    private static func calculateCurrentStreak(from sessions: [FocusSession]) -> Int {
        let sortedSessions = sessions.sorted { 
            ($0.endTime ?? $0.startTime) > ($1.endTime ?? $1.startTime) 
        }
        
        guard !sortedSessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        while true {
            let sessionsOnDate = sortedSessions.filter { session in
                calendar.isDate(
                    session.endTime ?? session.startTime,
                    inSameDayAs: checkDate
                )
            }
            
            if sessionsOnDate.isEmpty {
                break
            }
            
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }
        
        return streak
    }
    
    /// Calculate longest historical streak
    private static func calculateLongestStreak(from sessions: [FocusSession]) -> Int {
        let sortedSessions = sessions.sorted { 
            ($0.endTime ?? $0.startTime) < ($1.endTime ?? $1.startTime) 
        }
        
        guard !sortedSessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var maxStreak = 0
        var currentStreak = 0
        var lastDate: Date?
        
        for session in sortedSessions {
            let sessionDate = calendar.startOfDay(for: session.endTime ?? session.startTime)
            
            if let last = lastDate {
                let daysDiff = calendar.dateComponents([.day], from: last, to: sessionDate).day ?? 0
                
                if daysDiff == 1 {
                    // Consecutive day
                    currentStreak += 1
                } else if daysDiff > 1 {
                    // Gap - reset streak
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
                // Same day: don't increment streak
            } else {
                currentStreak = 1
            }
            
            lastDate = sessionDate
        }
        
        return max(maxStreak, currentStreak)
    }
}
