# Forest Focus Constitution

## Core Principles

### I. Radical Simplicity (NON-NEGOTIABLE)
Forest-style focus app: minimal features, clear purpose, zero bloat. Every feature must justify its existence. Start simple, expand only when essential. YAGNI principles strictly enforced.

### II. Offline-First (NON-NEGOTIABLE)
Zero network dependencies. All functionality works offline. No analytics, no cloud sync, no external services. Data stored locally using native iOS frameworks only.

### III. Test-First Development (NON-NEGOTIABLE)
TDD mandatory: Tests written → User approved → Tests fail → Then implement. Red-Green-Refactor cycle strictly enforced. No feature implementation without passing tests first. Unit tests for logic, UI tests for interactions.

### IV. Performance Standards (NON-NEGOTIABLE)
- **60fps animations**: All transitions and animations must maintain 60fps minimum
- **<2s cold start**: App launch to interactive UI in under 2 seconds
- **Memory efficient**: Minimal memory footprint, aggressive resource cleanup
- **Battery conscious**: No background processing, efficient Core Animation usage

### V. Accessibility First (NON-NEGOTIABLE)
- **VoiceOver**: Full VoiceOver support for all UI elements with meaningful labels
- **Dynamic Type**: All text scales correctly with system text size preferences
- **High Contrast**: Support for increased contrast accessibility settings
- **Reduce Motion**: Respect reduce motion preference with alternative transitions

## Technical Constraints

### Technology Stack
- **Language**: Swift only, latest stable version
- **UI Framework**: SwiftUI for declarative UI, UIKit only when absolutely necessary
- **Storage**: UserDefaults for simple data, Core Data or native file system for complex data
- **No Dependencies**: No third-party libraries or frameworks - native iOS SDK only

### Code Quality
- **Swift Style**: Follow Swift API Design Guidelines
- **Immutability**: Prefer value types (structs) over reference types (classes)
- **Type Safety**: Leverage Swift's type system, avoid `Any` and force unwrapping
- **Documentation**: Public APIs require documentation comments

## Development Workflow

### Testing Gates
- All tests must pass before commit
- Code coverage minimum 80% for business logic
- UI tests for critical user paths
- Performance tests for animations and startup time

### Performance Validation
- Profile with Instruments before each release
- Time Profiler for cold start measurement
- Core Animation for frame rate validation
- Memory Graph for leak detection

### Accessibility Validation
- Test with VoiceOver enabled
- Test all Dynamic Type sizes (XS to XXXL)
- Verify with Accessibility Inspector
- Test with Reduce Motion enabled

## Governance

This constitution supersedes all other practices. Amendments require:
1. Documentation of rationale
2. Impact assessment on existing principles
3. Team consensus

All PRs must verify compliance with:
- Test-first methodology (tests exist and pass)
- Performance standards (60fps, <2s cold start)
- Accessibility requirements (VoiceOver, Dynamic Type)
- Simplicity principle (minimal, justified changes)

**Version**: 1.0.0 | **Ratified**: 2025-10-29 | **Last Amended**: 2025-10-29
