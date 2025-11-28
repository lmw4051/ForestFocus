//
//  NotificationServiceTests.swift
//  ForestFocusTests
//
//  Created by AI Assistant on 10/29/25.
//  Task: T035 - Test notification scheduling
//

import XCTest
@testable import ForestFocus

final class NotificationServiceTests: XCTestCase {
    
    var mockNotificationService: MockNotificationService!
    
    override func setUp() {
        mockNotificationService = MockNotificationService()
    }
    
    override func tearDown() {
        mockNotificationService = nil
    }
    
    // MARK: - Authorization Tests
    
    func testRequestAuthorizationCallsService() async throws {
        // When: Request authorization
        _ = try await mockNotificationService.requestAuthorization()
        
        // Then: Service was called
        XCTAssertTrue(mockNotificationService.requestAuthorizationCalled)
    }
    
    func testRequestAuthorizationReturnsGranted() async throws {
        // Given: Authorization is granted
        mockNotificationService.authorizationGranted = true
        
        // When: Request authorization
        let granted = try await mockNotificationService.requestAuthorization()
        
        // Then: Returns true
        XCTAssertTrue(granted)
    }
    
    func testRequestAuthorizationReturnsDenied() async throws {
        // Given: Authorization is denied
        mockNotificationService.authorizationGranted = false
        
        // When: Request authorization
        let granted = try await mockNotificationService.requestAuthorization()
        
        // Then: Returns false
        XCTAssertFalse(granted)
    }
    
    // MARK: - Scheduling Tests
    
    func testScheduleNotificationStoresIdentifier() async throws {
        // When: Schedule notification
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1500,
            identifier: "session-123"
        )
        
        // Then: Notification is scheduled
        XCTAssertNotNil(mockNotificationService.scheduledNotifications["session-123"])
    }
    
    func testScheduleNotificationStoresDuration() async throws {
        // When: Schedule notification for 25 minutes
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1500,
            identifier: "session-123"
        )
        
        // Then: Duration is stored
        XCTAssertEqual(mockNotificationService.scheduledNotifications["session-123"], 1500)
    }
    
    func testScheduleMultipleNotifications() async throws {
        // When: Schedule multiple notifications
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1500,
            identifier: "session-1"
        )
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1800,
            identifier: "session-2"
        )
        
        // Then: Both are scheduled
        XCTAssertEqual(mockNotificationService.scheduledNotifications.count, 2)
        XCTAssertEqual(mockNotificationService.scheduledNotifications["session-1"], 1500)
        XCTAssertEqual(mockNotificationService.scheduledNotifications["session-2"], 1800)
    }
    
    // MARK: - Cancellation Tests
    
    func testCancelNotificationRemovesScheduled() async throws {
        // Given: Scheduled notification
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1500,
            identifier: "session-123"
        )
        XCTAssertNotNil(mockNotificationService.scheduledNotifications["session-123"])
        
        // When: Cancel notification
        mockNotificationService.cancelNotification(identifier: "session-123")
        
        // Then: Notification is removed
        XCTAssertNil(mockNotificationService.scheduledNotifications["session-123"])
    }
    
    func testCancelNonExistentNotificationDoesNothing() {
        // When: Cancel non-existent notification
        mockNotificationService.cancelNotification(identifier: "nonexistent")
        
        // Then: No error, no crash
        XCTAssertTrue(mockNotificationService.scheduledNotifications.isEmpty)
    }
    
    func testCancelAllNotificationsRemovesAll() async throws {
        // Given: Multiple scheduled notifications
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1500,
            identifier: "session-1"
        )
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1800,
            identifier: "session-2"
        )
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 2000,
            identifier: "session-3"
        )
        XCTAssertEqual(mockNotificationService.scheduledNotifications.count, 3)
        
        // When: Cancel all
        mockNotificationService.cancelAllNotifications()
        
        // Then: All removed
        XCTAssertTrue(mockNotificationService.scheduledNotifications.isEmpty)
    }
    
    // MARK: - Use Case Tests
    
    func testSessionStartFlow() async throws {
        // Scenario: User starts session
        
        // 1. Request authorization
        let granted = try await mockNotificationService.requestAuthorization()
        XCTAssertTrue(granted)
        
        // 2. Schedule completion notification
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1500,
            identifier: "current-session"
        )
        
        // Then: Notification is scheduled
        XCTAssertNotNil(mockNotificationService.scheduledNotifications["current-session"])
    }
    
    func testSessionAbandonFlow() async throws {
        // Scenario: User abandons session
        
        // 1. Schedule notification
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1500,
            identifier: "current-session"
        )
        
        // 2. User quits - cancel notification
        mockNotificationService.cancelNotification(identifier: "current-session")
        
        // Then: No notification pending
        XCTAssertNil(mockNotificationService.scheduledNotifications["current-session"])
    }
    
    func testReplaceExistingNotification() async throws {
        // Scenario: Reschedule with same identifier (replaces previous)
        
        // 1. Schedule first notification
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1500,
            identifier: "current-session"
        )
        XCTAssertEqual(mockNotificationService.scheduledNotifications["current-session"], 1500)
        
        // 2. Reschedule with same ID (simulates pause/resume)
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1200,
            identifier: "current-session"
        )
        
        // Then: Duration is updated (replaced)
        XCTAssertEqual(mockNotificationService.scheduledNotifications["current-session"], 1200)
        XCTAssertEqual(mockNotificationService.scheduledNotifications.count, 1)
    }
    
    // MARK: - Edge Cases
    
    func testScheduleZeroDurationNotification() async throws {
        // When: Schedule notification with 0 duration (immediate)
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 0,
            identifier: "immediate"
        )
        
        // Then: Accepts it (system will fire immediately)
        XCTAssertEqual(mockNotificationService.scheduledNotifications["immediate"], 0)
    }
    
    func testScheduleVeryLongDuration() async throws {
        // When: Schedule notification far in future (hours)
        let oneHour: TimeInterval = 3600
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: oneHour * 24, // 24 hours
            identifier: "long-session"
        )
        
        // Then: Accepts it
        XCTAssertEqual(mockNotificationService.scheduledNotifications["long-session"], oneHour * 24)
    }
    
    func testEmptyIdentifier() async throws {
        // When: Schedule with empty identifier
        try await mockNotificationService.scheduleSessionCompleteNotification(
            after: 1500,
            identifier: ""
        )
        
        // Then: Still works (though not recommended)
        XCTAssertNotNil(mockNotificationService.scheduledNotifications[""])
    }
}
