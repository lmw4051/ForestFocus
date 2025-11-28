//
//  ForestGridView.swift
//  ForestFocus
//
//  Created by AI Assistant on 10/29/25.
//

import SwiftUI
import SwiftData

struct ForestGridView: View {
    @Query(
        filter: #Predicate<FocusSession> { $0.state == "completed" },
        sort: \FocusSession.endTime,
        order: .reverse
    )
    var completedSessions: [FocusSession]
    
    var body: some View {
        NavigationStack {
            Group {
                if completedSessions.isEmpty {
                    EmptyForestView()
                } else {
                    ScrollView {
                        Text("Forest grid coming soon...")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .navigationTitle("My Forest")
        }
    }
}

struct EmptyForestView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 80))
                .foregroundColor(.green.opacity(0.3))
            
            Text("Plant your first tree")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start a 25-minute focus session to grow your forest")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    ForestGridView()
        .modelContainer(for: FocusSession.self, inMemory: true)
}
