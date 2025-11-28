//
//  ContentView.swift
//  ForestFocus
//
//  Created by David Lee on 10/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            TimerView(modelContext: modelContext)
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
            
            ForestGridView()
                .tabItem {
                    Label("Forest", systemImage: "leaf.fill")
                }
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FocusSession.self, inMemory: true)
}
