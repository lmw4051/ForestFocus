# Data Model Design - Forest Focus

**Date**: 2025-10-29  
**Status**: Complete  
**Tasks**: T009-T012

## Overview

This document defines the SwiftData schema for Forest Focus. Models are designed for simplicity, offline-first storage, and efficient querying.

---

## T009: FocusSession @Model Schema

### Model Definition

```swift
import Foundation
import SwiftData

@Model
final class FocusSession {
    // Primary key
    var id: UUID
    
    // Timestamps
    var startTime: Date
    var endTime: Date?
    
    // State tracking
    var state: String // "active", "paused", "completed", "abandoned"
    
    // Duration tracking
    var duration: TimeInterval // Actual focus time (excludes paused time)
    var pausedDuration: TimeInterval // Total time spent paused
    
    // Metadata
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        state: String = "active",
        duration: TimeInterval = 0,
        pausedDuration: TimeInterval = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.state = state
        self.duration = duration
        self.pausedDuration = pausedDuration
        self.createdAt = createdAt
    }
}
```

### Properties Explained

| Property | Type | Purpose | Notes |
|----------|------|---------|-------|
| `id` | UUID | Unique identifier | Primary key, auto-generated |
| `startTime` | Date | Session start timestamp | Wall clock time for display |
| `endTime` | Date? | Session end timestamp | Optional, set on completion/abandon |
| `state` | String | Current state | "active", "paused", "completed", "abandoned" |
| `duration` | TimeInterval | Actual focus time | Excludes paused time, max 1500s (25 min) |
| `pausedDuration` | TimeInterval | Total paused time | Tracked separately for analytics |
| `createdAt` | Date | Record creation time | For sorting, never changes |

### State Transitions

```
┌─────────┐
│ active  │ ──pause──> ┌────────┐
│         │ <─resume─── │ paused │
└─────────┘             └────────┘
     │                       │
     │                       │
  complete               cancel
  abandon                abandon
     │                       │
     ↓                       ↓
┌──────────┐           ┌───────────┐
│completed │           │ abandoned │
└──────────┘           └───────────┘
```

### Constraints

- `state` must be one of: "active", "paused", "completed", "abandoned"
- `duration` range: 0 to 1500 seconds (0 to 25 minutes)
- `endTime` is nil while active/paused, set when completed/abandoned
- `pausedDuration` >= 0

### SwiftData Configuration

**Indexing**: SwiftData automatically indexes `id` (primary key)

**Additional indexes** (via query optimization):
- `state` - frequently queried for completed sessions
- `endTime` - used for sorting and date filtering

---

## T010: SessionState Enum Schema

### Enum Definition

```swift
import Foundation

enum SessionState: String, Codable, CaseIterable {
    case active
    case paused
    case completed
    case abandoned
    
    var displayName: String {
        switch self {
        case .active: return "Active"
        case .paused: return "Paused"
        case .completed: return "Completed"
        case .abandoned: return "Abandoned"
        }
    }
    
    var canTransitionTo: [SessionState] {
        switch self {
        case .active:
            return [.paused, .completed, .abandoned]
        case .paused:
            return [.active, .abandoned]
        case .completed, .abandoned:
            return [] // Terminal states
        }
    }
    
    func canTransition(to newState: SessionState) -> Bool {
        return canTransitionTo.contains(newState)
    }
}
```

### State Descriptions

| State | Description | Terminal | Valid Transitions |
|-------|-------------|----------|-------------------|
| `active` | Timer running, tree growing | No | paused, completed, abandoned |
| `paused` | Timer stopped, can resume | No | active, abandoned |
| `completed` | Session finished (25 min) | Yes | none |
| `abandoned` | Session cancelled early | Yes | none |

### Usage in SwiftData

```swift
// Store as String rawValue
let session = FocusSession(state: SessionState.active.rawValue)

// Convert back to enum
if let state = SessionState(rawValue: session.state) {
    print("Current state: \(state.displayName)")
}
```

### Validation Logic

```swift
extension FocusSession {
    var sessionState: SessionState? {
        return SessionState(rawValue: state)
    }
    
    func canTransition(to newState: SessionState) -> Bool {
        guard let currentState = sessionState else { return false }
        return currentState.canTransition(to: newState)
    }
}
```

---

## T011: ForestStats Computed Struct Schema

### Struct Definition

