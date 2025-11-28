//
//  SessionState.swift
//  ForestFocus
//
//  Created by AI Assistant on 10/29/25.
//

import Foundation

/// Represents the current state of a focus session
enum SessionState: String, Codable, CaseIterable {
    case idle
    case active
    case paused
    case completed
    case abandoned
    
    /// Human-readable display name
    var displayName: String {
        switch self {
        case .idle: return "Idle"
        case .active: return "Active"
        case .paused: return "Paused"
        case .completed: return "Completed"
        case .abandoned: return "Abandoned"
        }
    }
    
    /// Valid state transitions from current state
    var canTransitionTo: [SessionState] {
        switch self {
        case .idle:
            return [.active]
        case .active:
            return [.paused, .completed, .abandoned]
        case .paused:
            return [.active, .abandoned]
        case .completed, .abandoned:
            return [] // Terminal states
        }
    }
    
    /// Check if transition to new state is valid
    func canTransition(to newState: SessionState) -> Bool {
        return canTransitionTo.contains(newState)
    }
}
