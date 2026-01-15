import AppKit
import SwiftUI

class BlockerWindowController {
    // MARK: - Properties
    private var windows: [NSWindow] = []
    var timerManager: TimerManager?

    // MARK: - Public Methods
    func showBlocker() {
        hideBlocker() // Clean up any existing windows

        let screens = NSScreen.screens
        guard let primaryScreen = screens.first else { return }

        for screen in screens {
            let window = createBlockerWindow(for: screen, isPrimary: screen == primaryScreen)
            window.orderFrontRegardless()
            windows.append(window)
        }
    }

    func hideBlocker() {
        let windowsToClose = windows
        windows.removeAll()

        for window in windowsToClose {
            window.contentView = nil  // Remove SwiftUI view first
            window.orderOut(nil)
        }
    }

    // MARK: - Private Methods
    private func createBlockerWindow(for screen: NSScreen, isPrimary: Bool) -> NSWindow {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.backgroundColor = .black
        window.isOpaque = true
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.acceptsMouseMovedEvents = false

        // Make window appear on all spaces and above fullscreen apps
        window.setFrame(screen.frame, display: true)

        if isPrimary, let timerManager = timerManager {
            // Primary screen shows countdown and quote
            let blockerView = BlockerView(timerManager: timerManager)
            window.contentView = NSHostingView(rootView: blockerView)
        } else {
            // Secondary screens show solid black
            window.contentView = NSView()
            window.contentView?.wantsLayer = true
            window.contentView?.layer?.backgroundColor = NSColor.black.cgColor
        }

        return window
    }
}