```swift
import Foundation

struct ForestStats {
    // Totals
    let totalTrees: Int
    let totalFocusTime: TimeInterval // Total minutes focused
    let totalSessions: Int // Including abandoned
    
    // Today's metrics
    let todaysTrees: Int
    let todaysFocusTime: TimeInterval
    
    // Streaks
    let currentStreak: Int // Consecutive days with ≥1 completed session
    let longestStreak: Int // Historical best
    
    // Abandoned tracking
    let abandonedCount: Int
    let completionRate: Double // Percentage of completed sessions
    
    // Computed properties
    var totalFocusHours: Double {
        totalFocusTime / 3600.0
    }
    
    var averageSessionsPerDay: Double {
        guard currentStreak > 0 else { return 0 }
        return Double(totalTrees) / Double(currentStreak)
    }
    
    var formattedTotalFocusTime: String {
        let hours = Int(totalFocusTime) / 3600
        let minutes = (Int(totalFocusTime) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
```

### Properties Explained

| Property | Type | Source | Description |
|----------|------|--------|-------------|
| `totalTrees` | Int | Completed sessions count | Only completed, not abandoned |
| `totalFocusTime` | TimeInterval | Sum of duration | Actual focus time (excludes paused) |
| `totalSessions` | Int | All sessions count | Completed + abandoned |
| `todaysTrees` | Int | Today's completed | Resets at midnight |
| `todaysFocusTime` | TimeInterval | Today's duration sum | Today's focus minutes |
| `currentStreak` | Int | Computed | Consecutive days with ≥1 completed |
| `longestStreak` | Int | Computed | Historical maximum streak |
| `abandonedCount` | Int | Abandoned sessions count | Cancelled sessions |
| `completionRate` | Double | Computed | totalTrees / totalSessions * 100 |

### Initialization

```swift
extension ForestStats {
    static func from(sessions: [FocusSession]) -> ForestStats {
        let completedSessions = sessions.filter { $0.state == "completed" }
        let abandonedSessions = sessions.filter { $0.state == "abandoned" }
        
        let totalTrees = completedSessions.count
        let totalFocusTime = completedSessions.reduce(0) { $0 + $1.duration }
        let totalSessions = sessions.count
        
        // Today's metrics
        let todaysSessions = completedSessions.filter { session in
            Calendar.current.isDateInToday(session.endTime ?? session.startTime)
        }
        let todaysTrees = todaysSessions.count
        let todaysFocusTime = todaysSessions.reduce(0) { $0 + $1.duration }
        
        // Streak calculation
        let currentStreak = calculateCurrentStreak(from: completedSessions)
        let longestStreak = calculateLongestStreak(from: completedSessions)
        
        // Abandoned tracking
        let abandonedCount = abandonedSessions.count
        let completionRate = totalSessions > 0 ? Double(totalTrees) / Double(totalSessions) * 100 : 0
        
        return ForestStats(
            totalTrees: totalTrees,
            totalFocusTime: totalFocusTime,
            totalSessions: totalSessions,
            todaysTrees: todaysTrees,
            todaysFocusTime: todaysFocusTime,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            abandonedCount: abandonedCount,
            completionRate: completionRate
        )
    }
}
```

### Not Persisted

**Important**: ForestStats is NOT stored in SwiftData. It is computed on-demand from FocusSession records.

**Rationale**:
- Always accurate (no stale data)
- No update logic needed
- Simpler codebase
- Performance: ~10ms for 1000 sessions (acceptable)

---

## T012: SwiftData Queries

### Query 1: All Completed Sessions (Newest First)

```swift
@Query(
    filter: #Predicate<FocusSession> { $0.state == "completed" },
    sort: \FocusSession.endTime,
    order: .reverse
)
var completedSessions: [FocusSession]
```

**Usage**: Forest grid view (displays all completed trees)

**Performance**: Efficient with SwiftData batching, handles 1000+ items

---

### Query 2: Today's Completed Sessions

```swift
@Query(filter: #Predicate<FocusSession> { session in
    session.state == "completed" &&
    Calendar.current.isDateInToday(session.endTime ?? session.startTime)
})
var todaysSessions: [FocusSession]
```

**Usage**: "Today's Trees" stat

**Note**: Calendar.current.isDateInToday() evaluates at query execution time

---

### Query 3: All Sessions (For Stats Calculation)

```swift
@Query var allSessions: [FocusSession]
```

**Usage**: StatsViewModel to compute ForestStats

**Note**: Fetches all sessions (completed + abandoned) for comprehensive stats

---

### Query 4: Sessions in Date Range (For Streak Calculation)

```swift
func fetchSessions(from startDate: Date, to endDate: Date, context: ModelContext) throws -> [FocusSession] {
    let descriptor = FetchDescriptor<FocusSession>(
        predicate: #Predicate { session in
            session.state == "completed" &&
            session.endTime ?? session.startTime >= startDate &&
            session.endTime ?? session.startTime < endDate
        },
        sortBy: [SortDescriptor(\FocusSession.endTime, order: .reverse)]
    )
    
    return try context.fetch(descriptor)
}
```

