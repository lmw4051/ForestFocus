//
//  FocusSessionTests.swift
//  ForestFocusTests
//
//  Created by AI Assistant on 10/29/25.
//  Task: T029 - Write unit tests for FocusSession model
//

import XCTest
import SwiftData
@testable import ForestFocus

final class FocusSessionTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    
    override func setUp() async throws {
        // In-memory container for isolated testing
        let schema = Schema([FocusSession.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)
    }
    
    override func tearDown() {
        container = nil
        context = nil
    }
    
    // MARK: - Initialization Tests
    
    func testSessionCreationWithDefaults() {
        // Given: Default initialization
        let session = FocusSession()
        
        // Then: Verify default values
        XCTAssertNotNil(session.id)
        XCTAssertEqual(session.state, SessionState.active.rawValue)
        XCTAssertEqual(session.duration, 0)
        XCTAssertEqual(session.pausedDuration, 0)
        XCTAssertNil(session.endTime)
        XCTAssertNotNil(session.startTime)
        XCTAssertNotNil(session.createdAt)
    }
    
    func testSessionCreationWithCustomValues() throws {
        // Given: Custom values
        let id = UUID()
        let startTime = Date()
        let duration: TimeInterval = 1200 // 20 minutes
        
        // When: Create session with custom values
        let session = FocusSession(
            id: id,
            startTime: startTime,
            state: SessionState.completed.rawValue,
            duration: duration
        )
        
        // Then: Verify values are set
        XCTAssertEqual(session.id, id)
        XCTAssertEqual(session.startTime, startTime)
        XCTAssertEqual(session.state, SessionState.completed.rawValue)
        XCTAssertEqual(session.duration, duration)
    }
    
    // MARK: - State Transition Tests
    
    func testActiveCanTransitionToPaused() {
        // Given: Active session
        let session = FocusSession(state: SessionState.active.rawValue)
        
        // When: Check transition to paused
        let canTransition = session.canTransition(to: .paused)
        
        // Then: Transition is valid
        XCTAssertTrue(canTransition)
    }
    
    func testActiveCanTransitionToCompleted() {
        // Given: Active session
        let session = FocusSession(state: SessionState.active.rawValue)
        
        // When: Check transition to completed
        let canTransition = session.canTransition(to: .completed)
        
        // Then: Transition is valid
        XCTAssertTrue(canTransition)
    }
    
    func testActiveCanTransitionToAbandoned() {
        // Given: Active session
        let session = FocusSession(state: SessionState.active.rawValue)
        
        // When: Check transition to abandoned
        let canTransition = session.canTransition(to: .abandoned)
        
        // Then: Transition is valid
        XCTAssertTrue(canTransition)
    }
    
    func testPausedCanTransitionToActive() {
        // Given: Paused session
        let session = FocusSession(state: SessionState.paused.rawValue)
        
        // When: Check transition to active
        let canTransition = session.canTransition(to: .active)
        
        // Then: Transition is valid
        XCTAssertTrue(canTransition)
    }
    
    func testPausedCanTransitionToAbandoned() {
        // Given: Paused session
        let session = FocusSession(state: SessionState.paused.rawValue)
        
        // When: Check transition to abandoned
        let canTransition = session.canTransition(to: .abandoned)
        
        // Then: Transition is valid
        XCTAssertTrue(canTransition)
    }
    
    func testPausedCannotTransitionToCompleted() {
        // Given: Paused session
        let session = FocusSession(state: SessionState.paused.rawValue)
        
        // When: Check transition to completed
        let canTransition = session.canTransition(to: .completed)
        
        // Then: Transition is invalid
        XCTAssertFalse(canTransition)
    }
    
    func testCompletedIsTerminalState() {
        // Given: Completed session
        let session = FocusSession(state: SessionState.completed.rawValue)
        
        // When: Check all possible transitions
        let canTransitionToActive = session.canTransition(to: .active)
        let canTransitionToPaused = session.canTransition(to: .paused)
        let canTransitionToAbandoned = session.canTransition(to: .abandoned)
        
        // Then: All transitions are invalid
        XCTAssertFalse(canTransitionToActive)
        XCTAssertFalse(canTransitionToPaused)
        XCTAssertFalse(canTransitionToAbandoned)
    }
    
    func testAbandonedIsTerminalState() {
        // Given: Abandoned session
        let session = FocusSession(state: SessionState.abandoned.rawValue)
        
        // When: Check all possible transitions
        let canTransitionToActive = session.canTransition(to: .active)
        let canTransitionToPaused = session.canTransition(to: .paused)
        let canTransitionToCompleted = session.canTransition(to: .completed)
        
        // Then: All transitions are invalid
        XCTAssertFalse(canTransitionToActive)
        XCTAssertFalse(canTransitionToPaused)
        XCTAssertFalse(canTransitionToCompleted)
    }
    
    // MARK: - Update State Tests
    
    func testUpdateStateSucceedsForValidTransition() {
        // Given: Active session
        let session = FocusSession(state: SessionState.active.rawValue)
        
        // When: Update to paused
        let success = session.updateState(to: .paused)
        
        // Then: Update succeeds and state is changed
        XCTAssertTrue(success)
        XCTAssertEqual(session.state, SessionState.paused.rawValue)
    }
    
    func testUpdateStateFailsForInvalidTransition() {
        // Given: Completed session (terminal)
        let session = FocusSession(state: SessionState.completed.rawValue)
        
        // When: Try to update to active
        let success = session.updateState(to: .active)
        
        // Then: Update fails and state is unchanged
        XCTAssertFalse(success)
        XCTAssertEqual(session.state, SessionState.completed.rawValue)
    }
    
    // MARK: - SwiftData Persistence Tests
    
    func testSessionPersistsToSwiftData() throws {
        // Given: A new session
        let session = FocusSession(state: SessionState.active.rawValue)
        
        // When: Insert and save
        context.insert(session)
        try context.save()
        
        // Then: Session can be fetched
        let descriptor = FetchDescriptor<FocusSession>()
        let sessions = try context.fetch(descriptor)
        
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.id, session.id)
    }
    
    func testMultipleSessionsPersist() throws {
        // Given: Multiple sessions
        let session1 = FocusSession(state: SessionState.completed.rawValue)
        let session2 = FocusSession(state: SessionState.abandoned.rawValue)
        let session3 = FocusSession(state: SessionState.active.rawValue)
        
        // When: Insert all and save
        context.insert(session1)
        context.insert(session2)
        context.insert(session3)
        try context.save()
        
        // Then: All sessions can be fetched
        let descriptor = FetchDescriptor<FocusSession>()
        let sessions = try context.fetch(descriptor)
        
        XCTAssertEqual(sessions.count, 3)
    }
    
    func testQueryCompletedSessions() throws {
        // Given: Mixed sessions
        let completed1 = FocusSession(state: SessionState.completed.rawValue)
        let completed2 = FocusSession(state: SessionState.completed.rawValue)
        let active = FocusSession(state: SessionState.active.rawValue)
        let abandoned = FocusSession(state: SessionState.abandoned.rawValue)
        
        context.insert(completed1)
        context.insert(completed2)
        context.insert(active)
        context.insert(abandoned)
        try context.save()
        
        // When: Query only completed sessions
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.state == "completed" }
        )
        let completedSessions = try context.fetch(descriptor)
        
        // Then: Only completed sessions returned
        XCTAssertEqual(completedSessions.count, 2)
        XCTAssertTrue(completedSessions.allSatisfy { $0.state == SessionState.completed.rawValue })
    }
    
    func testSessionUpdatesPersist() throws {
        // Given: A persisted session
        let session = FocusSession(state: SessionState.active.rawValue)
        context.insert(session)
        try context.save()
        
        // When: Update session state
        _ = session.updateState(to: .completed)
        session.duration = 1500 // 25 minutes
        session.endTime = Date()
        try context.save()
        
        // Then: Updates are persisted
        let descriptor = FetchDescriptor<FocusSession>()
        let sessions = try context.fetch(descriptor)
        
        XCTAssertEqual(sessions.first?.state, SessionState.completed.rawValue)
        XCTAssertEqual(sessions.first?.duration, 1500)
        XCTAssertNotNil(sessions.first?.endTime)
    }
    
    // MARK: - SessionState Helper Tests
    
    func testSessionStatePropertyReturnsCorrectEnum() {
        // Given: Session with various states
        let activeSession = FocusSession(state: SessionState.active.rawValue)
        let pausedSession = FocusSession(state: SessionState.paused.rawValue)
        let completedSession = FocusSession(state: SessionState.completed.rawValue)
        
        // When/Then: sessionState returns correct enum
        XCTAssertEqual(activeSession.sessionState, .active)
        XCTAssertEqual(pausedSession.sessionState, .paused)
        XCTAssertEqual(completedSession.sessionState, .completed)
    }
    
    func testSessionStateReturnsNilForInvalidState() {
        // Given: Session with invalid state string
        let session = FocusSession()
        session.state = "invalid_state"
        
        // When/Then: sessionState returns nil
        XCTAssertNil(session.sessionState)
    }
    
    // MARK: - Edge Cases
    
    func testZeroDurationIsValid() {
        // Given: Session with zero duration
        let session = FocusSession(duration: 0)
        
        // Then: Valid state
        XCTAssertEqual(session.duration, 0)
    }
    
    func testMaxDurationIsValid() {
        // Given: Session with 25 minutes duration (max)
        let session = FocusSession(duration: 1500)
        
        // Then: Valid state
        XCTAssertEqual(session.duration, 1500)
    }
    
    func testPausedDurationCanExceedFocusDuration() {
        // Given: Session with long paused duration
        let session = FocusSession(duration: 300, pausedDuration: 600)
        
        // Then: Valid (user paused longer than focused)
        XCTAssertEqual(session.pausedDuration, 600)
    }
}
