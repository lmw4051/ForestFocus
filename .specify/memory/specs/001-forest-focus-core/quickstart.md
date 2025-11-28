# Forest Focus - Developer Quickstart Guide

**Date**: 2025-10-29  
**Tasks**: T016-T017  
**Purpose**: Get new developers up and running with Forest Focus development workflow.

---

## Overview

This guide covers:
- Project setup in Xcode
- Running tests (unit, UI, performance)
- Profiling with Instruments
- Target benchmarks
- TDD workflow
- Common commands

---

## Prerequisites

### Required Tools

| Tool | Version | Installation |
|------|---------|--------------|
| macOS | 13.0+ | System requirement |
| Xcode | 15.0+ | Mac App Store |
| iOS Simulator | 17.0+ | Included with Xcode |
| Git | 2.0+ | Pre-installed on macOS |

### Optional Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| SF Symbols | Icon browsing | [developer.apple.com](https://developer.apple.com/sf-symbols/) |
| SimulatorStatusMagic | Clean screenshots | `brew install lyft/formulae/set-simulator-location` |

---

## Initial Setup

### 1. Clone Repository

```bash
cd ~/Documents
git clone [repository-url] forest-focus
cd forest-focus
```

### 2. Open in Xcode

```bash
open ForestFocus.xcodeproj
```

Or from Xcode: File → Open → Select `ForestFocus.xcodeproj`

### 3. Verify Build

**Keyboard shortcut**: `Cmd + B`

**Expected output**:
```
Build Succeeded
```

**First build time**: ~30-60 seconds (Swift compiles SwiftData framework)

### 4. Select Simulator

**Toolbar**: iPhone 15 Pro (or any iOS 17+ simulator)

**To install more simulators**:
1. Xcode → Preferences (Cmd + ,)
2. Components tab
3. Download iOS 17.x Simulator

---

## Running Tests

### Unit Tests

**Keyboard shortcut**: `Cmd + U`

**Command line**:
```bash
xcodebuild test \
  -scheme ForestFocus \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:ForestFocusTests
```

**Expected output**:
```
Test Suite 'All tests' passed
    Executed 42 tests, with 0 failures (0 unexpected)
```

**Test duration**: ~5-10 seconds (depending on number of tests)

---

### UI Tests

**Keyboard shortcut**: `Cmd + Shift + U`

**Command line**:
```bash
xcodebuild test \
  -scheme ForestFocus \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:ForestFocusUITests
```

**Expected output**:
```
Test Suite 'All tests' passed
    Executed 12 tests, with 0 failures (0 unexpected)
```

**Test duration**: ~30-60 seconds (UI tests are slower)

**Note**: First run may take longer as simulator launches

---

### Run Specific Test

**In Xcode**:
1. Open test file (e.g., `TimerViewModelTests.swift`)
2. Click diamond icon next to test method
3. Test runs in isolation

**Command line**:
```bash
xcodebuild test \
  -scheme ForestFocus \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:ForestFocusTests/TimerViewModelTests/testStartSession
```

---

### Run Tests on Commit (Recommended)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
echo "Running tests before commit..."
xcodebuild test \
  -scheme ForestFocus \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro,OS=17.0' \
  -quiet

if [ $? -ne 0 ]; then
  echo "❌ Tests failed. Commit aborted."
  exit 1
fi

echo "✅ Tests passed. Proceeding with commit."
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

---

## Profiling with Instruments

### 1. Cold Start Performance (Time Profiler)

**Target**: <2 seconds to interactive UI

**Steps**:
1. Product → Profile (Cmd + I)
2. Select "Time Profiler" template
3. Click Record (red button)
4. Wait for app to launch and become interactive
5. Stop recording (stop button)
6. Analyze "Main Thread" track

**What to look for**:
- Time from `application(_:didFinishLaunchingWithOptions:)` to first view render
- Should be <2000ms

**Pass criteria**: Main thread shows UI ready <2s after launch

**Screenshot location**: Save as `docs/profiling/cold-start-YYYY-MM-DD.png`

---

### 2. Animation Performance (Core Animation)

**Target**: 60fps (16.67ms max frame time)

**Steps**:
1. Product → Profile (Cmd + I)
2. Select "Core Animation" template
3. Enable "Color Offscreen-Rendered" (yellow)
4. Enable "Flash Updated Regions" (will flash on updates)
5. Click Record
6. In app: Start session, watch tree growth animations
7. Navigate to Forest grid, scroll through trees
8. Stop recording

**What to look for**:
- Frame Time graph: Should stay below 16.67ms line
- No red bars (dropped frames)
- Flash regions: Only animating elements should flash

**Pass criteria**: No frames exceed 16.67ms during animations

