import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var timerManager: TimerManager!
    private var warningWindowController: WarningWindowController!
    private var blockerWindowController: BlockerWindowController!
    private var hotkeyManager: HotkeyManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupManagers()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "eye", accessibilityDescription: "Eyebreak")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 200)
        popover.behavior = .transient
    }

    private func setupManagers() {
        timerManager = TimerManager()
        warningWindowController = WarningWindowController()
        blockerWindowController = BlockerWindowController()
        hotkeyManager = HotkeyManager()

        // Set up the menu bar view with the timer manager
        let menuBarView = MenuBarView(timerManager: timerManager)
        popover.contentViewController = NSHostingController(rootView: menuBarView)

        // Configure timer manager callbacks
        timerManager.onWarning = { [weak self] in
            guard let self = self else { return }
            let seconds = Int(self.timerManager.timeRemaining)
            self.warningWindowController.showWarning(secondsRemaining: seconds)
        }

        timerManager.onBreakStart = { [weak self] in
            self?.warningWindowController.hideWarning()
            self?.blockerWindowController.showBlocker()
        }

        timerManager.onBreakEnd = { [weak self] in
            self?.blockerWindowController.hideBlocker()
        }

        // Configure warning window callback for skip action
        warningWindowController.onSkip = { [weak self] in
            self?.timerManager.skipBreak()
        }

        // Configure hotkey manager callback for override (only works during break)
        hotkeyManager.onOverride = { [weak self] in
            guard let self = self, self.timerManager.isOnBreak else { return }
            self.blockerWindowController.hideBlocker()
            self.timerManager.skipBreak()
        }

        // Update status item based on timer state
        timerManager.onStateChange = { [weak self] isPaused in
            self?.updateStatusItemIcon(isPaused: isPaused)
        }

        // Pass timer manager to blocker for countdown
        blockerWindowController.timerManager = timerManager

        // Start monitoring for hotkeys
        hotkeyManager.startMonitoring()

        // Start the timer
        timerManager.start()
    }

    private func updateStatusItemIcon(isPaused: Bool) {
        if let button = statusItem.button {
            let imageName = isPaused ? "eye.slash" : "eye"
            button.image = NSImage(systemSymbolName: imageName, accessibilityDescription: "Eyebreak")
        }
    }

    @objc private func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}
