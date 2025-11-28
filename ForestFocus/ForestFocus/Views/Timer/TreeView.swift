//
//  TreeView.swift
//  ForestFocus
//
//  Created by AI Assistant on 10/29/25.
//  Task: T055-T058 - Tree animation with 5 growth stages
//

import SwiftUI

struct TreeView: View {
    let growthStage: Int
    let sessionState: SessionState
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let treeSymbols = [
        "circle.fill",           // Stage 0: Seed
        "leaf.fill",             // Stage 1: Sprout
        "leaf.circle.fill",      // Stage 2: Sapling
        "tree",                  // Stage 3: Young tree
        "tree.fill",             // Stage 4: Mature tree
        "tree.fill"              // Stage 5: Full grown (same as 4, but we'll add flourish)
    ]
    
    private let treeColors: [Color] = [
        .brown,                  // Stage 0: Seed
        .green.opacity(0.5),    // Stage 1: Light green
        .green.opacity(0.7),    // Stage 2: Medium green
        .green,                  // Stage 3: Green
        .green,                  // Stage 4: Dark green
        .green                   // Stage 5: Full green
    ]
    
    var body: some View {
        ZStack {
            // Main tree
            Image(systemName: currentSymbol)
                .font(.system(size: treeSize))
                .foregroundStyle(currentColor)
                .scaleEffect(scale)
                .opacity(opacity)
                .animation(animation, value: growthStage)
                .animation(animation, value: sessionState)
            
            // Success flourish for completed sessions
            if sessionState == .completed && !reduceMotion {
                ForEach(0..<8, id: \.self) { index in
                    Image(systemName: "sparkle")
                        .font(.system(size: 20))
                        .foregroundStyle(.yellow)
                        .offset(
                            x: cos(Double(index) * .pi / 4) * 80,
                            y: sin(Double(index) * .pi / 4) * 80
                        )
                        .opacity(sessionState == .completed ? 1 : 0)
                        .scaleEffect(sessionState == .completed ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                                .delay(Double(index) * 0.05),
                            value: sessionState
                        )
                }
            }
            
            // Wilted state for abandoned sessions
            if sessionState == .abandoned {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.red.opacity(0.8))
                    .offset(y: -60)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityValue(accessibilityValue)
    }
    
    // MARK: - Computed Properties
    
    private var currentSymbol: String {
        let stage = min(max(growthStage, 0), 5)
        return treeSymbols[stage]
    }
    
    private var currentColor: Color {
        let stage = min(max(growthStage, 0), 5)
        
        if sessionState == .abandoned {
            return .gray.opacity(0.5)
        }
        
        return treeColors[stage]
    }
    
    private var treeSize: CGFloat {
        switch growthStage {
        case 0: return 40
        case 1: return 60
        case 2: return 90
        case 3: return 120
        case 4: return 150
        case 5: return 180
        default: return 40
        }
    }
    
    private var scale: CGFloat {
        if sessionState == .abandoned {
            return 0.8
        }
        return 1.0
    }
    
    private var opacity: Double {
        if sessionState == .abandoned {
            return 0.5
        }
        return 1.0
    }
    
    private var animation: Animation? {
        if reduceMotion {
            return .linear(duration: 0.3)
        }
        
        switch sessionState {
        case .active, .paused:
            return .spring(response: 0.6, dampingFraction: 0.7)
        case .completed:
            return .spring(response: 0.5, dampingFraction: 0.6)
        case .abandoned:
            return .easeInOut(duration: 0.3)
        case .idle:
            return .easeInOut(duration: 0.2)
        }
    }
    
    // MARK: - Accessibility
    
    private var accessibilityDescription: String {
        switch sessionState {
        case .idle:
            return "Tree waiting to be planted"
        case .active, .paused:
            return "Tree growing, stage \(growthStage) of 5"
        case .completed:
            return "Tree fully grown"
        case .abandoned:
            return "Tree wilted"
        }
    }
    
    private var accessibilityValue: String {
        let percentage = Int(Double(growthStage) / 5.0 * 100)
        return "\(percentage) percent complete"
    }
}

// MARK: - Previews

#Preview("Growth Stages") {
    VStack(spacing: 20) {
        ForEach(0...5, id: \.self) { stage in
            HStack {
                Text("Stage \(stage)")
                    .frame(width: 80, alignment: .leading)
                TreeView(growthStage: stage, sessionState: .active)
            }
        }
    }
    .padding()
}

#Preview("States") {
    VStack(spacing: 30) {
        VStack {
            Text("Idle")
            TreeView(growthStage: 0, sessionState: .idle)
        }
        
        VStack {
            Text("Active (Stage 3)")
            TreeView(growthStage: 3, sessionState: .active)
        }
        
        VStack {
            Text("Completed")
            TreeView(growthStage: 5, sessionState: .completed)
        }
        
        VStack {
            Text("Abandoned")
            TreeView(growthStage: 3, sessionState: .abandoned)
        }
    }
    .padding()
}

#Preview("Animation") {
    TreeAnimationPreview()
}

// Helper for animation preview
private struct TreeAnimationPreview: View {
    @State private var stage = 0
    @State private var state: SessionState = .active
    
    var body: some View {
        VStack(spacing: 40) {
            TreeView(growthStage: stage, sessionState: state)
            
            HStack {
                Button("Previous") {
                    if stage > 0 {
                        stage -= 1
                    }
                }
                .disabled(stage == 0)
                
                Button("Next") {
                    if stage < 5 {
                        stage += 1
                    }
                }
                .disabled(stage == 5)
            }
            .buttonStyle(.bordered)
            
            Picker("State", selection: $state) {
                Text("Idle").tag(SessionState.idle)
                Text("Active").tag(SessionState.active)
                Text("Paused").tag(SessionState.paused)
                Text("Completed").tag(SessionState.completed)
                Text("Abandoned").tag(SessionState.abandoned)
            }
            .pickerStyle(.segmented)
            .padding()
        }
        .padding()
    }
}
