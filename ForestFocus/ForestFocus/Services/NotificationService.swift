//
//  NotificationService.swift
//  ForestFocus
//
//  Created by AI Assistant on 10/29/25.
//  Task: T032 - Local notification service
//

import Foundation
import UserNotifications

/// Protocol for notification operations (enables testing)
protocol NotificationServiceProtocol {
    func requestAuthorization() async throws -> Bool
    func scheduleSessionCompleteNotification(after duration: TimeInterval, identifier: String) async throws
    func cancelNotification(identifier: String)
    func cancelAllNotifications()
}

/// Service for managing local notifications
final class NotificationService: NotificationServiceProtocol {
    private let center = UNUserNotificationCenter.current()
    
    /// Request notification permission from user
    func requestAuthorization() async throws -> Bool {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted
    }
    
    /// Schedule notification for session completion
    func scheduleSessionCompleteNotification(after duration: TimeInterval, identifier: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Session Complete! 🌲"
        content.body = "Great focus! Your tree is fully grown."
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        try await center.add(request)
    }
    
    /// Cancel specific notification
    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Cancel all pending notifications
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}

/// Mock notification service for testing
final class MockNotificationService: NotificationServiceProtocol {
    var authorizationGranted = true
    var scheduledNotifications: [String: TimeInterval] = [:]
    var requestAuthorizationCalled = false
    
    func requestAuthorization() async throws -> Bool {
        requestAuthorizationCalled = true
        return authorizationGranted
    }
    
    func scheduleSessionCompleteNotification(after duration: TimeInterval, identifier: String) async throws {
        scheduledNotifications[identifier] = duration
    }
    
    func cancelNotification(identifier: String) {
        scheduledNotifications.removeValue(forKey: identifier)
    }
    
    func cancelAllNotifications() {
        scheduledNotifications.removeAll()
    }
}
