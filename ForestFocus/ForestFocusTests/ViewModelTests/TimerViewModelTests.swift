//
//  TimerViewModelTests.swift
//  ForestFocusTests
//
//  Created by AI Assistant on 10/29/25.
//  Task: T046 - Test TimerViewModel (TDD RED phase)
//

import XCTest
import Combine
import SwiftData
@testable import ForestFocus

@MainActor
final class TimerViewModelTests: XCTestCase {
    
    var viewModel: TimerViewModel!
    var mockTimer: MockTimerService!
    var mockNotification: MockNotificationService!
    var mockBackground: MockBackgroundService!
    var modelContext: ModelContext!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() async throws {
        // Setup in-memory SwiftData
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FocusSession.self, configurations: config)
        modelContext = ModelContext(container)
        
        // Setup mock services
        mockTimer = MockTimerService()
        mockNotification = MockNotificationService()
        mockBackground = MockBackgroundService()
        
        // Create view model
        viewModel = TimerViewModel(
            modelContext: modelContext,
            timerService: mockTimer,
            notificationService: mockNotification,
            backgroundService: mockBackground
        )
        
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockTimer = nil
        mockNotification = nil
        mockBackground = nil
        modelContext = nil
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        // Then: Initial state is correct
        XCTAssertEqual(viewModel.timeRemaining, 1500) // 25 minutes
        XCTAssertEqual(viewModel.sessionState, .idle)
        XCTAssertEqual(viewModel.growthStage, 0)
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertNil(viewModel.currentSession)
    }
    
    func testInitialTimeRemainingIs25Minutes() {
        XCTAssertEqual(viewModel.timeRemaining, 1500)
    }
    
    // MARK: - Start Session Tests
    
    func testStartSessionCreatesNewSession() async {
        // When: Start session
        await viewModel.startSession()
        
        // Then: Session created
        XCTAssertNotNil(viewModel.currentSession)
        XCTAssertEqual(viewModel.currentSession?.sessionState, .active)
    }
    
    func testStartSessionUpdatesState() async {
        // When: Start session
        await viewModel.startSession()
        
        // Then: State is running
        XCTAssertEqual(viewModel.sessionState, .active)
        XCTAssertTrue(viewModel.isRunning)
    }
    
    func testStartSessionRequestsNotificationPermission() async {
        // When: Start session
        await viewModel.startSession()
        
        // Then: Requested authorization
        XCTAssertTrue(mockNotification.requestAuthorizationCalled)
    }
    
    func testStartSessionSchedulesNotification() async {
        // When: Start session
        await viewModel.startSession()
        
        // Then: Notification scheduled
        XCTAssertEqual(mockNotification.scheduledNotifications.count, 1)
    }
    
    func testStartSessionPersistsToSwiftData() async {
        // When: Start session
        await viewModel.startSession()
        
        // Then: Session saved to SwiftData
        let descriptor = FetchDescriptor<FocusSession>()
        let sessions = try? modelContext.fetch(descriptor)
        XCTAssertEqual(sessions?.count, 1)
    }
    
    // MARK: - Timer Tick Tests
    
    func testTimerTickDecrementsTimeRemaining() async {
        // Given: Session started
        await viewModel.startSession()
        let initialTime = viewModel.timeRemaining
        
        // When: Advance time by 1 second
        mockTimer.advance(by: 1.0)
        await viewModel.tick()
        
        // Then: Time decreased by 1
        XCTAssertEqual(viewModel.timeRemaining, initialTime - 1)
    }
    
    func testTimerTickUpdatesGrowthStage() async {
        // Given: Session started
        await viewModel.startSession()
        
        // When: Advance to 20% complete (300 seconds)
        mockTimer.advance(by: 300)
        await viewModel.tick()
        
        // Then: Growth stage is 1
        XCTAssertEqual(viewModel.growthStage, 1)
    }
    
    func testGrowthStageProgression() async {
        // Given: Session started
        await viewModel.startSession()
        
        // Stage 0: 0%
        XCTAssertEqual(viewModel.growthStage, 0)
        
        // Stage 1: 20% (300s)
        mockTimer.advance(by: 300)
        await viewModel.tick()
        XCTAssertEqual(viewModel.growthStage, 1)
        
        // Stage 2: 40% (600s total)
        mockTimer.advance(by: 300)
        await viewModel.tick()
        XCTAssertEqual(viewModel.growthStage, 2)
        
        // Stage 3: 60% (900s total)
        mockTimer.advance(by: 300)
        await viewModel.tick()
        XCTAssertEqual(viewModel.growthStage, 3)
        
        // Stage 4: 80% (1200s total)
        mockTimer.advance(by: 300)
        await viewModel.tick()
        XCTAssertEqual(viewModel.growthStage, 4)
        
        // Stage 5: 100% (1500s total - complete)
        mockTimer.advance(by: 300)
        await viewModel.tick()
        XCTAssertEqual(viewModel.growthStage, 5)
    }
    
    // MARK: - Complete Session Tests
    
    func testCompleteSessionWhenTimeExpires() async {
        // Given: Session started
        await viewModel.startSession()
        
        // When: Time expires
        mockTimer.advance(by: 1500)
        await viewModel.tick()
        
        // Then: Session completed
        XCTAssertEqual(viewModel.sessionState, .completed)
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertEqual(viewModel.growthStage, 5)
    }
    
    func testCompleteSessionUpdatesSwiftData() async {
        // Given: Session started
        await viewModel.startSession()
        
        // When: Complete session
        mockTimer.advance(by: 1500)
        await viewModel.tick()
        
        // Then: Session marked completed in SwiftData
        let descriptor = FetchDescriptor<FocusSession>()
        let sessions = try? modelContext.fetch(descriptor)
        XCTAssertEqual(sessions?.first?.state, "completed")
    }
    
    func testCompleteSessionSetsEndTime() async {
        // Given: Session started
        await viewModel.startSession()
        
        // When: Complete
        mockTimer.advance(by: 1500)
        await viewModel.tick()
        
        // Then: End time is set
        XCTAssertNotNil(viewModel.currentSession?.endTime)
    }
    
    // MARK: - Pause/Resume Tests
    
    func testPauseSessionStopsTimer() async {
        // Given: Running session
        await viewModel.startSession()
        XCTAssertTrue(viewModel.isRunning)
        
        // When: Pause
        await viewModel.pauseSession()
        
        // Then: Timer stopped
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertEqual(viewModel.sessionState, .paused)
    }
    
    func testPauseSessionUpdatesSwiftData() async {
        // Given: Running session
        await viewModel.startSession()
        
        // When: Pause
        await viewModel.pauseSession()
        
        // Then: Session state updated
        XCTAssertEqual(viewModel.currentSession?.sessionState, .paused)
    }
    
    func testResumeSessionRestartsTimer() async {
        // Given: Paused session
        await viewModel.startSession()
        await viewModel.pauseSession()
        XCTAssertFalse(viewModel.isRunning)
        
        // When: Resume
        await viewModel.resumeSession()
        
        // Then: Timer running
        XCTAssertTrue(viewModel.isRunning)
        XCTAssertEqual(viewModel.sessionState, .active)
    }
    
    func testResumePreservesTimeRemaining() async {
        // Given: Session paused at 1000 seconds
        await viewModel.startSession()
        mockTimer.advance(by: 500)
        await viewModel.tick()
        let timeBeforePause = viewModel.timeRemaining
        
        await viewModel.pauseSession()
        
        // When: Resume
        await viewModel.resumeSession()
        
        // Then: Time remaining unchanged
        XCTAssertEqual(viewModel.timeRemaining, timeBeforePause)
    }
    
    // MARK: - Abandon Session Tests
    
    func testAbandonSessionStopsTimer() async {
        // Given: Running session
        await viewModel.startSession()
        
        // When: Abandon
        await viewModel.abandonSession()
        
        // Then: Timer stopped
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertEqual(viewModel.sessionState, .abandoned)
    }
    
    func testAbandonSessionMarksSessionAbandoned() async {
        // Given: Running session
        await viewModel.startSession()
        
        // When: Abandon
        await viewModel.abandonSession()
        
        // Then: Session marked abandoned
        XCTAssertEqual(viewModel.currentSession?.sessionState, .abandoned)
    }
    
    func testAbandonSessionCancelsNotification() async {
        // Given: Session with scheduled notification
        await viewModel.startSession()
        XCTAssertEqual(mockNotification.scheduledNotifications.count, 1)
        
        // When: Abandon
        await viewModel.abandonSession()
        
        // Then: Notification cancelled
        XCTAssertEqual(mockNotification.scheduledNotifications.count, 0)
    }
    
    func testAbandonSessionResetsTimeRemaining() async {
        // Given: Session in progress
        await viewModel.startSession()
        mockTimer.advance(by: 500)
        await viewModel.tick()
        
        // When: Abandon
        await viewModel.abandonSession()
        
        // Then: Time reset to 25 minutes
        XCTAssertEqual(viewModel.timeRemaining, 1500)
    }
    
    func testAbandonSessionResetsGrowthStage() async {
        // Given: Session with tree growth
        await viewModel.startSession()
        mockTimer.advance(by: 600)
        await viewModel.tick()
        XCTAssertGreaterThan(viewModel.growthStage, 0)
        
        // When: Abandon
        await viewModel.abandonSession()
        
        // Then: Growth stage reset
        XCTAssertEqual(viewModel.growthStage, 0)
    }
    
    // MARK: - Background/Foreground Tests
    
    func testBackgroundingPausesTimer() async {
        // Given: Running session
        await viewModel.startSession()
        XCTAssertTrue(viewModel.isRunning)
        
        // When: App enters background
        mockBackground.simulateEnterBackground()
        
        // Then: Time should be saved but continue
        // (In real app, background time is tracked)
        XCTAssertNotNil(viewModel.currentSession)
    }
    
    func testForegroundingSyncsElapsedTime() async {
        // Given: Session running, then backgrounded for 60 seconds
        await viewModel.startSession()
        let timeBeforeBackground = viewModel.timeRemaining
        
        mockBackground.simulateEnterBackground()
        mockTimer.advance(by: 60)
        
        // When: Return to foreground
        mockBackground.simulateEnterForeground()
        await viewModel.syncBackgroundTime(elapsed: 60)
        
        // Then: Time decreased by 60
        XCTAssertEqual(viewModel.timeRemaining, timeBeforeBackground - 60)
    }
    
    // MARK: - Computed Properties Tests
    
    func testFormattedTimeRemainingMinutesAndSeconds() {
        // Given: 1500 seconds (25:00)
        viewModel.timeRemaining = 1500
        XCTAssertEqual(viewModel.formattedTimeRemaining, "25:00")
        
        // 90 seconds (01:30)
        viewModel.timeRemaining = 90
        XCTAssertEqual(viewModel.formattedTimeRemaining, "01:30")
        
        // 5 seconds (00:05)
        viewModel.timeRemaining = 5
        XCTAssertEqual(viewModel.formattedTimeRemaining, "00:05")
    }
    
    func testProgressPercentage() async {
        // Given: Session started
        await viewModel.startSession()
        
        // 0% complete
        XCTAssertEqual(viewModel.progressPercentage, 0.0)
        
        // 25% complete (375s elapsed)
        mockTimer.advance(by: 375)
        await viewModel.tick()
        XCTAssertEqual(viewModel.progressPercentage, 0.25, accuracy: 0.01)
        
        // 50% complete (750s elapsed total)
        mockTimer.advance(by: 375)
        await viewModel.tick()
        XCTAssertEqual(viewModel.progressPercentage, 0.5, accuracy: 0.01)
        
        // 100% complete
        mockTimer.advance(by: 750)
        await viewModel.tick()
        XCTAssertEqual(viewModel.progressPercentage, 1.0, accuracy: 0.01)
    }
    
    func testCanPause() async {
        // Initially can't pause
        XCTAssertFalse(viewModel.canPause)
        
        // Can pause when running
        await viewModel.startSession()
        XCTAssertTrue(viewModel.canPause)
        
        // Can't pause when paused
        await viewModel.pauseSession()
        XCTAssertFalse(viewModel.canPause)
        
        // Can't pause when completed
        await viewModel.resumeSession()
        mockTimer.advance(by: 1500)
        await viewModel.tick()
        XCTAssertFalse(viewModel.canPause)
    }
    
    func testCanResume() async {
        // Initially can't resume
        XCTAssertFalse(viewModel.canResume)
        
        // Can't resume when running
        await viewModel.startSession()
        XCTAssertFalse(viewModel.canResume)
        
        // Can resume when paused
        await viewModel.pauseSession()
        XCTAssertTrue(viewModel.canResume)
        
        // Can't resume when completed
        await viewModel.resumeSession()
        mockTimer.advance(by: 1500)
        await viewModel.tick()
        XCTAssertFalse(viewModel.canResume)
    }
    
    // MARK: - Edge Cases
    
    func testCannotStartMultipleSessions() async {
        // Given: Session already running
        await viewModel.startSession()
        let firstSession = viewModel.currentSession
        
        // When: Try to start another
        await viewModel.startSession()
        
        // Then: Same session (no-op)
        XCTAssertEqual(viewModel.currentSession?.id, firstSession?.id)
    }
    
    func testCannotPauseWhenIdle() async {
        // When: Try to pause without session
        await viewModel.pauseSession()
        
        // Then: Still idle
        XCTAssertEqual(viewModel.sessionState, .idle)
    }
    
    func testCannotResumeWhenIdle() async {
        // When: Try to resume without session
        await viewModel.resumeSession()
        
        // Then: Still idle
        XCTAssertEqual(viewModel.sessionState, .idle)
    }
    
    func testTimeRemainingNeverNegative() async {
        // Given: Session started
        await viewModel.startSession()
        
        // When: Advance past completion time
        mockTimer.advance(by: 2000) // More than 1500
        await viewModel.tick()
        
        // Then: Time is 0, not negative
        XCTAssertEqual(viewModel.timeRemaining, 0)
    }
}
