import AppKit
import SwiftUI
import Combine

class WarningWindowController {
    // MARK: - Properties
    private var window: NSWindow?
    var onSkip: (() -> Void)?
    var onDismiss: (() -> Void)?

    // MARK: - Constants
    private let windowWidth: CGFloat = 380
    private let windowHeight: CGFloat = 90

    // MARK: - Public Methods
    func showWarning(timerManager: TimerManager) {
        // Hide existing warning first
        hideWarning()

        guard let screen = NSScreen.main else { return }

        let warningView = WarningView(
            timerManager: timerManager,
            onSkip: { [weak self] in
                self?.hideWarning()
                self?.onSkip?()
            },
            onDismiss: { [weak self] in
                self?.hideWarning()
                self?.onDismiss?()
            }
        )

        let hostingView = NSHostingView(rootView: warningView)
        hostingView.frame = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        newWindow.contentView = hostingView
        newWindow.backgroundColor = .clear
        newWindow.isOpaque = false
        newWindow.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)) + 1)
        newWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        newWindow.hasShadow = true

        // Calculate final position (top-right corner)
        let screenFrame = screen.visibleFrame
        let finalX = screenFrame.maxX - windowWidth - 20
        let y = screenFrame.maxY - windowHeight - 20

        // Position window at final location
        newWindow.setFrameOrigin(NSPoint(x: finalX, y: y))

        window = newWindow
        newWindow.orderFrontRegardless()
    }

    func hideWarning() {
        guard let existingWindow = window else { return }
        window = nil
        existingWindow.orderOut(nil)
    }
}

// MARK: - Warning View
struct WarningView: View {
    @ObservedObject var timerManager: TimerManager
    let onSkip: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Friendly eye icon
            Image(systemName: "eye")
                .font(.system(size: 26, weight: .light))
                .foregroundColor(.blue)

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text("Break coming up")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)

                Text("Time to rest your eyes in \(Int(timerManager.timeRemaining))s")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Skip button
            Button(action: onSkip) {
                Text("Skip")
                    .font(.system(size: 11))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.bordered)
            .tint(.secondary)

            // Close button
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .frame(width: 20, height: 20)
            .background(Color.secondary.opacity(0.1))
            .clipShape(Circle())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
        )
    }
}
