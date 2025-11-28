# TimerViewModel Contract

**Date**: 2025-10-29  
**Task**: T013  
**Purpose**: Define the contract between TimerView and TimerViewModel for session management.

---

## Overview

TimerViewModel is the central business logic controller for focus sessions. It manages:
- Timer countdown with Combine
- Session state machine (active, paused, completed, abandoned)
- Tree growth stages (1-5)
- Background time synchronization
- SwiftData persistence
- Notification scheduling

---

## Inputs (View → ViewModel)

### Methods

```swift
func startSession()
```
**Precondition**: No active or paused session exists  
**Effect**: 
- Creates new FocusSession in "active" state
- Initializes timer at 25:00 (1500 seconds)
- Starts Combine timer (1-second interval)
- Schedules completion notification (25 minutes)
- Sets tree stage to 1
- Captures start timestamp (CACurrentMediaTime)

**Postcondition**: 
- `currentState` = .active
- `remainingTime` = 1500.0
- `treeStage` = 1
- Session persisted to SwiftData

---

```swift
func pauseSession()
```
**Precondition**: `currentState` == .active  
**Effect**:
- Cancels Combine timer
- Transitions state to "paused"
- Captures pause timestamp
- Updates session.pausedDuration

**Postcondition**:
- `currentState` = .paused
- Timer stopped (no countdown)
- `remainingTime` unchanged

---

```swift
func resumeSession()
```
**Precondition**: `currentState` == .paused  
**Effect**:
- Restarts Combine timer from `remainingTime`
- Transitions state to "active"
- Updates start timestamp (accounting for paused time)

**Postcondition**:
- `currentState` = .active
- Timer resumes countdown from previous `remainingTime`

---

```swift
func cancelSession()
```
**Precondition**: `currentState` == .active || .paused  
**Effect**:
- Cancels Combine timer
- Transitions state to "abandoned"
- Sets endTime to now
- Persists abandoned session
- Cancels scheduled notification

**Postcondition**:
- `currentState` = .abandoned
- Session saved with state "abandoned"
- Timer cancelled
- Notification cancelled

---

```swift
func handleBackground()
```
**Precondition**: Session is active  
**Effect**:
- Captures background timestamp (CACurrentMediaTime)
- Pauses Combine timer (iOS automatically pauses)

**Postcondition**:
- Background timestamp stored
- Timer paused (by system)

---

```swift
func handleForeground()
```
**Precondition**: Session was active when backgrounded  
**Effect**:
- Calculates elapsed time (current - background timestamp)
- Updates `remainingTime` -= elapsed
- Updates `treeStage` based on total elapsed
- If remainingTime <= 0, completes session
- Restarts Combine timer if session still active

**Postcondition**:
- `remainingTime` synced with actual elapsed time
- `treeStage` reflects current progress
- Session completed if time expired in background

---

## Outputs (ViewModel → View)

### Published Properties

```swift
@Published var remainingTime: TimeInterval
```
**Type**: TimeInterval (seconds)  
**Range**: 0.0 to 1500.0  
**Format**: Seconds (View formats to MM:SS)  
**Updates**: Every 1 second while active  
**Example**: 1320.0 (22 minutes remaining)

---

```swift
@Published var currentState: SessionState
```
**Type**: SessionState enum  
**Values**: .active, .paused, .completed, .abandoned  
**Updates**: On state transitions  
**Usage**: View shows different buttons based on state

---

```swift
@Published var treeStage: Int
```
**Type**: Int  
**Range**: 1 to 5  
**Mapping**:
- Stage 1: 25:00 - 20:01 (0-5 min elapsed)
- Stage 2: 20:00 - 15:01 (5-10 min elapsed)
- Stage 3: 15:00 - 10:01 (10-15 min elapsed)
- Stage 4: 10:00 - 5:01 (15-20 min elapsed)
- Stage 5: 5:00 - 0:00 (20-25 min elapsed)

**Updates**: Every 5 minutes during active session  
**Usage**: TreeView displays corresponding visual

---

```swift
@Published var isSessionActive: Bool
```
**Type**: Bool  
**Derived from**: `currentState == .active`  
**Usage**: View enables/disables controls

---

## Side Effects

### SwiftData Persistence

**On startSession()**:
```swift
let session = FocusSession(
    startTime: Date(),
    state: SessionState.active.rawValue
)
context.insert(session)
try context.save()
```

**On completeSession()**:
```swift
session.state = SessionState.completed.rawValue
session.endTime = Date()
session.duration = 1500.0
try context.save()
```

**On cancelSession()**:
```swift
session.state = SessionState.abandoned.rawValue
session.endTime = Date()
session.duration = 1500.0 - remainingTime // Partial duration
try context.save()
```

---

### Notification Scheduling

**On startSession()**:
```swift
await notificationService.scheduleNotification(
    identifier: "sessionComplete",
    in: 1500.0, // 25 minutes
    title: "Tree planted!",
    body: "Great focus session!"
)
```

**On cancelSession() or handleForeground() (if completed)**:
```swift
notificationService.cancelNotification(identifier: "sessionComplete")
```

