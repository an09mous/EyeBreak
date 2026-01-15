import AppKit
import SwiftUI

class WarningWindowController {
    // MARK: - Properties
    private var window: NSWindow?
    private var dismissWorkItem: DispatchWorkItem?
    var onSkip: (() -> Void)?

    // MARK: - Public Methods
    func showWarning(secondsRemaining: Int) {
        // Cancel any pending dismiss
        dismissWorkItem?.cancel()
        dismissWorkItem = nil

        // Hide existing warning first
        if window != nil {
            window?.orderOut(nil)
            window = nil
        }

        let warningView = WarningView(
            secondsRemaining: secondsRemaining,
            onSkip: { [weak self] in
                self?.hideWarning()
                self?.onSkip?()
            }
        )

        let hostingView = NSHostingView(rootView: warningView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 320, height: 90)

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 90),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        newWindow.contentView = hostingView
        newWindow.backgroundColor = .clear
        newWindow.isOpaque = false
        newWindow.level = .floating
        newWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        newWindow.hasShadow = true

        // Position at top-right of main screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let windowFrame = newWindow.frame
            let x = screenFrame.maxX - windowFrame.width - 20
            let y = screenFrame.maxY - windowFrame.height - 20
            newWindow.setFrameOrigin(NSPoint(x: x, y: y))
        }

        window = newWindow
        newWindow.orderFrontRegardless()

        // Auto-dismiss after 5 seconds using DispatchWorkItem
        let workItem = DispatchWorkItem { [weak self] in
            self?.hideWarning()
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: workItem)
    }

    func hideWarning() {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil

        if let existingWindow = window {
            existingWindow.orderOut(nil)
            window = nil
        }
    }
}

// MARK: - Warning View
struct WarningView: View {
    let secondsRemaining: Int
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Friendly eye icon
            Image(systemName: "eye")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(.blue)

            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text("Break coming up")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)

                Text("Time to rest your eyes in \(secondsRemaining)s")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Skip button
            Button(action: onSkip) {
                Text("Skip")
                    .font(.system(size: 12))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
        )
    }
}
