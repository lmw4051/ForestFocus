# ForestFocus 🌲

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2016-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-green.svg)
![AI-Generated](https://img.shields.io/badge/AI-Generated-purple.svg)

**ForestFocus** is a productivity application designed to help users stay focused using the Pomodoro Technique. It combines effective time management with gamification elements—planting virtual trees—to make productivity engaging and rewarding.

## 🚀 Development Methodology: AI-Driven & SpecKit

This project is a demonstration of **modern AI-assisted software development**. It was not written entirely by hand but was architected and generated through a structured AI workflow.

* **Specification Engine:** [SpecKit](https://github.com/SpecKit) was used to define the project's memory, requirements, and architectural boundaries.
* **AI Generation:** Based on the robust specs provided by SpecKit, AI agents generated the core codebase, ensuring adherence to SOLID principles and the MVVM architecture.

This approach ensures that the project maintains a high standard of code structure and documentation from day one.

## 🛠 Tech Stack

* **Language:** Swift 5.9+
* **UI Framework:** SwiftUI
* **Architecture:** MVVM (Model-View-ViewModel)
* **Data Flow:** Combine / ObservableObject
* **Services:** Background Tasks, UserNotifications
* **Platform:** iOS 16.0+

## ✨ Key Features

* **🍅 Pomodoro Timer:** Customizable focus sessions to boost productivity.
* **🌲 Virtual Forest:** Visualize your focus time. Successfully completing a session plants a tree; interrupting it withers the tree.
* **📊 Statistics:** Track your daily, weekly, and monthly focus trends (powered by Swift Charts or Custom Views).
* **🔔 Smart Notifications:** Get notified when a session ends or when it's time to take a break.
* **⚙️ Customization:** Adjustable timer durations for focus, short breaks, and long breaks.

## 🏗 Architecture Overview

The app follows a clean **MVVM (Model-View-ViewModel)** architecture to separate UI logic from business logic:

* **Models:** `FocusSession`, `ForestStats`, `SessionState`. (Pure data structures).
* **Views:** SwiftUI Views (e.g., `TimerView`, `ForestGridView`, `StatsView`) that observe ViewModels.
* **ViewModels:** `TimerViewModel`. Handles state management, timer logic, and business rules.
* **Services:** `TimerService`, `NotificationService`, `BackgroundService`. Reusable components injected into ViewModels.

## 📲 Getting Started

### Prerequisites
* Mac running macOS Ventura or later.
* Xcode 15.0 or later.
* iOS 16.0+ Simulator or Device.

### Installation

1.  **Clone the repository**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/ForestFocus.git](https://github.com/YOUR_USERNAME/ForestFocus.git)
    cd ForestFocus
    ```

2.  **Open the project**
    Double-click `ForestFocus.xcodeproj` to open it in Xcode.

3.  **Run the App**
    Select your target simulator (e.g., iPhone 15 Pro) and press **Cmd + R** to build and run.

## 📂 Project Structure

```text
ForestFocus/
├── Models/         # Data structures (FocusSession, etc.)
├── Views/          # SwiftUI Screens (Timer, Stats, Forest)
├── ViewModels/     # Business Logic (TimerViewModel)
├── Services/       # Helper classes (Notification, Background)
├── Resources/      # Assets and Colors
└── Tests/          # Unit and UI Tests
