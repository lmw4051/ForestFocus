---
description: "Task list for Forest Focus Pomodoro Timer implementation"
---

# Tasks: Forest Focus - Pomodoro Timer

**Input**: Design documents from `.specify/memory/specs/001-forest-focus-core/`  
**Prerequisites**: plan.md ✅, spec.md ✅ (forest-focus-spec.md), research.md (Phase 0), data-model.md (Phase 1), contracts/ (Phase 1)

**Tests**: TDD MANDATORY per constitution - all test tasks must be completed FIRST (RED) before implementation (GREEN).

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story/phase this task belongs to (e.g., US1, US2, SETUP)
- Include exact file paths in descriptions

## Path Conventions

Mobile iOS project structure:
- **App**: `ForestFocus/` at repository root
- **Tests**: `ForestFocusTests/` (unit), `ForestFocusUITests/` (UI)
- Models: `ForestFocus/Models/`
- ViewModels: `ForestFocus/ViewModels/`
- Views: `ForestFocus/Views/`
- Services: `ForestFocus/Services/`

---

## Phase 0: Research & Architecture (PRE-IMPLEMENTATION)

**Purpose**: Understand SwiftData, Combine timer, background timing, and animation performance constraints BEFORE coding.

**Deliverable**: `research.md` with architectural decisions

- [ ] T001 [P] [RESEARCH] Research SwiftData @Model macro, queries, and in-memory testing patterns
- [ ] T002 [P] [RESEARCH] Research Combine Timer.publish() vs CADisplayLink for 60fps updates
- [ ] T003 [P] [RESEARCH] Research background timing with ScenePhase and CACurrentMediaTime
- [ ] T004 [P] [RESEARCH] Research UNUserNotificationCenter scheduling and permission flow
- [ ] T005 [P] [RESEARCH] Research SwiftUI animation performance (withAnimation vs implicit, Reduce Motion)
- [ ] T006 [P] [RESEARCH] Research memory management strategies (@StateObject vs @ObservedObject, LazyVGrid efficiency)
- [ ] T007 [RESEARCH] Document architectural decisions in `.specify/memory/specs/001-forest-focus-core/research.md`
- [ ] T008 [RESEARCH] Answer 7 open questions from plan.md in research.md

**Checkpoint**: Research complete, architecture decisions documented, ready for Phase 1 design.

---

## Phase 1: Design & Contracts (PRE-IMPLEMENTATION)

**Purpose**: Define SwiftData models, ViewModel contracts, and testing strategy BEFORE writing code.

**Deliverables**: `data-model.md`, `quickstart.md`, `contracts/*.md`

### Data Model Design

