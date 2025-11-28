//
//  FocusSession.swift
//  ForestFocus
//
//  Created by AI Assistant on 10/29/25.
//

import Foundation
import SwiftData

/// Represents a single focus session (active, paused, completed, or abandoned)
@Model
final class FocusSession {
    // Primary key
    var id: UUID
    
    // Timestamps
    var startTime: Date
    var endTime: Date?
    
    // State tracking (stored as String for SwiftData compatibility)
    var state: String // "active", "paused", "completed", "abandoned"
    
    // Duration tracking
    var duration: TimeInterval // Actual focus time (excludes paused time)
    var pausedDuration: TimeInterval // Total time spent paused
    
    // Metadata
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        state: String = SessionState.active.rawValue,
        duration: TimeInterval = 0,
        pausedDuration: TimeInterval = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.state = state
        self.duration = duration
        self.pausedDuration = pausedDuration
        self.createdAt = createdAt
    }
}

// MARK: - Convenience Extensions

extension FocusSession {
    /// Get state as SessionState enum
    var sessionState: SessionState? {
        return SessionState(rawValue: state)
    }
    
    /// Check if transition to new state is valid
    func canTransition(to newState: SessionState) -> Bool {
        guard let currentState = sessionState else { return false }
        return currentState.canTransition(to: newState)
    }
    
    /// Update state (validates transition)
    func updateState(to newState: SessionState) -> Bool {
        guard canTransition(to: newState) else { return false }
        state = newState.rawValue
        return true
    }
}
