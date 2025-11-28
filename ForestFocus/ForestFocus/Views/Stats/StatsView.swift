//
//  StatsView.swift
//  ForestFocus
//
//  Created by AI Assistant on 10/29/25.
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Query var allSessions: [FocusSession]
    
    var stats: ForestStats {
        ForestStats.from(sessions: allSessions)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    StatRow(
                        icon: "leaf.fill",
                        label: "Total Trees",
                        value: "\(stats.totalTrees)",
                        color: .green
                    )
                    
                    StatRow(
                        icon: "clock.fill",
                        label: "Total Focus Time",
                        value: stats.formattedTotalFocusTime,
                        color: .blue
                    )
                }
                
                Section("Today") {
                    StatRow(
                        icon: "calendar",
                        label: "Today's Trees",
                        value: "\(stats.todaysTrees)",
                        color: .orange
                    )
                }
                
                Section("Streaks") {
                    StatRow(
                        icon: "flame.fill",
                        label: "Current Streak",
                        value: "\(stats.currentStreak) day\(stats.currentStreak == 1 ? "" : "s")",
                        color: .red
                    )
                }
                
                Section("Performance") {
                    StatRow(
                        icon: "chart.bar.fill",
                        label: "Completion Rate",
                        value: "\(Int(stats.completionRate))%",
                        color: .purple
                    )
                    
                    StatRow(
                        icon: "xmark.circle.fill",
                        label: "Abandoned",
                        value: "\(stats.abandonedCount)",
                        color: .gray
                    )
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    StatsView()
        .modelContainer(for: FocusSession.self, inMemory: true)
}
