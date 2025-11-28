//
//  TimerView.swift
//  ForestFocus
//
//  Created by AI Assistant on 10/29/25.
//  Task: T059-T061 - Wire up TimerViewModel
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: TimerViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: TimerViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // Tree with growth animation
                TreeView(
                    growthStage: viewModel.growthStage,
                    sessionState: viewModel.sessionState
                )
                .frame(height: 200)
                
                // Countdown timer
                Text(viewModel.formattedTimeRemaining)
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundStyle(timerColor)
                    .accessibilityLabel("Time remaining")
                    .accessibilityValue(viewModel.formattedTimeRemaining)
                
                // Action buttons
                HStack(spacing: 20) {
                    if viewModel.sessionState == .idle {
                        // Start button
                        Button {
                            Task {
                                await viewModel.startSession()
                            }
                        } label: {
                            Label("Plant Tree", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .accessibilityLabel("Start focus session")
                        .accessibilityHint("Begins a 25-minute focus session")
                    } else if viewModel.sessionState == .active {
                        // Pause button
                        Button {
                            Task {
                                await viewModel.pauseSession()
                            }
                        } label: {
                            Label("Pause", systemImage: "pause.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .accessibilityLabel("Pause focus session")
                        
                        // Abandon button
                        Button(role: .destructive) {
                            Task {
                                await viewModel.abandonSession()
                            }
                        } label: {
                            Label("Give Up", systemImage: "xmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .accessibilityLabel("Abandon focus session")
                        .accessibilityHint("Cancels the current session and kills the tree")
                    } else if viewModel.sessionState == .paused {
                        // Resume button
                        Button {
                            Task {
                                await viewModel.resumeSession()
                            }
                        } label: {
                            Label("Resume", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .accessibilityLabel("Resume focus session")
                        
                        // Abandon button
                        Button(role: .destructive) {
                            Task {
                                await viewModel.abandonSession()
                            }
                        } label: {
                            Label("Give Up", systemImage: "xmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .accessibilityLabel("Abandon focus session")
                    } else if viewModel.sessionState == .completed {
                        // New session button
                        Button {
                            Task {
                                await viewModel.startSession()
                            }
                        } label: {
                            Label("Plant Another", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .accessibilityLabel("Start new focus session")
                    } else if viewModel.sessionState == .abandoned {
                        // Try again button
                        Button {
                            Task {
                                await viewModel.startSession()
                            }
                        } label: {
                            Label("Try Again", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .accessibilityLabel("Start new focus session")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Focus Timer")
        }
    }
    
    // MARK: - Computed Properties
    
    private var timerColor: Color {
        switch viewModel.sessionState {
        case .idle:
            return .primary
        case .active:
            return .green
        case .paused:
            return .orange
        case .completed:
            return .green
        case .abandoned:
            return .red
        }
    }
}

#Preview("Idle") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FocusSession.self, configurations: config)
    
    return TimerView(modelContext: container.mainContext)
}

#Preview("Active") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: FocusSession.self, configurations: config)
    let view = TimerView(modelContext: container.mainContext)
    
    Task {
        // Simulate active session
    }
    
    return view
}
