//
//  ForestFocusApp.swift
//  ForestFocus
//
//  Created by David Lee on 10/30/25.
//

import SwiftUI
import SwiftData

@main
struct ForestFocusApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: FocusSession.self)
    }
}
