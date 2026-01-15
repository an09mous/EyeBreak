# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Eyebreak is a macOS menu bar app implementing the 20-20-20 rule for eye strain prevention. Built with SwiftUI and AppKit.

## Build Commands

```bash
# Build and create app bundle (required - do not use swift run)
./build.sh

# Run the app
open Eyebreak.app

# Build release with DMG
./build.sh --release --dmg
```

**Important:** Always use `./build.sh` instead of `swift run`. The app requires a proper macOS app bundle for notifications, menu bar integration, and system features.

## Architecture

### Core Components

- **EyebreakApp.swift** - SwiftUI app entry point, minimal delegation to AppDelegate
- **AppDelegate.swift** - Main coordinator; manages menu bar, timer, and blocker lifecycle
- **TimerManager.swift** - State machine handling work/warning/break phases; observes sleep/wake
- **MenuBarView.swift** - SwiftUI view for menu bar dropdown with pause/resume/skip controls

### Window Management

- **BlockerWindow.swift** - Creates borderless NSWindows at screen level for all displays
- **BlockerView.swift** - SwiftUI view showing countdown and quotes on primary display
- **WarningWindow.swift** - 30-second pre-break notification with skip option

### Utilities

- **ConfigManager.swift** - Loads timing config from bundled JSON
- **QuoteManager.swift** - Random quote selection from bundled JSON
- **HotkeyManager.swift** - Global hotkey (⌥⇧⎋) using Carbon APIs
- **LoginItemManager.swift** - SMAppService for launch-at-login

## Key Patterns

1. **Timer States**: Work → Warning → Break → Work (managed in TimerManager)
2. **Multi-Monitor**: BlockerWindow creates one window per NSScreen
3. **Sleep Handling**: Timer resets on wake via NSWorkspace notifications
4. **Menu Bar**: Uses NSStatusItem with SwiftUI MenuBarExtra

## Configuration

Edit `Sources/Eyebreak/Resources/config.json` for timing changes, then rebuild.