**Screenshot location**: Save as `docs/profiling/animations-YYYY-MM-DD.png`

---

### 3. Memory Usage (Allocations + Leaks)

**Target**: <50MB during active session, zero leaks

**Steps**:
1. Product → Profile (Cmd + I)
2. Select "Allocations" template
3. Click Record
4. In app: Start session
5. Wait 25 minutes (or use accelerated time in Debug)
6. Check memory graph
7. Switch to "Leaks" instrument
8. Look for leak indicators (red bars)

**What to look for**:
- "All Heap & Anonymous VM" should be <50MB
- No red bars in Leaks instrument
- Persistent memory growth (indicates leak)

**Pass criteria**: <50MB peak, zero leaks

**Screenshot location**: Save as `docs/profiling/memory-YYYY-MM-DD.png`

---

### 4. Battery Impact (Energy Log)

**Target**: Low energy impact

**Steps**:
1. Product → Profile (Cmd + I)
2. Select "Energy Log" template
3. Click Record
4. In app: Start session, let run for 5 minutes
5. Stop recording
6. Check "Energy Usage" section

**What to look for**:
- Energy impact rating: Should be "Low"
- CPU usage: Should be <5% average
- No unexpected wakeups

**Pass criteria**: Energy impact rated "Low"

---

## Target Benchmarks

### Performance Goals

| Metric | Target | Tool | Test Frequency |
|--------|--------|------|----------------|
| Cold start | <2s | Time Profiler | Per PR |
| Animations | 60fps | Core Animation | Per animation change |
| Memory | <50MB | Allocations | Per session logic change |
| Timer accuracy | ±1s/25min | Manual stopwatch | Per timer change |
| Battery | Low impact | Energy Log | Per release |

### Code Coverage

**View coverage**:
1. Product → Test (Cmd + U)
2. Show Report Navigator (Cmd + 9)
3. Select latest test run
4. Click "Coverage" tab

**Target**: 80% coverage for business logic

**Exclude from coverage**:
- Views (UI code)
- SwiftUI previews
- App entry point

---

## Test Strategy (Per Constitution)

### Test Pyramid

```
         /\
        /  \  10% Performance (XCTMetrics)
       /----\
      /      \  20% UI Tests (XCUITest)
     /--------\
    /          \  70% Unit Tests (XCTest)
   /------------\
```

### Test Types

| Type | Framework | Purpose | Example |
|------|-----------|---------|---------|
| Unit | XCTest | Business logic | `TimerViewModelTests` |
| UI | XCUITest | User flows | `TimerFlowTests` |
| Performance | XCTMetrics | Benchmarks | `PerformanceTests` |

### TDD Workflow (Mandatory)

```
1. RED: Write failing test
   └─> Test fails (expected)
   
2. GREEN: Implement minimal code
   └─> Test passes
   
3. REFACTOR: Clean up code
   └─> Tests still pass
   
4. PROFILE: Validate performance
   └─> Meets benchmarks
   
5. COMMIT: Save progress
   └─> Git commit with message
```

**Example commit messages**:
```
RED: Add test for session start functionality
GREEN: Implement startSession() to pass test
REFACTOR: Extract timer logic to pure function
PROFILE: Verify memory usage <5MB for TimerViewModel
```

---

## Common Commands

### Build & Run

```bash
# Clean build folder
xcodebuild clean \
  -scheme ForestFocus

# Build for simulator
xcodebuild build \
  -scheme ForestFocus \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run app in simulator
open -a Simulator
xcrun simctl install booted ForestFocus.app
xcrun simctl launch booted com.example.ForestFocus
```

---

### Testing

```bash
# Run all tests
xcodebuild test \
  -scheme ForestFocus \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -quiet

# Run only unit tests
xcodebuild test \
  -scheme ForestFocus \
  -only-testing:ForestFocusTests

# Run only UI tests
xcodebuild test \
  -scheme ForestFocus \
  -only-testing:ForestFocusUITests

# Run with coverage
xcodebuild test \
  -scheme ForestFocus \
  -enableCodeCoverage YES
```

---

### Profiling

```bash
# Profile with Time Profiler
xcodebuild clean build \
  -scheme ForestFocus \
  -configuration Release
instruments -t "Time Profiler" -D time_profile.trace \
  ~/Library/Developer/Xcode/DerivedData/.../ForestFocus.app

# Profile with Allocations
instruments -t "Allocations" -D allocations.trace \
  ~/Library/Developer/Xcode/DerivedData/.../ForestFocus.app
```

---

## Project Structure Navigation

### Key Directories

