//
//  TimerViewModel.swift
//  ForestFocus
//
//  Created by AI Assistant on 10/29/25.
//  Task: T047 - Implement TimerViewModel
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class TimerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var timeRemaining: Int = 1500 // 25 minutes
    @Published var sessionState: SessionState = .idle
    @Published var growthStage: Int = 0
    @Published var isRunning: Bool = false
    @Published var currentSession: FocusSession?
    
    // MARK: - Dependencies
    
    private let modelContext: ModelContext
    private let timerService: TimerServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private var backgroundService: BackgroundServiceProtocol
    
    private var timerCancellable: AnyCancellable?
    private var sessionStartTime: TimeInterval = 0
    private var pausedTime: TimeInterval = 0
    private var totalPausedDuration: TimeInterval = 0
    
    private let sessionDuration: Int = 1500 // 25 minutes
    
    // MARK: - Initialization
    
    init(
        modelContext: ModelContext,
        timerService: TimerServiceProtocol,
        notificationService: NotificationServiceProtocol,
        backgroundService: BackgroundServiceProtocol
    ) {
        self.modelContext = modelContext
        self.timerService = timerService
        self.notificationService = notificationService
        self.backgroundService = backgroundService
        
        setupBackgroundCallbacks()
    }
    
    convenience init(modelContext: ModelContext) {
        self.init(
            modelContext: modelContext,
            timerService: TimerService(),
            notificationService: NotificationService(),
            backgroundService: BackgroundService()
        )
    }
    
    // MARK: - Public Methods
    
    func startSession() async {
        guard currentSession == nil else { return }
        
        // Request notification permission
        _ = try? await notificationService.requestAuthorization()
        
        // Create new session
        let session = FocusSession(
            startTime: Date(),
            state: SessionState.active.rawValue,
            duration: Double(sessionDuration)
        )
        
        modelContext.insert(session)
        try? modelContext.save()
        
        currentSession = session
        sessionState = .active
        isRunning = true
        sessionStartTime = timerService.currentTime()
        timeRemaining = sessionDuration
        growthStage = 0
        
        // Schedule completion notification
        try? await notificationService.scheduleSessionCompleteNotification(
            after: Double(sessionDuration),
            identifier: session.id.uuidString
        )
        
        startTimer()
    }
    
    func pauseSession() async {
        guard let session = currentSession, sessionState == .active else { return }
        
        isRunning = false
        sessionState = .paused
        pausedTime = timerService.currentTime()
        
        _ = session.updateState(to: .paused)
        try? modelContext.save()
        
        stopTimer()
    }
    
    func resumeSession() async {
        guard currentSession != nil, sessionState == .paused else { return }
        
        // Calculate pause duration
        let pauseDuration = timerService.currentTime() - pausedTime
        totalPausedDuration += pauseDuration
        
        isRunning = true
        sessionState = .active
        
        _ = currentSession?.updateState(to: .active)
        try? modelContext.save()
        
        startTimer()
    }
    
    func abandonSession() async {
        guard let session = currentSession else { return }
        
        stopTimer()
        
        // Cancel notification
        notificationService.cancelNotification(identifier: session.id.uuidString)
        
        // Update session
        _ = session.updateState(to: .abandoned)
        session.endTime = Date()
        try? modelContext.save()
        
        // Update state (keep session for verification, but mark as abandoned)
        sessionState = .abandoned
        isRunning = false
        timeRemaining = sessionDuration
        growthStage = 0
        totalPausedDuration = 0
    }
    
    func tick() async {
        guard isRunning, let session = currentSession else { return }
        
        // Calculate elapsed time
        let currentTime = timerService.currentTime()
        let elapsed = currentTime - sessionStartTime - totalPausedDuration
        let remaining = max(0, sessionDuration - Int(elapsed))
        
        timeRemaining = remaining
        
        // Update growth stage (0-5 based on progress)
        let progress = Double(sessionDuration - remaining) / Double(sessionDuration)
        growthStage = min(5, Int(progress * 5))
        
        // Check if completed
        if remaining <= 0 {
            await completeSession()
        }
    }
    
    func syncBackgroundTime(elapsed: TimeInterval) async {
        // Adjust for background time
        let remaining = max(0, timeRemaining - Int(elapsed))
        timeRemaining = remaining
        
        if remaining <= 0 {
            await completeSession()
        }
    }
    
    // MARK: - Computed Properties
    
    var formattedTimeRemaining: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progressPercentage: Double {
        let elapsed = Double(sessionDuration - timeRemaining)
        return elapsed / Double(sessionDuration)
    }
    
    var canPause: Bool {
        return sessionState == .active && isRunning
    }
    
    var canResume: Bool {
        return sessionState == .paused && !isRunning
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.tick()
                }
            }
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func completeSession() async {
        guard let session = currentSession else { return }
        
        stopTimer()
        
        // Update session
        _ = session.updateState(to: .completed)
        session.endTime = Date()
        session.duration = Double(sessionDuration)
        try? modelContext.save()
        
        // Update state
        sessionState = .completed
        isRunning = false
        timeRemaining = 0
        growthStage = 5
        
        // Keep current session visible for UI
        // It will be cleared when starting new session
    }
    
    private func setupBackgroundCallbacks() {
        var backgroundTime: Date?
        
        backgroundService.onEnterBackground = { date in
            backgroundTime = date
        }
        
        backgroundService.onEnterForeground = { [weak self] date in
            guard let self = self, let bgTime = backgroundTime else { return }
            let elapsed = date.timeIntervalSince(bgTime)
            
            Task { @MainActor in
                await self.syncBackgroundTime(elapsed: elapsed)
            }
        }
    }
}