---

### Combine Timer Lifecycle

**Start**:
```swift
timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
    .autoconnect()
    .sink { [weak self] _ in
        self?.updateTimer()
    }
```

**Stop**:
```swift
timerCancellable?.cancel()
timerCancellable = nil
```

---

## Dependencies

### Injected Services

```swift
class TimerViewModel: ObservableObject {
    private let context: ModelContext
    private let notificationService: NotificationService
    private let backgroundService: BackgroundService
    
    init(
        context: ModelContext,
        notificationService: NotificationService = .shared,
        backgroundService: BackgroundService = .shared
    ) {
        self.context = context
        self.notificationService = notificationService
        self.backgroundService = backgroundService
    }
}
```

---

## State Machine

```
┌─────────────┐
│   No Session │
│   (initial)  │
└──────┬───────┘
       │ startSession()
       ↓
┌─────────────┐     pauseSession()     ┌─────────────┐
│   ACTIVE    │ ───────────────────→   │   PAUSED    │
│ (timer runs)│ ←───────────────────   │(timer stops)│
└─────────────┘     resumeSession()    └─────────────┘
       │                                       │
       │ completeSession()                    │
       │ (time reaches 0)                     │
       │                                      │ cancelSession()
       │                                      │
       ↓                                      ↓
┌──────────────┐                      ┌──────────────┐
│  COMPLETED   │                      │  ABANDONED   │
│  (success)   │                      │   (killed)   │
└──────────────┘                      └──────────────┘
       │                                      │
       └──────────────┬───────────────────────┘
                      │
                      ↓ (after animation)
                ┌─────────────┐
                │ No Session  │
                │  (reset)    │
                └─────────────┘
```

---

## Error Handling

### Invalid State Transitions

```swift
func pauseSession() {
    guard currentState == .active else {
        print("Cannot pause: session not active")
        return
    }
    // ... proceed
}
```

### SwiftData Save Failures

```swift
do {
    try context.save()
} catch {
    print("Failed to save session: \(error)")
    // Show error to user via published property
    errorMessage = "Failed to save session"
}
```

### Notification Permission Denied

```swift
// Gracefully degrade - no error shown
await notificationService.scheduleNotificationIfAuthorized(in: 1500.0)
```

---

## Testing Doubles

### Mock ModelContext

```swift
class MockModelContext: ModelContext {
    var insertedSessions: [FocusSession] = []
    var savedCount: Int = 0
    
    override func insert(_ session: FocusSession) {
        insertedSessions.append(session)
    }
    
    override func save() throws {
        savedCount += 1
    }
}
```

### Mock NotificationService

```swift
class MockNotificationService: NotificationService {
    var scheduledNotifications: [(id: String, interval: TimeInterval)] = []
    var cancelledNotifications: [String] = []
    
    override func scheduleNotification(id: String, in interval: TimeInterval) {
        scheduledNotifications.append((id, interval))
    }
    
    override func cancelNotification(id: String) {
        cancelledNotifications.append(id)
    }
}
```

### Time-Accelerated Testing

```swift
// For tests, inject a time multiplier
class TimerViewModel {
    var timeMultiplier: Double = 1.0 // 60.0 for 60x speed in tests
    
    func updateTimer() {
        remainingTime -= (1.0 * timeMultiplier)
        // ...
    }
}
```

---

## Performance Constraints

| Operation | Target | Validation |
|-----------|--------|------------|
| startSession() | <100ms | Time Profiler |
| updateTimer() (1s tick) | <10ms | Time Profiler |
| handleForeground() | <50ms | Time Profiler |
| Memory footprint | <5MB | Allocations Instrument |

---

## Usage Example

```swift
struct TimerView: View {
    @StateObject private var viewModel: TimerViewModel
    
    var body: some View {
        VStack {
            // Countdown display
            Text(formatTime(viewModel.remainingTime))
                .font(.system(size: 60, weight: .bold))
            
            // Tree visualization
            TreeView(stage: viewModel.treeStage)
            
            // Controls based on state
            switch viewModel.currentState {
            case .active:
                Button("Pause") { viewModel.pauseSession() }
                Button("Give Up") { showCancelConfirmation = true }
                
            case .paused:
                Button("Resume") { viewModel.resumeSession() }
                Button("Give Up") { showCancelConfirmation = true }
                
            case .completed, .abandoned:
                // Show completion/abandonment UI
                
            default:
                Button("Plant Tree") { viewModel.startSession() }
            }
        }
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
```

---

## Contract Complete ✅

**Inputs defined**: 7 methods (start, pause, resume, cancel, background, foreground)  
**Outputs defined**: 4 published properties (remainingTime, currentState, treeStage, isSessionActive)  
**Side effects documented**: Persistence, notifications, timer lifecycle  
**Dependencies identified**: ModelContext, NotificationService, BackgroundService  
**Testing strategy**: Mocks for all dependencies, time acceleration for tests

**Ready for implementation**: Phase 2 TDD cycle (RED → GREEN → REFACTOR)

---

**Authored by**: AI Assistant  
**Date**: 2025-10-29