```
ForestFocus/
├── ForestFocusApp.swift          # App entry point
├── Models/                       # SwiftData models
│   ├── FocusSession.swift
│   └── SessionState.swift
├── ViewModels/                   # Business logic
│   ├── TimerViewModel.swift
│   ├── ForestViewModel.swift
│   └── StatsViewModel.swift
├── Views/                        # SwiftUI views
│   ├── Timer/
│   ├── Forest/
│   └── Stats/
├── Services/                     # Platform services
│   ├── NotificationService.swift
│   ├── TimerService.swift
│   └── BackgroundService.swift
└── Resources/
    └── Assets.xcassets

ForestFocusTests/
├── ModelTests/
├── ViewModelTests/
└── ServiceTests/

ForestFocusUITests/
├── TimerFlowTests.swift
├── ForestViewTests.swift
└── AccessibilityTests.swift
```

---

## Troubleshooting

### Issue: "Build Failed - SwiftData not found"

**Solution**: Ensure deployment target is iOS 17.0+
1. Select project in Navigator
2. Select target "ForestFocus"
3. General tab → Deployment Info → iOS 17.0

---

### Issue: Tests fail with "Unable to find simulator"

**Solution**: Install iOS 17+ simulator
1. Xcode → Preferences → Components
2. Download iOS 17.x Simulator
3. Restart Xcode

---

### Issue: "Code coverage not showing"

**Solution**: Enable coverage in scheme
1. Product → Scheme → Edit Scheme (Cmd + <)
2. Test tab → Options
3. Check "Gather coverage for some targets"
4. Select ForestFocus target

---

### Issue: Instruments not launching

**Solution**: Reset Instruments
```bash
rm -rf ~/Library/Application\ Support/Instruments
killall -9 Instruments
```

---

## Accessibility Testing

### VoiceOver Testing

**Enable VoiceOver in Simulator**:
1. Settings app in simulator
2. Accessibility → VoiceOver → On
3. Or triple-click Home button (if enabled)

**VoiceOver gestures**:
- Swipe right: Next element
- Swipe left: Previous element
- Double tap: Activate
- Three-finger swipe up: Scroll up

**Test checklist**:
- [ ] All buttons have meaningful labels
- [ ] Timer reads "X minutes Y seconds remaining"
- [ ] Tree stages announced on change
- [ ] Navigation works with swipe gestures

---

### Dynamic Type Testing

**Change text size in Simulator**:
1. Settings → Accessibility → Display & Text Size → Larger Text
2. Drag slider to maximum (XXXL)
3. Return to Forest Focus app

**Test checklist**:
- [ ] All text scales correctly
- [ ] No truncation at XXXL size
- [ ] Layout adapts to larger text
- [ ] Buttons still tappable

---

### Reduce Motion Testing

**Enable Reduce Motion**:
1. Settings → Accessibility → Motion → Reduce Motion → On
2. Return to Forest Focus app

**Test checklist**:
- [ ] Tree growth uses fade instead of scale
- [ ] Navigation transitions simplified
- [ ] No motion-based animations

---

## Next Steps

1. **Read architecture docs**: `.specify/memory/specs/001-forest-focus-core/research.md`
2. **Review data models**: `.specify/memory/specs/001-forest-focus-core/data-model.md`
3. **Study contracts**: `.specify/memory/specs/001-forest-focus-core/contracts/`
4. **Pick a task**: `.specify/memory/specs/001-forest-focus-core/tasks.md`
5. **Follow TDD workflow**: RED → GREEN → REFACTOR → PROFILE

---

## Resources

### Official Documentation

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Combine Documentation](https://developer.apple.com/documentation/combine)
- [Instruments Help](https://help.apple.com/instruments/mac/current/)

### Internal Documentation

- Constitution: `.specify/memory/constitution.md`
- Specification: `.specify/memory/forest-focus-spec.md`
- Implementation Plan: `.specify/memory/specs/001-forest-focus-core/plan.md`
- Tasks: `.specify/memory/specs/001-forest-focus-core/tasks.md`

---

## Quickstart Complete ✅

**Setup documented**: Xcode project, simulators, tools  
**Test commands**: Unit, UI, performance, coverage  
**Profiling workflows**: Time Profiler, Core Animation, Allocations, Energy Log  
**Benchmarks defined**: <2s cold start, 60fps, <50MB, 80% coverage  
**TDD workflow**: RED → GREEN → REFACTOR → PROFILE → COMMIT  
**Accessibility testing**: VoiceOver, Dynamic Type, Reduce Motion  
**Troubleshooting**: Common issues with solutions

**Ready for**: Phase 2 implementation (starting with T018 - project setup)

---

**Authored by**: AI Assistant  
**Date**: 2025-10-29  
**Review Status**: Ready for implementation
