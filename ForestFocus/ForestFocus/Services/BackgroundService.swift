//
//  BackgroundService.swift
//  ForestFocus
//
//  Created by AI Assistant on 10/29/25.
//  Task: T033 - Background time tracking service
//

import Foundation
import SwiftUI
import Combine

/// Protocol for background state management
protocol BackgroundServiceProtocol {
    var onEnterBackground: ((Date) -> Void)? { get set }
    var onEnterForeground: ((Date) -> Void)? { get set }
}

/// Service for tracking app background/foreground transitions
final class BackgroundService: BackgroundServiceProtocol, ObservableObject {
    @Published private(set) var isInBackground = false
    
    var onEnterBackground: ((Date) -> Void)?
    var onEnterForeground: ((Date) -> Void)?
    
    private var backgroundTime: Date?
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        let now = Date()
        backgroundTime = now
        isInBackground = true
        onEnterBackground?(now)
    }
    
    @objc private func appWillEnterForeground() {
        let now = Date()
        isInBackground = false
        onEnterForeground?(now)
        backgroundTime = nil
    }
    
    /// Calculate time spent in background
    func timeInBackground() -> TimeInterval? {
        guard let backgroundTime = backgroundTime else { return nil }
        return Date().timeIntervalSince(backgroundTime)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

/// Mock background service for testing
final class MockBackgroundService: BackgroundServiceProtocol {
    var onEnterBackground: ((Date) -> Void)?
    var onEnterForeground: ((Date) -> Void)?
    
    var isInBackground = false
    
    /// Simulate entering background
    func simulateEnterBackground() {
        isInBackground = true
        onEnterBackground?(Date())
    }
    
    /// Simulate entering foreground
    func simulateEnterForeground() {
        isInBackground = false
        onEnterForeground?(Date())
    }
}
