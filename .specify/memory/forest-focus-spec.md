# Feature Specification: Forest Focus - Pomodoro Timer

**Feature Branch**: `001-forest-focus-core`  
**Created**: 2025-10-29  
**Status**: Draft  
**Input**: User description: "Build a Forest-style Pomodoro app for iOS: start a 25-minute session to 'plant' a tree that grows through 5 stages; cancel/quit kills the tree; completion saves it to a personal forest. Show countdown, pause/resume, local notification, and background-accurate timing. Store completed/abandoned sessions locally; show a forest grid and stats (total trees, total focus time, today's count, daily streak). Out of scope: custom durations, species, sync, sharing, watch, widgets."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Start and Complete Focus Session (Priority: P1)

As a user, I want to start a 25-minute focus session and see a tree grow, so I can stay focused and feel rewarded for completing my session.

**Why this priority**: Core value proposition - without this, there's no app. Delivers immediate tangible value.

**Independent Test**: Can be fully tested by starting a session, waiting for completion, and verifying the tree is saved. Delivers a complete focus experience with visual feedback.

**Acceptance Scenarios**:

1. **Given** app is open on main screen, **When** user taps "Plant Tree" button, **Then** timer starts at 25:00, tree appears at growth stage 1, countdown begins
2. **Given** session is active at 20:00 remaining, **When** 5 minutes elapse, **Then** tree advances to growth stage 2
3. **Given** session is active at 15:00 remaining, **When** 5 minutes elapse, **Then** tree advances to growth stage 3
4. **Given** session is active at 10:00 remaining, **When** 5 minutes elapse, **Then** tree advances to growth stage 4
5. **Given** session is active at 5:00 remaining, **When** 5 minutes elapse, **Then** tree advances to growth stage 5
6. **Given** session completes (00:00), **When** timer reaches zero, **Then** tree is fully grown, success animation plays, tree is saved to forest, local notification sent
7. **Given** session completes, **When** user returns to main screen, **Then** stats update (total trees +1, total focus time +25 min, today's count +1)

---

### User Story 2 - Pause and Resume Session (Priority: P1)

As a user, I want to pause my focus session if interrupted and resume it later, so I can handle urgent matters without abandoning my progress.

**Why this priority**: Essential for real-world usage - users need flexibility for genuine interruptions while maintaining focus commitment.

**Independent Test**: Start a session, pause it, verify timer stops, resume it, verify timer continues from paused time and tree completes normally.

**Acceptance Scenarios**:

1. **Given** session is active at 18:00 remaining, **When** user taps "Pause" button, **Then** timer stops, countdown pauses, tree stops growing, "Resume" button appears
2. **Given** session is paused, **When** user taps "Resume" button, **Then** timer continues from paused time, countdown resumes, tree growth continues
3. **Given** session is paused, **When** user backgrounds the app and returns, **Then** session remains paused at same time
4. **Given** session is paused for 2 minutes, **When** user resumes and completes remaining time, **Then** tree saves correctly with accurate focus time (pause time not counted)

---

### User Story 3 - Cancel Session (Priority: P1)

As a user, I want to see clear consequences when I quit a session early, so I'm motivated to complete my focus time.

**Why this priority**: Core to the Forest mechanic - the "penalty" of killing a tree is what makes completion meaningful.

**Independent Test**: Start a session, cancel it, verify tree dies, verify session recorded as abandoned.

**Acceptance Scenarios**:

1. **Given** session is active at any time, **When** user taps "Give Up" button, **Then** confirmation dialog appears with warning "This will kill your tree"
2. **Given** confirmation dialog is shown, **When** user taps "Cancel", **Then** dialog closes, session continues normally
3. **Given** confirmation dialog is shown, **When** user taps "Give Up", **Then** tree wilts/dies animation plays, session ends, abandoned session recorded
4. **Given** abandoned session recorded, **When** user views stats, **Then** abandoned count increments but total trees does NOT increment

---

### User Story 4 - Background Timer Accuracy (Priority: P1)

As a user, I want the timer to continue accurately when the app is in the background, so I can use my phone for other tasks without losing progress.

**Why this priority**: Critical for usability - users must trust the timer works correctly when app is backgrounded.

**Independent Test**: Start session, background app for known duration, return to app, verify timer shows correct elapsed time.

**Acceptance Scenarios**:

1. **Given** session is active at 20:00 remaining, **When** user backgrounds app for 5 minutes, **Then** timer shows 15:00 when app returns to foreground
2. **Given** session is active at 20:00 remaining, **When** user backgrounds app for 5 minutes, **Then** tree growth stage updates correctly to reflect actual elapsed time
3. **Given** session is active at 5:00 remaining, **When** user backgrounds app until completion, **Then** local notification fires at exact completion time
4. **Given** session completes while backgrounded, **When** user returns to app, **Then** completed tree is visible, stats updated correctly

---

### User Story 5 - View Personal Forest (Priority: P2)

As a user, I want to see all my completed trees in a forest grid, so I can visualize my focus achievements over time.

**Why this priority**: Important for motivation and sense of progress, but app delivers value without it (P1 scenarios work standalone).

**Independent Test**: Complete 3 sessions, navigate to forest view, verify 3 trees displayed in grid with timestamps.

**Acceptance Scenarios**:

1. **Given** user has completed 5 sessions, **When** user navigates to "Forest" tab, **Then** grid shows 5 trees in chronological order (newest first)
2. **Given** user has completed 0 sessions, **When** user navigates to "Forest" tab, **Then** empty state shows "Plant your first tree to start growing your forest"
3. **Given** user has completed 20 sessions, **When** user views forest grid, **Then** grid scrolls vertically to show all trees
4. **Given** user taps a tree in forest, **When** tree is selected, **Then** detail view shows completion date and time

---

### User Story 6 - View Focus Statistics (Priority: P2)

As a user, I want to see my focus statistics, so I can track my productivity and maintain motivation.

**Why this priority**: Enhances motivation but not required for core focus functionality.

**Independent Test**: Complete sessions across multiple days, verify stats calculate correctly for all metrics.

**Acceptance Scenarios**:

1. **Given** user has completed 10 sessions total, **When** user views stats, **Then** "Total Trees" shows 10
2. **Given** user has completed 10 sessions (250 minutes), **When** user views stats, **Then** "Total Focus Time" shows "4h 10m"
3. **Given** user completed 3 sessions today, **When** user views stats, **Then** "Today's Trees" shows 3
4. **Given** user completed sessions on consecutive days (Mon, Tue, Wed), **When** user views stats on Wed, **Then** "Current Streak" shows 3 days
5. **Given** user completed sessions on Mon, Wed (skipped Tue), **When** user views stats on Wed, **Then** "Current Streak" shows 1 day (streak broken)
6. **Given** user has abandoned 3 sessions, **When** user views stats, **Then** "Abandoned" shows 3 (separate from completed trees)

---

### User Story 7 - Local Notifications (Priority: P2)

As a user, I want to receive a notification when my session completes, so I know when to return even if the app is backgrounded.

**Why this priority**: Nice-to-have for user experience, but timer works without it.

**Independent Test**: Start session, background app, verify notification appears at completion time with correct content.

**Acceptance Scenarios**:

1. **Given** user has granted notification permission, **When** session completes while backgrounded, **Then** notification appears with title "Tree planted!" and body "Great focus session!"
2. **Given** user has denied notification permission, **When** session completes while backgrounded, **Then** no notification sent, app behavior otherwise normal
3. **Given** notification is received, **When** user taps notification, **Then** app opens to show completed tree and updated forest

---

### Edge Cases

#### Timer and Session Management
- What happens when user force-quits app during active session? Session treated as abandoned, tree killed
- What happens when session is paused and user backgrounds app for 24 hours? Session remains paused indefinitely, user can resume or give up
- What happens when device time changes during session? Use monotonic clock (CACurrentMediaTime) for accuracy, ignore wall clock changes
- What happens when app is in background and phone restarts? Session lost, treated as abandoned
- What happens when user tries to start new session while one is active? Not possible - UI only shows active session controls

#### Background and Notifications
- What happens when notification permission changes mid-session? No retroactive effect, applies to next session
- What happens when session completes exactly when app returns to foreground? Show completion animation immediately, no notification
- What happens when multiple sessions complete on same day after app reopens? All count toward today's stats, all appear in forest

#### Data and Stats
- What happens when user completes first session ever? Streak starts at 1 day
- What happens when user completes session at 11:59 PM and another at 12:01 AM? Both count for their respective days, streak continues
- What happens when data storage fails? Show error message, session data lost for that session only
- What happens when user has 1000+ completed trees? Forest grid continues scrolling, performance maintained (lazy loading if needed)

#### Tree Growth
- What happens when timer is at exactly 5:00, 10:00, 15:00, 20:00? Tree updates to next stage at those exact moments
- What happens when user backgrounds app between growth stages? Tree shows correct stage when app returns based on elapsed time

## Requirements *(mandatory)*

### Functional Requirements

#### Session Management
- **FR-001**: System MUST allow users to start a 25-minute focus session with a single tap
- **FR-002**: System MUST display countdown timer showing minutes:seconds remaining
- **FR-003**: System MUST allow users to pause an active session
- **FR-004**: System MUST allow users to resume a paused session from exact pause point
- **FR-005**: System MUST allow users to cancel/give up on an active session with confirmation dialog
- **FR-006**: System MUST prevent starting a new session while one is active or paused
- **FR-007**: System MUST track only active focus time (exclude paused duration from total)

#### Tree Visualization
- **FR-008**: System MUST display tree visual that grows through exactly 5 distinct stages
- **FR-009**: System MUST advance tree to stage 2 at 20:00 remaining (5 min elapsed)
- **FR-010**: System MUST advance tree to stage 3 at 15:00 remaining (10 min elapsed)
- **FR-011**: System MUST advance tree to stage 4 at 10:00 remaining (15 min elapsed)
- **FR-012**: System MUST advance tree to stage 5 at 5:00 remaining (20 min elapsed)
- **FR-013**: System MUST show fully grown tree at 0:00 (25 min elapsed)
- **FR-014**: System MUST animate tree death when session is cancelled
- **FR-015**: System MUST animate tree success/completion when session finishes

#### Background Operation
- **FR-016**: System MUST continue timer countdown accurately when app is backgrounded
- **FR-017**: System MUST use monotonic clock (not wall clock) for timer accuracy
- **FR-018**: System MUST sync timer and tree growth when app returns from background
- **FR-019**: System MUST schedule local notification for session completion time
- **FR-020**: System MUST handle notification permission states (granted/denied) gracefully

#### Data Persistence
- **FR-021**: System MUST store completed sessions locally with completion timestamp
- **FR-022**: System MUST store abandoned sessions locally with abandonment timestamp
- **FR-023**: System MUST persist session data immediately upon completion/abandonment
- **FR-024**: System MUST use UserDefaults or Core Data (native iOS storage only)
- **FR-025**: System MUST maintain data integrity across app launches

#### Forest View
- **FR-026**: System MUST display grid of all completed trees in chronological order
- **FR-027**: System MUST show most recent trees first (reverse chronological)
- **FR-028**: System MUST show empty state when no trees exist
- **FR-029**: System MUST support scrolling for large collections of trees
- **FR-030**: System MUST display completion date/time when tree is tapped

#### Statistics
- **FR-031**: System MUST calculate and display "Total Trees" (all completed sessions)
- **FR-032**: System MUST calculate and display "Total Focus Time" in hours and minutes
- **FR-033**: System MUST calculate and display "Today's Trees" (sessions completed today)
- **FR-034**: System MUST calculate and display "Current Streak" (consecutive days with at least one completed session)
- **FR-035**: System MUST calculate and display "Abandoned" count (cancelled sessions)
- **FR-036**: System MUST reset "Today's Trees" at midnight local time
- **FR-037**: System MUST break streak if no sessions completed on a day

#### Notifications
- **FR-038**: System MUST request notification permission on first launch
- **FR-039**: System MUST send local notification when session completes in background
- **FR-040**: System MUST include meaningful message in notification ("Tree planted!")
- **FR-041**: System MUST open app to completed tree view when notification tapped
- **FR-042**: System MUST NOT send notification if app is in foreground at completion

#### Performance (Per Constitution)
- **FR-043**: System MUST launch to interactive UI in under 2 seconds (cold start)
- **FR-044**: System MUST maintain 60fps for all animations (tree growth, death, completion)
- **FR-045**: System MUST NOT perform background processing (battery conscious)
- **FR-046**: System MUST use efficient Core Animation for all visual transitions

#### Accessibility (Per Constitution)
- **FR-047**: System MUST provide VoiceOver labels for all interactive elements
- **FR-048**: System MUST support Dynamic Type for all text (timer, stats, labels)
- **FR-049**: System MUST provide alternative animations when Reduce Motion enabled
- **FR-050**: System MUST support high contrast mode for tree visuals

### Key Entities

- **FocusSession**: Represents a single 25-minute focus attempt
  - Attributes: startTime (Date), endTime (Date?), completed (Bool), duration (TimeInterval)
  - States: active, paused, completed, abandoned
  
- **Tree**: Visual representation of a completed session
  - Attributes: completionDate (Date), growthStage (1-5)
  - Linked to: FocusSession (one-to-one)
  
- **ForestStats**: Aggregated statistics
  - Attributes: totalTrees (Int), totalFocusTime (TimeInterval), todaysCount (Int), currentStreak (Int), abandonedCount (Int)
  - Computed from: Collection of FocusSession records

- **Timer**: Manages countdown and state
  - Attributes: remainingTime (TimeInterval), state (active/paused), startTime (Date)
  - Uses: CACurrentMediaTime for monotonic clock

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can start a focus session and see tree begin growing within 0.5 seconds of tap
- **SC-002**: Timer accuracy is within ±1 second after 25 minutes of backgrounded operation
- **SC-003**: All animations maintain 60fps minimum on devices from iPhone X onwards
- **SC-004**: App cold start to interactive UI completes in under 2 seconds on iPhone X or newer
- **SC-005**: VoiceOver users can complete full session (start, pause, resume, complete) using voice navigation only
- **SC-006**: All text remains readable at maximum Dynamic Type size (XXXL)
- **SC-007**: Forest view with 100 trees scrolls smoothly at 60fps
- **SC-008**: Session completion notification fires within 1 second of actual completion time
- **SC-009**: No memory leaks detected after 10 consecutive sessions (Instruments validation)
- **SC-010**: Stats calculate correctly for edge cases (midnight boundary, streak calculation)

### Performance Benchmarks (Per Constitution)

- **SC-011**: Time Profiler shows main thread idle >90% during active session
- **SC-012**: Core Animation Profiler shows 60fps (16.67ms frame time) for tree growth animations
- **SC-013**: Memory Graph shows no retain cycles in session management code
- **SC-014**: Energy Log shows minimal battery impact during 25-minute session

### User Experience Success

- **SC-015**: 95% of users successfully complete their first session without errors
- **SC-016**: Pause/resume flow completes in under 1 second (tap to UI update)
- **SC-017**: Tree growth stages are visually distinct and recognizable
- **SC-018**: Give up confirmation prevents accidental session cancellation

## Out of Scope (Explicit)

The following are explicitly NOT included in this specification:

- **Custom durations**: Only 25-minute sessions supported
- **Tree species**: Single tree design, no variations
- **Cloud sync**: All data local only, no server communication
- **Social features**: No sharing, friends, leaderboards
- **Apple Watch**: No watchOS companion app
- **Widgets**: No home screen or lock screen widgets
- **Sounds**: No audio feedback (focus on visual simplicity)
- **Themes**: No dark mode customization beyond system default
- **Export**: No data export functionality
- **Settings**: Minimal configuration (notifications only)

## Technical Constraints (Per Constitution)

### Architecture
- Swift only, latest stable version
- SwiftUI for UI (UIKit only if absolutely necessary)
- No third-party dependencies
- Offline-first: zero network calls

### Testing
- TDD mandatory: write tests before implementation
- Unit tests for business logic (timer, stats calculation)
- UI tests for critical user paths (start, pause, complete, cancel)
- Performance tests for startup time and animation frame rates
- Accessibility tests for VoiceOver navigation

### Quality Gates
- All tests pass before commit
- 80% code coverage minimum for business logic
- Instruments profiling shows <2s cold start
- Core Animation profiling shows 60fps for animations
- Accessibility Inspector validates VoiceOver labels
- Dynamic Type preview validates all sizes

## Open Questions

- **Q1**: Should tree visuals be illustrated (realistic) or abstract (geometric)?
- **Q2**: What happens to active session if user deletes and reinstalls app? (Acceptable loss?)
- **Q3**: Should abandoned sessions appear in forest view (as dead trees) or only in stats?
- **Q4**: Define exact animation durations for tree growth transitions (for 60fps validation)
- **Q5**: Should streak calculation count today if session completed after viewing stats?

## Dependencies

- iOS SDK: 17.0+ (latest stable)
- Xcode: 15.0+
- Swift: 5.9+
- Frameworks: SwiftUI, Foundation, UserNotifications, Combine (for timer)

## Next Steps

1. Get user approval on specification
2. Write test suite for P1 user stories (session start, pause/resume, cancel, background timing)
3. Implement minimal UI scaffolding (SwiftUI views, navigation)
4. Implement timer logic with background support
5. Implement tree visual and growth stages
6. Implement data persistence layer
7. Implement forest grid view
8. Implement statistics calculation
9. Profile with Instruments for performance validation
10. Accessibility audit with VoiceOver and Dynamic Type testing