- [ ] T009 [P] [DESIGN] Define FocusSession @Model schema in `data-model.md` (id, startTime, endTime, state, duration)
- [ ] T010 [P] [DESIGN] Define SessionState enum schema in `data-model.md` (active, paused, completed, abandoned)
- [ ] T011 [P] [DESIGN] Define ForestStats computed struct schema in `data-model.md` (totals, streaks, today's count)
- [ ] T012 [DESIGN] Document SwiftData queries in `data-model.md` (all completed, today's sessions, date range)

### ViewModel Contracts

- [ ] T013 [P] [DESIGN] Define TimerViewModel contract in `contracts/timer-contract.md` (inputs, outputs, side effects)
- [ ] T014 [P] [DESIGN] Define ForestViewModel contract in `contracts/forest-contract.md` (query patterns, grid data)
- [ ] T015 [P] [DESIGN] Define StatsViewModel contract in `contracts/stats-contract.md` (calculations, streak logic)

### Testing Strategy & Quickstart

- [ ] T016 [DESIGN] Document test pyramid in `data-model.md` (70% unit, 20% UI, 10% performance)
- [ ] T017 [DESIGN] Create `quickstart.md` with Xcode setup, test commands, Instruments profiling workflow

**Checkpoint**: All contracts defined, data models designed, zero ambiguity, ready for Phase 2 TDD implementation.

---

## Phase 2: Project Setup (Shared Infrastructure)

**Purpose**: Initialize Xcode project with proper configuration before any feature implementation.

- [ ] T018 [SETUP] Create new iOS App project in Xcode 15+ named "ForestFocus"
- [ ] T019 [SETUP] Set deployment target to iOS 17.0+ in project settings
- [ ] T020 [SETUP] Configure SwiftData ModelContainer in `ForestFocus/ForestFocusApp.swift`
- [ ] T021 [P] [SETUP] Add notification permission keys to `Info.plist` (NSUserNotificationsUsageDescription)
- [ ] T022 [P] [SETUP] Create folder structure: Models/, ViewModels/, Views/, Services/, Resources/
- [ ] T023 [P] [SETUP] Configure XCTest unit test target `ForestFocusTests`
- [ ] T024 [P] [SETUP] Configure XCUITest UI test target `ForestFocusUITests`
- [ ] T025 [SETUP] Add Assets.xcassets with placeholder colors (primary, background, treeGreen)
- [ ] T026 [SETUP] Verify project builds successfully (Cmd+B)

**Checkpoint**: Project structure ready, builds successfully, ready for foundational work.

---

## Phase 3: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### SwiftData Foundation

- [ ] T027 [P] [FOUNDATION] Create `SessionState.swift` enum in `ForestFocus/Models/` (active, paused, completed, abandoned)
- [ ] T028 [FOUNDATION] Create `FocusSession.swift` @Model in `ForestFocus/Models/` with properties per data-model.md
- [ ] T029 [FOUNDATION] Write unit tests for FocusSession in `ForestFocusTests/ModelTests/FocusSessionTests.swift` (state transitions)
- [ ] T030 [FOUNDATION] Run tests, verify they pass (Cmd+U)

### Services Foundation

- [ ] T031 [P] [FOUNDATION] Create `TimerService.swift` in `ForestFocus/Services/` with CACurrentMediaTime monotonic clock
- [ ] T032 [P] [FOUNDATION] Create `NotificationService.swift` in `ForestFocus/Services/` with UNUserNotificationCenter wrapper
- [ ] T033 [P] [FOUNDATION] Create `BackgroundService.swift` in `ForestFocus/Services/` with ScenePhase observation
- [ ] T034 [FOUNDATION] Write unit tests for TimerService in `ForestFocusTests/ServiceTests/TimerServiceTests.swift`
- [ ] T035 [FOUNDATION] Write unit tests for NotificationService in `ForestFocusTests/ServiceTests/NotificationServiceTests.swift`
- [ ] T036 [FOUNDATION] Run tests, verify they pass (Cmd+U)

### Main UI Shell

- [ ] T037 [FOUNDATION] Create `ContentView.swift` in `ForestFocus/Views/` with TabView (Timer, Forest, Stats tabs)
- [ ] T038 [FOUNDATION] Create placeholder views: `TimerView.swift`, `ForestGridView.swift`, `StatsView.swift`
- [ ] T039 [FOUNDATION] Wire up ContentView in `ForestFocusApp.swift` with SwiftData environment
- [ ] T040 [FOUNDATION] Run app, verify tabs navigate correctly (Cmd+R)

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel.

---

## Phase 4: User Story 1 - Start and Complete Focus Session (Priority: P1) 🎯 MVP

**Goal**: Users can start a 25-minute session, watch a tree grow through 5 stages, complete the session, and see it saved to their forest.

**Independent Test**: Start session, wait for completion (or use accelerated time), verify tree saved and stats updated.

### Tests for User Story 1 (TDD - RED PHASE) ⚠️

> **CRITICAL: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T041 [P] [US1-TEST] Write failing test `testStartSession()` in `ForestFocusTests/ViewModelTests/TimerViewModelTests.swift` - verify timer starts at 25:00
- [ ] T042 [P] [US1-TEST] Write failing test `testTreeGrowthStages()` in `TimerViewModelTests.swift` - verify stages advance every 5 min
- [ ] T043 [P] [US1-TEST] Write failing test `testSessionCompletion()` in `TimerViewModelTests.swift` - verify session persisted to SwiftData
- [ ] T044 [P] [US1-TEST] Write failing test `testStatsUpdateOnCompletion()` in `ForestFocusTests/ViewModelTests/StatsViewModelTests.swift` - verify totals increment
- [ ] T045 [US1-TEST] Run all tests, verify they FAIL (Cmd+U) - expected RED state

### Implementation for User Story 1 (TDD - GREEN PHASE)

- [ ] T046 [US1-IMPL] Implement `TimerViewModel.swift` in `ForestFocus/ViewModels/` with Combine Timer.publish()
- [ ] T047 [US1-IMPL] Add `startSession()` method to TimerViewModel - initialize timer at 25:00 (1500 seconds)
- [ ] T048 [US1-IMPL] Add `@Published var remainingTime: TimeInterval` to TimerViewModel
- [ ] T049 [US1-IMPL] Add `@Published var currentState: SessionState` to TimerViewModel
- [ ] T050 [US1-IMPL] Add `@Published var treeStage: Int` (1-5) to TimerViewModel with growth logic
- [ ] T051 [US1-IMPL] Implement tree stage advancement logic (stage 2 at 20:00, stage 3 at 15:00, etc.)
- [ ] T052 [US1-IMPL] Add timer completion logic - persist FocusSession to SwiftData with completed state
- [ ] T053 [US1-IMPL] Add notification scheduling in startSession() via NotificationService
- [ ] T054 [US1-IMPL] Run tests, verify US1 tests now PASS (Cmd+U) - GREEN state achieved

### UI for User Story 1

- [ ] T055 [P] [US1-UI] Create `TreeView.swift` in `ForestFocus/Views/Timer/` with 5 stage visuals (placeholder shapes)
- [ ] T056 [P] [US1-UI] Create `CountdownView.swift` in `ForestFocus/Views/Timer/` with MM:SS format and Dynamic Type support
- [ ] T057 [US1-UI] Update `TimerView.swift` to display TreeView, CountdownView, and "Plant Tree" button
- [ ] T058 [US1-UI] Wire up TimerViewModel as @StateObject in TimerView
- [ ] T059 [US1-UI] Add "Plant Tree" button action to call `viewModel.startSession()`
- [ ] T060 [US1-UI] Add VoiceOver labels to all buttons (.accessibilityLabel)
- [ ] T061 [US1-UI] Run app, manually test session start and completion (Cmd+R)

### Refactor for User Story 1 (TDD - REFACTOR PHASE)

- [ ] T062 [US1-REFACTOR] Extract timer logic into pure functions for testability
- [ ] T063 [US1-REFACTOR] Optimize Combine subscriptions (use weak self to avoid retain cycles)
- [ ] T064 [US1-REFACTOR] Profile memory usage with Instruments - verify <10MB baseline increase

### UI Tests for User Story 1

- [ ] T065 [US1-UITEST] Write UI test `testStartAndCompleteSession()` in `ForestFocusUITests/TimerFlowTests.swift`
- [ ] T066 [US1-UITEST] Run UI tests, verify they pass (Cmd+Shift+U)

**Checkpoint**: User Story 1 fully functional - can start session, watch tree grow, complete, see in stats.

---

## Phase 5: User Story 2 - Pause and Resume Session (Priority: P1)

**Goal**: Users can pause an active session, then resume it from the exact pause point without losing progress.

**Independent Test**: Start session, pause at 18:00, wait 2 minutes, resume, verify timer continues from 18:00 (pause time not counted).

### Tests for User Story 2 (TDD - RED PHASE) ⚠️

- [ ] T067 [P] [US2-TEST] Write failing test `testPauseSession()` in `TimerViewModelTests.swift` - verify timer stops
- [ ] T068 [P] [US2-TEST] Write failing test `testResumeSession()` in `TimerViewModelTests.swift` - verify timer continues from pause point
- [ ] T069 [P] [US2-TEST] Write failing test `testPauseDurationNotCounted()` in `TimerViewModelTests.swift` - verify accurate total time
- [ ] T070 [US2-TEST] Run tests, verify they FAIL (Cmd+U)

### Implementation for User Story 2 (TDD - GREEN PHASE)

- [ ] T071 [US2-IMPL] Add `pauseSession()` method to TimerViewModel - cancel Combine subscription
- [ ] T072 [US2-IMPL] Add `resumeSession()` method to TimerViewModel - restart timer from remainingTime
- [ ] T073 [US2-IMPL] Add state machine transitions (active ↔ paused) in TimerViewModel
- [ ] T074 [US2-IMPL] Store pause timestamp for accurate time tracking
- [ ] T075 [US2-IMPL] Run tests, verify US2 tests now PASS (Cmd+U)

### UI for User Story 2

- [ ] T076 [US2-UI] Update `TimerView.swift` to show "Pause" button when state is active
- [ ] T077 [US2-UI] Update `TimerView.swift` to show "Resume" button when state is paused
- [ ] T078 [US2-UI] Add VoiceOver labels for pause/resume buttons
- [ ] T079 [US2-UI] Run app, manually test pause/resume flow (Cmd+R)

### Refactor for User Story 2

- [ ] T080 [US2-REFACTOR] Simplify state transition logic (consider state machine pattern)
- [ ] T081 [US2-REFACTOR] Profile memory with Instruments - verify no leaks on pause/resume cycle

### UI Tests for User Story 2

- [ ] T082 [US2-UITEST] Write UI test `testPauseAndResumeSession()` in `TimerFlowTests.swift`
- [ ] T083 [US2-UITEST] Run UI tests, verify they pass (Cmd+Shift+U)

**Checkpoint**: User Story 2 fully functional - can pause and resume sessions accurately.

---

## Phase 6: User Story 3 - Cancel Session (Priority: P1)

**Goal**: Users see clear consequences when they quit a session early (tree dies), motivating completion.

**Independent Test**: Start session, tap "Give Up", confirm in dialog, verify tree dies, session marked abandoned.

### Tests for User Story 3 (TDD - RED PHASE) ⚠️

- [ ] T084 [P] [US3-TEST] Write failing test `testCancelSession()` in `TimerViewModelTests.swift` - verify session marked abandoned
- [ ] T085 [P] [US3-TEST] Write failing test `testAbandonedSessionNotCountedInStats()` in `StatsViewModelTests.swift` - verify total trees doesn't increment
- [ ] T086 [US3-TEST] Run tests, verify they FAIL (Cmd+U)

### Implementation for User Story 3 (TDD - GREEN PHASE)

- [ ] T087 [US3-IMPL] Add `cancelSession()` method to TimerViewModel - cancel timer, mark abandoned
- [ ] T088 [US3-IMPL] Persist abandoned FocusSession to SwiftData with abandoned state
- [ ] T089 [US3-IMPL] Cancel scheduled notification in cancelSession()
- [ ] T090 [US3-IMPL] Run tests, verify US3 tests now PASS (Cmd+U)

### UI for User Story 3

- [ ] T091 [US3-UI] Update `TimerView.swift` to show "Give Up" button when state is active or paused
- [ ] T092 [US3-UI] Add confirmation dialog with warning "This will kill your tree"
- [ ] T093 [US3-UI] Add tree death animation to TreeView (wilting/fading)
- [ ] T094 [US3-UI] Add VoiceOver labels for "Give Up" button and dialog actions
- [ ] T095 [US3-UI] Run app, manually test cancel flow (Cmd+R)

### Refactor for User Story 3

- [ ] T096 [US3-REFACTOR] Extract confirmation dialog to reusable SwiftUI component
- [ ] T097 [US3-REFACTOR] Profile memory - verify abandoned sessions don't leak

### UI Tests for User Story 3

- [ ] T098 [US3-UITEST] Write UI test `testCancelWithConfirmation()` in `TimerFlowTests.swift`
- [ ] T099 [US3-UITEST] Write UI test `testCancelDialogDismissal()` in `TimerFlowTests.swift` - verify "Cancel" dismisses dialog
- [ ] T100 [US3-UITEST] Run UI tests, verify they pass (Cmd+Shift+U)

**Checkpoint**: User Story 3 fully functional - can cancel sessions with confirmation, tree dies.

---

## Phase 7: User Story 4 - Background Timer Accuracy (Priority: P1)

**Goal**: Timer continues accurately when app is backgrounded, allowing users to use other apps without losing progress.

**Independent Test**: Start session at 20:00, background app for 5 minutes, return, verify timer shows 15:00.

### Tests for User Story 4 (TDD - RED PHASE) ⚠️

- [ ] T101 [P] [US4-TEST] Write failing test `testBackgroundTimeSync()` in `BackgroundServiceTests.swift` - verify time delta calculation
- [ ] T102 [P] [US4-TEST] Write failing test `testBackgroundCompletionDetection()` in `TimerViewModelTests.swift` - verify session completes
- [ ] T103 [P] [US4-TEST] Write failing test `testBackgroundTreeGrowthSync()` in `TimerViewModelTests.swift` - verify correct tree stage
- [ ] T104 [US4-TEST] Run tests, verify they FAIL (Cmd+U)

### Implementation for User Story 4 (TDD - GREEN PHASE)

- [ ] T105 [US4-IMPL] Implement ScenePhase observation in BackgroundService
- [ ] T106 [US4-IMPL] Capture background timestamp using CACurrentMediaTime when app backgrounds
- [ ] T107 [US4-IMPL] Calculate elapsed time delta on foreground return in BackgroundService
- [ ] T108 [US4-IMPL] Update TimerViewModel.remainingTime based on background elapsed time
- [ ] T109 [US4-IMPL] Update TimerViewModel.treeStage based on total elapsed time
- [ ] T110 [US4-IMPL] Check for session completion on foreground return (remainingTime <= 0)
- [ ] T111 [US4-IMPL] Handle completion while backgrounded (persist session, update stats)
- [ ] T112 [US4-IMPL] Run tests, verify US4 tests now PASS (Cmd+U)

### Integration for User Story 4

- [ ] T113 [US4-INTEGRATION] Wire BackgroundService into TimerViewModel via Combine publishers
- [ ] T114 [US4-INTEGRATION] Add ScenePhase environment to TimerView for lifecycle observation
- [ ] T115 [US4-INTEGRATION] Test background/foreground transitions manually (Cmd+H to background)

### Refactor for User Story 4

- [ ] T116 [US4-REFACTOR] Optimize ScenePhase listener (debounce rapid transitions)
- [ ] T117 [US4-REFACTOR] Validate timer accuracy with external stopwatch - verify ±1 second over 25 minutes

**Checkpoint**: User Story 4 fully functional - timer accurate in background, session completes correctly.

---

## Phase 8: User Story 5 - View Personal Forest (Priority: P2)

**Goal**: Users can see all completed trees in a grid, visualizing focus achievements over time.

**Independent Test**: Complete 3 sessions, navigate to Forest tab, verify 3 trees displayed in grid.

### Tests for User Story 5 (TDD - RED PHASE) ⚠️

- [ ] T118 [P] [US5-TEST] Write failing test `testCompletedSessionsQuery()` in `ForestViewModelTests.swift` - verify only completed sessions returned
- [ ] T119 [P] [US5-TEST] Write failing test `testChronologicalOrdering()` in `ForestViewModelTests.swift` - verify newest first
- [ ] T120 [P] [US5-TEST] Write failing test `testEmptyForestState()` in `ForestViewModelTests.swift` - verify empty when no sessions
- [ ] T121 [US5-TEST] Run tests, verify they FAIL (Cmd+U)

### Implementation for User Story 5 (TDD - GREEN PHASE)

- [ ] T122 [US5-IMPL] Create `ForestViewModel.swift` in `ForestFocus/ViewModels/` with SwiftData query
- [ ] T123 [US5-IMPL] Add @Query for completed sessions sorted by endTime descending
- [ ] T124 [US5-IMPL] Add computed property for empty state detection
- [ ] T125 [US5-IMPL] Run tests, verify US5 tests now PASS (Cmd+U)

### UI for User Story 5

- [ ] T126 [P] [US5-UI] Create `TreeCell.swift` in `ForestFocus/Views/Forest/` - single tree in grid
- [ ] T127 [P] [US5-UI] Create `EmptyForestView.swift` in `ForestFocus/Views/Forest/` - empty state message
- [ ] T128 [US5-UI] Update `ForestGridView.swift` with LazyVGrid displaying completed trees
- [ ] T129 [US5-UI] Wire up ForestViewModel as @StateObject in ForestGridView
- [ ] T130 [US5-UI] Add navigation to tree detail view on tap (show completion date/time)
- [ ] T131 [US5-UI] Add VoiceOver labels for grid items
- [ ] T132 [US5-UI] Run app, complete multiple sessions, verify forest grid displays correctly (Cmd+R)

### Refactor for User Story 5

- [ ] T133 [US5-REFACTOR] Optimize LazyVGrid performance with 1000+ trees
- [ ] T134 [US5-REFACTOR] Profile scrolling with Instruments - verify 60fps

### UI Tests for User Story 5

- [ ] T135 [US5-UITEST] Write UI test `testForestGridDisplay()` in `ForestViewTests.swift`
- [ ] T136 [US5-UITEST] Write UI test `testEmptyForestState()` in `ForestViewTests.swift`
- [ ] T137 [US5-UITEST] Run UI tests, verify they pass (Cmd+Shift+U)

**Checkpoint**: User Story 5 fully functional - can view completed trees in grid, see empty state.

---

## Phase 9: User Story 6 - View Focus Statistics (Priority: P2)

**Goal**: Users can see focus statistics to track productivity and maintain motivation.

**Independent Test**: Complete sessions across multiple days, verify stats calculate correctly (totals, streaks, today's count).

### Tests for User Story 6 (TDD - RED PHASE) ⚠️

- [ ] T138 [P] [US6-TEST] Write failing test `testTotalTreesCalculation()` in `StatsViewModelTests.swift` - verify count of completed sessions
- [ ] T139 [P] [US6-TEST] Write failing test `testTotalFocusTimeCalculation()` in `StatsViewModelTests.swift` - verify sum of durations
- [ ] T140 [P] [US6-TEST] Write failing test `testTodaysCount()` in `StatsViewModelTests.swift` - verify today's sessions only
- [ ] T141 [P] [US6-TEST] Write failing test `testStreakCalculation()` in `StatsViewModelTests.swift` - verify consecutive days logic
- [ ] T142 [P] [US6-TEST] Write failing test `testStreakBreak()` in `StatsViewModelTests.swift` - verify streak resets on gap day
- [ ] T143 [P] [US6-TEST] Write failing test `testAbandonedCount()` in `StatsViewModelTests.swift` - verify abandoned sessions counted
- [ ] T144 [US6-TEST] Run tests, verify they FAIL (Cmd+U)

### Implementation for User Story 6 (TDD - GREEN PHASE)

- [ ] T145 [US6-IMPL] Create `StatsViewModel.swift` in `ForestFocus/ViewModels/` with SwiftData queries
- [ ] T146 [US6-IMPL] Create `ForestStats.swift` struct in `ForestFocus/Models/` (computed, not persisted)
- [ ] T147 [US6-IMPL] Implement total trees calculation (count completed sessions)
- [ ] T148 [US6-IMPL] Implement total focus time calculation (sum durations)
- [ ] T149 [US6-IMPL] Implement today's count calculation (filter by today's date)
- [ ] T150 [US6-IMPL] Implement streak calculation algorithm (consecutive days with ≥1 completed session)
- [ ] T151 [US6-IMPL] Implement abandoned count calculation (count abandoned sessions)
- [ ] T152 [US6-IMPL] Run tests, verify US6 tests now PASS (Cmd+U)

### UI for User Story 6

- [ ] T153 [US6-UI] Update `StatsView.swift` to display all stats with Dynamic Type support
- [ ] T154 [US6-UI] Add "Total Trees" display with icon
- [ ] T155 [US6-UI] Add "Total Focus Time" display formatted as "Xh Ym"
- [ ] T156 [US6-UI] Add "Today's Trees" display
- [ ] T157 [US6-UI] Add "Current Streak" display with "days" label
- [ ] T158 [US6-UI] Add "Abandoned" display (separate section)
- [ ] T159 [US6-UI] Wire up StatsViewModel as @StateObject in StatsView
- [ ] T160 [US6-UI] Add VoiceOver labels for all stat displays
- [ ] T161 [US6-UI] Run app, verify stats display correctly after completing sessions (Cmd+R)

### Refactor for User Story 6

- [ ] T162 [US6-REFACTOR] Extract streak logic to pure function for testability
- [ ] T163 [US6-REFACTOR] Profile stats calculation - verify <100ms for 1000+ sessions

**Checkpoint**: User Story 6 fully functional - can view all statistics with correct calculations.

---

## Phase 10: User Story 7 - Local Notifications (Priority: P2)

**Goal**: Users receive notification when session completes in background so they know to return.

**Independent Test**: Start session, background app, verify notification appears at 25-minute mark.

### Tests for User Story 7 (TDD - RED PHASE) ⚠️

- [ ] T164 [P] [US7-TEST] Write failing test `testPermissionRequest()` in `NotificationServiceTests.swift` - verify permission requested
- [ ] T165 [P] [US7-TEST] Write failing test `testScheduleNotification()` in `NotificationServiceTests.swift` - verify 25-min trigger
- [ ] T166 [P] [US7-TEST] Write failing test `testCancelNotification()` in `NotificationServiceTests.swift` - verify cancellation
- [ ] T167 [P] [US7-TEST] Write failing test `testNoNotificationWhenDenied()` in `NotificationServiceTests.swift` - verify graceful handling
- [ ] T168 [US7-TEST] Run tests, verify they FAIL (Cmd+U)

### Implementation for User Story 7 (TDD - GREEN PHASE)

- [ ] T169 [US7-IMPL] Update NotificationService with permission request on first launch
- [ ] T170 [US7-IMPL] Add `scheduleNotification(in timeInterval:)` method to NotificationService
- [ ] T171 [US7-IMPL] Add `cancelNotification()` method to NotificationService
- [ ] T172 [US7-IMPL] Handle permission denial gracefully (no-op if denied)
- [ ] T173 [US7-IMPL] Set notification title "Tree planted!" and body "Great focus session!"
- [ ] T174 [US7-IMPL] Run tests, verify US7 tests now PASS (Cmd+U)

### Integration for User Story 7

- [ ] T175 [US7-INTEGRATION] Call NotificationService.scheduleNotification() in TimerViewModel.startSession()
- [ ] T176 [US7-INTEGRATION] Call NotificationService.cancelNotification() in TimerViewModel.cancelSession()
- [ ] T177 [US7-INTEGRATION] Cancel notification on foreground return if session completed
- [ ] T178 [US7-INTEGRATION] Request notification permission on first app launch in ForestFocusApp
- [ ] T179 [US7-INTEGRATION] Handle notification tap to open app (UNUserNotificationCenterDelegate)
- [ ] T180 [US7-INTEGRATION] Test notification delivery manually by backgrounding app

### Refactor for User Story 7

- [ ] T181 [US7-REFACTOR] Simplify permission handling logic
- [ ] T182 [US7-REFACTOR] Profile memory - verify no impact from notification scheduling

**Checkpoint**: User Story 7 fully functional - notifications sent on completion, tapping opens app.

---

## Phase 11: Tree Animations & Polish (Cross-Cutting)

**Purpose**: Implement smooth 60fps animations and visual polish across all tree displays.

### Animation Implementation

- [ ] T183 [P] [ANIMATION] Design 5 tree stage visuals in Assets.xcassets (seed, sprout, sapling, tree, full tree)
- [ ] T184 [P] [ANIMATION] Implement tree growth animation with SwiftUI withAnimation() in TreeView
- [ ] T185 [P] [ANIMATION] Implement tree death animation (wilting/fading) in TreeView
- [ ] T186 [P] [ANIMATION] Implement success/completion animation in TreeView
- [ ] T187 [ANIMATION] Add accessibilityReduceMotion check for alternative animations (fade/scale only)
- [ ] T188 [ANIMATION] Extract animation constants to AnimationConstants.swift (durations, curves)

### Animation Testing

- [ ] T189 [ANIMATION-TEST] Write UI test `testReduceMotion()` in `AccessibilityTests.swift` - verify alternative animations
- [ ] T190 [ANIMATION-TEST] Profile with Core Animation Instrument - verify 60fps (16.67ms max frame time)
- [ ] T191 [ANIMATION-TEST] Run UI tests, verify animations pass (Cmd+Shift+U)

**Checkpoint**: All animations smooth at 60fps, Reduce Motion alternatives working.

---

## Phase 12: Accessibility Validation (Cross-Cutting)

**Purpose**: Validate all accessibility requirements meet constitution standards.

### VoiceOver Audit

- [ ] T192 [P] [ACCESSIBILITY] Audit all buttons for VoiceOver labels (Plant Tree, Pause, Resume, Give Up)
- [ ] T193 [P] [ACCESSIBILITY] Audit timer display for VoiceOver (read as "X minutes Y seconds remaining")
- [ ] T194 [P] [ACCESSIBILITY] Audit tree stages for VoiceOver descriptions ("Tree at stage 1 of 5")
- [ ] T195 [P] [ACCESSIBILITY] Audit forest grid for VoiceOver (date and time of each tree)
- [ ] T196 [P] [ACCESSIBILITY] Audit stats for VoiceOver (meaningful stat names and values)

### Dynamic Type Testing

- [ ] T197 [ACCESSIBILITY-TEST] Preview TimerView at all Dynamic Type sizes (XS to XXXL) in Xcode
- [ ] T198 [ACCESSIBILITY-TEST] Preview ForestGridView at all Dynamic Type sizes
- [ ] T199 [ACCESSIBILITY-TEST] Preview StatsView at all Dynamic Type sizes
- [ ] T200 [ACCESSIBILITY-TEST] Verify no text truncation at XXXL size

### Accessibility UI Tests

- [ ] T201 [ACCESSIBILITY-TEST] Write UI test `testVoiceOverNavigation()` in `AccessibilityTests.swift` - complete session with VoiceOver
- [ ] T202 [ACCESSIBILITY-TEST] Write UI test `testDynamicTypeScaling()` in `AccessibilityTests.swift` - verify text scales
- [ ] T203 [ACCESSIBILITY-TEST] Run accessibility tests, verify they pass (Cmd+Shift+U)

**Checkpoint**: All accessibility requirements validated and passing.

---

## Phase 13: Performance Validation (Cross-Cutting)

**Purpose**: Validate all performance requirements with Instruments profiling.

### Cold Start Performance

- [ ] T204 [PERFORMANCE] Profile cold start with Time Profiler - launch app from terminated state
- [ ] T205 [PERFORMANCE] Measure time to interactive UI (first tap-responsive view)
- [ ] T206 [PERFORMANCE] Verify cold start <2 seconds on iPhone X or newer
- [ ] T207 [PERFORMANCE] Document profiling evidence in `specs/001-forest-focus-core/performance-validation.md`

### Animation Performance

- [ ] T208 [PERFORMANCE] Profile tree growth animations with Core Animation Instrument
- [ ] T209 [PERFORMANCE] Verify 60fps (no frames exceed 16.67ms)
- [ ] T210 [PERFORMANCE] Document frame rate evidence in performance-validation.md

### Memory Budget

- [ ] T211 [PERFORMANCE] Profile active session with Allocations + Leaks Instrument
- [ ] T212 [PERFORMANCE] Run 25-minute session, check memory graph
- [ ] T213 [PERFORMANCE] Verify total memory <50MB during active session
- [ ] T214 [PERFORMANCE] Verify zero memory leaks detected
- [ ] T215 [PERFORMANCE] Document memory evidence in performance-validation.md

### Timer Accuracy

- [ ] T216 [PERFORMANCE] Test timer accuracy with external stopwatch
- [ ] T217 [PERFORMANCE] Start session, background for 25 minutes, compare to external timer
- [ ] T218 [PERFORMANCE] Verify timer accuracy ±1 second over 25 minutes
- [ ] T219 [PERFORMANCE] Document accuracy evidence in performance-validation.md

### Battery Impact

- [ ] T220 [PERFORMANCE] Profile energy usage with Energy Log in Xcode
- [ ] T221 [PERFORMANCE] Run 25-minute session, check energy impact rating
- [ ] T222 [PERFORMANCE] Verify energy impact rated as "Low"
- [ ] T223 [PERFORMANCE] Document energy evidence in performance-validation.md

### Performance Tests (XCTMetrics)

- [ ] T224 [P] [PERFORMANCE-TEST] Write performance test `testColdStartTime()` in `PerformanceTests.swift` using XCTMetrics
- [ ] T225 [P] [PERFORMANCE-TEST] Write performance test `testMemoryUsage()` in `PerformanceTests.swift` using XCTMemoryMetric
- [ ] T226 [PERFORMANCE-TEST] Run performance tests, verify baselines met (Cmd+Shift+U)

**Checkpoint**: All performance benchmarks validated with profiling evidence documented.

---

## Phase 14: Final Polish & Documentation

**Purpose**: Final code cleanup, documentation, and validation before release.

### Code Quality

- [ ] T227 [P] [POLISH] Run code cleanup pass - remove debug logging, TODO comments
- [ ] T228 [P] [POLISH] Add documentation comments to all public APIs
- [ ] T229 [P] [POLISH] Verify no compiler warnings (treat warnings as errors)
- [ ] T230 [POLISH] Run all tests one final time - verify 100% pass rate (Cmd+U, Cmd+Shift+U)

### Documentation

- [ ] T231 [P] [DOCS] Create README.md with project overview and setup instructions
- [ ] T232 [P] [DOCS] Document quickstart.md validation (run through setup steps)
- [ ] T233 [DOCS] Create CHANGELOG.md with v1.0.0 release notes

### Constitution Validation

- [ ] T234 [VALIDATION] Verify TDD compliance (git history shows tests before implementation)
- [ ] T235 [VALIDATION] Verify performance compliance (all profiling evidence documented)
- [ ] T236 [VALIDATION] Verify accessibility compliance (all validation tests pass)
- [ ] T237 [VALIDATION] Verify simplicity compliance (zero third-party deps, no bloat)
- [ ] T238 [VALIDATION] Verify offline compliance (static analysis confirms zero network calls)
- [ ] T239 [VALIDATION] Document constitution compliance in `specs/001-forest-focus-core/constitution-compliance.md`

### Final Testing

- [ ] T240 [FINAL-TEST] Complete full end-to-end test on physical device (iPhone)
- [ ] T241 [FINAL-TEST] Complete 3 full sessions, verify all features work correctly
- [ ] T242 [FINAL-TEST] Test all edge cases from spec (force quit, midnight boundary, etc.)
- [ ] T243 [FINAL-TEST] Archive build for TestFlight distribution (if applicable)

**Checkpoint**: Feature complete, all tests passing, ready for code review and merge.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 0 (Research)**: No dependencies - START HERE
- **Phase 1 (Design)**: Depends on Phase 0 completion - BLOCKS all implementation
- **Phase 2 (Setup)**: Depends on Phase 1 completion - can start after design
- **Phase 3 (Foundational)**: Depends on Phase 2 completion - BLOCKS all user stories
- **Phase 4-10 (User Stories)**: All depend on Phase 3 completion
  - P1 stories (US1-US4): Implement first in order for stable foundation
  - P2 stories (US5-US7): Can start after P1 stories or in parallel (if staffed)
- **Phase 11-13 (Cross-Cutting)**: Can proceed in parallel with user stories
- **Phase 14 (Final)**: Depends on all previous phases

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Phase 3 - No dependencies on other stories (FOUNDATION)
- **User Story 2 (P1)**: Depends on US1 completion (extends timer with pause/resume)
- **User Story 3 (P1)**: Depends on US1 completion (extends timer with cancel)
- **User Story 4 (P1)**: Depends on US1 completion (extends timer with background support)
- **User Story 5 (P2)**: Depends on US1 completion (queries completed sessions)
- **User Story 6 (P2)**: Depends on US1 completion (aggregates session data)
- **User Story 7 (P2)**: Depends on US1 completion (notifies on session completion)

### Within Each User Story (TDD Cycle)

1. **RED**: Write failing tests FIRST
2. **GREEN**: Implement minimal code to pass tests
3. **REFACTOR**: Clean up code, optimize
4. **PROFILE**: Validate performance with Instruments
5. **UI Tests**: Write UI tests for end-to-end validation

### Parallel Opportunities

- **Phase 0**: All research tasks [P] can run in parallel
- **Phase 1**: All design tasks [P] can run in parallel
- **Phase 2**: All setup tasks [P] can run in parallel
- **Phase 3**: Model/Service tasks [P] can run in parallel within their groups
- **User Stories**: Tests within a story marked [P] can run in parallel
- **Cross-Cutting**: Animations, Accessibility, Performance can proceed in parallel

---

## Implementation Strategy

### TDD-First Approach (Constitution Mandated)

**Every feature MUST follow this cycle:**

1. **Research** (Phase 0): Understand patterns and APIs
2. **Design** (Phase 1): Define contracts and data models
3. **RED**: Write failing test
4. **GREEN**: Implement minimal code to pass test
5. **REFACTOR**: Clean up and optimize
6. **PROFILE**: Validate performance constraints

**Never implement before tests fail. Never commit without tests passing.**

### MVP First (P1 Stories Only)

1. Complete Phase 0-3: Research → Design → Setup → Foundation
2. Complete Phase 4: User Story 1 (start/complete session) → VALIDATE
3. Complete Phase 5: User Story 2 (pause/resume) → VALIDATE
4. Complete Phase 6: User Story 3 (cancel) → VALIDATE
5. Complete Phase 7: User Story 4 (background) → VALIDATE
6. **STOP**: You now have a fully functional MVP!
7. Test thoroughly, profile performance, validate accessibility
8. Deploy/demo if ready

### Incremental Delivery (Add P2 Stories)

1. MVP complete (P1 stories done)
2. Add Phase 8: User Story 5 (forest grid) → VALIDATE
3. Add Phase 9: User Story 6 (stats) → VALIDATE
4. Add Phase 10: User Story 7 (notifications) → VALIDATE
5. Complete Phase 11-14: Polish, validate, document
6. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers (after Phase 3 foundation):

- **Developer A**: US1 (start/complete) → US4 (background)
- **Developer B**: US2 (pause/resume) → US5 (forest)
- **Developer C**: US3 (cancel) → US6 (stats) → US7 (notifications)
- **Designer**: Phase 11 (animations, tree visuals)
- **All**: Phase 12-13 (accessibility, performance validation)

---

## Notes

- **[P] tasks**: Different files, no dependencies - can parallelize
- **[Story] label**: Maps task to specific user story for traceability
- **TDD MANDATORY**: Tests MUST fail before implementation (constitution requirement)
- **Performance gates**: Profile after each user story (60fps, <50MB, <2s cold start)
- **Accessibility gates**: Validate VoiceOver, Dynamic Type, Reduce Motion continuously
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- All 50 functional requirements from spec mapped to tasks

**Total Tasks**: 243 tasks across 14 phases

**Critical Path**: Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4 (US1) → Phase 5 (US2) → Phase 6 (US3) → Phase 7 (US4) → Performance validation

**Estimated Timeline**: 
- Phase 0-1: 2-3 days (research + design)
- Phase 2-3: 1-2 days (setup + foundation)
- Phase 4-7 (P1 stories): 5-7 days (TDD cycle per story)
- Phase 8-10 (P2 stories): 3-4 days
- Phase 11-14 (polish): 2-3 days
- **Total**: 13-19 days (solo developer, TDD pace)

Ready to begin with Phase 0 research! 🌲
