# Eyebreak - macOS 20-20-20 Rule App

## Overview

Build a macOS menu bar app called **Eyebreak** that implements the 20-20-20 rule to prevent digital eye strain. The rule: every **20 minutes**, take a **20-second break** to look at something **20 feet away**.

## Tech Stack

- **SwiftUI** for UI
- **AppKit** integration where needed (menu bar, screen blocking)
- macOS 13+ target
- Swift 5.9+

## Core Features

### 1. Menu Bar App

- Lives in the menu bar with a simple **eye icon** (use SF Symbol `eye` or similar)
- No dock icon (LSUIElement = true in Info.plist)
- Menu bar dropdown shows:
  - Time until next break (e.g., "Next break in 12:34")
  - Pause/Resume toggle
  - Quit option

### 2. Timer System

- 20-minute countdown timer
- Timer **resets** when Mac sleeps/wakes (use NSWorkspace sleep/wake notifications)
- Pause functionality: stays paused until manually resumed
- Visual indicator in menu bar when paused (e.g., different icon or "Paused" text)

### 3. Warning Notification (30 seconds before break)

- Send a **macOS notification** 30 seconds before the screen blocks
- Notification should have:
  - Title: "Break in 30 seconds"
  - Body: Brief message about upcoming break
  - **Skip button**: Action to skip this break (timer restarts for next 20 min)
- Use `UNUserNotificationCenter` for notifications
- Request notification permissions on first launch

### 4. Screen Blocker

After 20 minutes (if not skipped), block all screens for 20 seconds:

- **Full-screen black overlay** on ALL displays
- Primary display shows:
  - Countdown timer (large, centered)
  - A random quote from `quotes.json` about looking away/nature/eye care
- Secondary displays: just solid black (no content)
- Window level: must appear **above fullscreen apps** (use `.screenSaver` or appropriate NSWindow.Level)
- Window should:
  - Be borderless
  - Not be closeable via standard means
  - Cover the entire screen including menu bar
  - Use `canJoinAllSpaces` collection behavior

### 5. Override Shortcut

- **Option+Shift+Escape** (`⌥⇧⎋`) dismisses the blocker immediately
- When override is used:
  - Mark this break as "skipped" (for potential future stats)
  - Restart the 20-minute timer
- Use `NSEvent.addGlobalMonitorForEvents` or similar for global hotkey

### 6. Launch at Login

- Support launching at system startup
- Use `SMAppService` (modern API) or `LSSharedFileList` for login items
- Add toggle in menu bar dropdown: "Launch at Login" with checkmark

## Data Files

### quotes.json

Create a JSON file with 20+ quotes/messages to display during breaks. Examples:

```json
{
  "quotes": [
    "Rest your eyes on the horizon. Your screen will wait.",
    "Nature never hurries, yet everything is accomplished.",
    "Look far, think deep, rest well.",
    "Your eyes work hard. Give them a moment of peace.",
    "The mountains are calling. Look toward them.",
    "Twenty seconds of rest, twenty hours of clarity.",
    "Let your gaze wander where your feet cannot.",
    "Eyes on the distance, mind at ease.",
    "A moment away from the screen is a gift to yourself.",
    "Look beyond the glass. The world is still there."
  ]
}
```

Include at least 20 varied quotes about:
- Looking away/distance
- Nature and outdoors
- Rest and relaxation
- Eye health awareness
- Mindfulness

## File Structure

```
Eyebreak/
├── Eyebreak.xcodeproj/
├── Eyebreak/
│   ├── EyebreakApp.swift          # Main app entry, menu bar setup
│   ├── AppDelegate.swift          # NSApplicationDelegate for AppKit integration
│   ├── MenuBarView.swift          # Menu bar dropdown content
│   ├── BlockerWindow.swift        # Full-screen blocker window
│   ├── BlockerView.swift          # SwiftUI view for blocker content
│   ├── TimerManager.swift         # Timer logic, sleep/wake handling
│   ├── NotificationManager.swift  # Notification handling
│   ├── HotkeyManager.swift        # Global hotkey registration
│   ├── QuoteManager.swift         # Load and serve random quotes
│   ├── LoginItemManager.swift     # Launch at login functionality
│   ├── Resources/
│   │   └── quotes.json
│   ├── Assets.xcassets/
│   └── Info.plist
└── PROMPT.md
```

## Implementation Notes

### Screen Blocking Strategy

```swift
// Create window for each screen
for screen in NSScreen.screens {
    let window = NSWindow(
        contentRect: screen.frame,
        styleMask: .borderless,
        backing: .buffered,
        defer: false
    )
    window.level = .screenSaver  // or higher if needed
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    window.backgroundColor = .black
    window.isOpaque = true
    // Set content view based on primary vs secondary
}
```

### Timer Reset on Wake

```swift
NSWorkspace.shared.notificationCenter.addObserver(
    self,
    selector: #selector(handleWake),
    name: NSWorkspace.didWakeNotification,
    object: nil
)
```

### Notification with Skip Action

```swift
let skipAction = UNNotificationAction(
    identifier: "SKIP_BREAK",
    title: "Skip",
    options: []
)
let category = UNNotificationCategory(
    identifier: "BREAK_WARNING",
    actions: [skipAction],
    intentIdentifiers: []
)
```

## Acceptance Criteria

1. App appears in menu bar with eye icon on launch
2. Timer counts down from 20 minutes
3. Notification appears 30 seconds before break with skip option
4. Clicking skip restarts the 20-minute timer
5. Screen blocks on all displays after 20 minutes
6. Primary display shows countdown + random quote
7. Secondary displays show solid black
8. Option+Shift+Escape dismisses blocker and restarts timer
9. Pause/Resume works correctly from menu bar
10. Timer resets when Mac wakes from sleep
11. Launch at login works
12. App works correctly over fullscreen apps

## Completion Promise

When all acceptance criteria are met and the app builds and runs successfully, output:

```
<promise>EYEBREAK COMPLETE</promise>
```
