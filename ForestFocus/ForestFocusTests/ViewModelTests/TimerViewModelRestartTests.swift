//
//  TimerViewModelRestartTests.swift
//  ForestFocusTests
//
//  Created by AI Assistant on 11/30/25.
//

import XCTest
import Combine
import SwiftData
@testable import ForestFocus

@MainActor
final class TimerViewModelRestartTests: XCTestCase {
    
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

    func testCanStartNewSessionAfterAbandon() async {
        // Given: Session started and then abandoned
        await viewModel.startSession()
        let firstSessionId = viewModel.currentSession?.id
        
        await viewModel.abandonSession()
        XCTAssertEqual(viewModel.sessionState, .abandoned)
        
        // When: Start session again (Try Again)
        await viewModel.startSession()
        
        // Then: New session created and active
        XCTAssertNotEqual(viewModel.currentSession?.id, firstSessionId)
        XCTAssertEqual(viewModel.sessionState, .active)
        XCTAssertTrue(viewModel.isRunning)
    }

    func testCanStartNewSessionAfterComplete() async {
        // Given: Session started and then completed
        await viewModel.startSession()
        let firstSessionId = viewModel.currentSession?.id
        
        // Fast forward to completion
        mockTimer.advance(by: 1500)
        await viewModel.tick()
        XCTAssertEqual(viewModel.sessionState, .completed)
        
        // When: Start session again (Plant Another)
        await viewModel.startSession()
        
        // Then: New session created and active
        XCTAssertNotEqual(viewModel.currentSession?.id, firstSessionId)
        XCTAssertEqual(viewModel.sessionState, .active)
        XCTAssertTrue(viewModel.isRunning)
    }
}