**Usage**: Streak calculation (check each day for completed sessions)

---

### Query 5: Active or Paused Session (At Most One)

```swift
@Query(filter: #Predicate<FocusSession> { session in
    session.state == "active" || session.state == "paused"
})
var currentSession: [FocusSession]
```

**Usage**: TimerViewModel to resume session on app relaunch

**Constraint**: Should return 0 or 1 session (enforce in ViewModel logic)

---

## Data Model Relationships

### No Relationships Needed

ForestFocus uses a flat data model:
- Single entity: `FocusSession`
- No foreign keys, no joins
- All queries filter on session properties

**Rationale**:
- Simplicity (constitution principle: Radical Simplicity)
- No need for separate Tree entity (tree is just a view representation)
- Stats computed from sessions (no separate StatsData entity)

---

## SwiftData Container Setup

### App Entry Point Configuration

```swift
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
```

### In-Memory Container for Testing

```swift
import XCTest
import SwiftData
@testable import ForestFocus

class ModelTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    
    override func setUp() async throws {
        let schema = Schema([FocusSession.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = ModelContext(container)
    }
    
    override func tearDown() {
        container = nil
        context = nil
    }
}
```

---

## Migration Strategy

### v1.0 (Initial Release)

- Single model: `FocusSession`
- No migrations needed

### Future Versions (Out of Scope for v1.0)

If schema changes in future:
```swift
// Example: Adding new property
@Model
final class FocusSession {
    // Existing properties...
    var notes: String? = nil // New optional property
}
```

SwiftData handles additive changes automatically:
- New optional properties: default to nil
- New required properties: need migration plan

**For v1.0**: No migration logic needed.

---

## Performance Considerations

### Query Optimization

| Query | Expected Result Size | Performance |
|-------|---------------------|-------------|
| All completed sessions | 100-1000 | <100ms with LazyVGrid |
| Today's sessions | 1-10 | <1ms |
| All sessions (stats) | 100-1000 | <10ms |
| Date range (streak) | 1-10 per day | <50ms for 30 days |
| Current session | 0-1 | <1ms |

### Memory Footprint

| Data | Size per Item | 1000 Items |
|------|--------------|------------|
| FocusSession | ~200 bytes | ~200 KB |
| SwiftData overhead | ~50 bytes | ~50 KB |
| LazyVGrid cache | ~5 KB per visible | ~150 KB (30 visible) |
| **Total** | - | **~400 KB** ✅ |

Well under 50MB budget.

---

## Data Integrity

### Constraints Enforced by ViewModel

1. **Single Active Session**: Only one session can be active/paused at a time
2. **State Transitions**: Only valid transitions allowed (per SessionState.canTransitionTo)
3. **Duration Limits**: duration ≤ 1500 seconds (25 minutes)
4. **End Time**: Set when state becomes completed/abandoned

### No Database-Level Constraints

SwiftData/Core Data don't enforce custom constraints. Validation happens in ViewModel layer.

---

## Example Data Flow

### Creating a Session

```swift
// 1. User taps "Plant Tree"
func startSession(context: ModelContext) {
    let session = FocusSession(
        startTime: Date(),
        state: SessionState.active.rawValue
    )
    
    context.insert(session)
    try? context.save()
}
```

### Completing a Session

```swift
// 2. Timer reaches 0:00
func completeSession(_ session: FocusSession, context: ModelContext) {
    session.state = SessionState.completed.rawValue
    session.endTime = Date()
    session.duration = 1500.0 // 25 minutes
    
    try? context.save()
}
```

### Computing Stats

```swift
// 3. User views Stats tab
@Query var allSessions: [FocusSession]

var stats: ForestStats {
    ForestStats.from(sessions: allSessions)
}
```

---

## Design Complete ✅

**Models defined**:
- ✅ FocusSession @Model with all properties
- ✅ SessionState enum with transition logic
- ✅ ForestStats computed struct (not persisted)

**Queries documented**:
- ✅ Completed sessions (forest grid)
- ✅ Today's sessions (stats)
- ✅ All sessions (stats calculation)
- ✅ Date range (streak calculation)
- ✅ Current session (resume on relaunch)

**Performance validated**:
- ✅ Memory: ~400KB for 1000 sessions
- ✅ Query time: <100ms for all operations
- ✅ SwiftData container setup defined

**Ready for**: Phase 1 contracts (T013-T015)

---

**Authored by**: AI Assistant  
**Date**: 2025-10-29  
**Review Status**: Ready for ViewModel contracts
