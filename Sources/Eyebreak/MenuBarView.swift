import SwiftUI

struct MenuBarView: View {
    @ObservedObject var timerManager: TimerManager
    @StateObject private var loginItemManager = LoginItemManager()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "eye")
                    .font(.title2)
                Text("Eyebreak")
                    .font(.headline)
                Spacer()
            }
            .padding(.bottom, 4)

            Divider()

            // Timer Status
            if timerManager.isPaused {
                HStack {
                    Image(systemName: "pause.circle.fill")
                        .foregroundColor(.orange)
                    Text("Paused")
                        .foregroundColor(.secondary)
                }
            } else {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text("Next break in \(timerManager.formattedTimeRemaining)")
                }
            }

            Divider()

            // Pause/Resume Button
            Button(action: {
                timerManager.togglePause()
            }) {
                HStack {
                    Image(systemName: timerManager.isPaused ? "play.fill" : "pause.fill")
                    Text(timerManager.isPaused ? "Resume" : "Pause")
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            // Skip Break Button (only show during the 30-second warning period)
            if timerManager.isInWarningPeriod && !timerManager.isOnBreak {
                Button(action: {
                    timerManager.skipBreak()
                }) {
                    HStack {
                        Image(systemName: "forward.fill")
                        Text("Skip This Break")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }

            Divider()

            // Launch at Login Toggle
            Button(action: {
                loginItemManager.toggleLaunchAtLogin()
            }) {
                HStack {
                    Image(systemName: loginItemManager.isLaunchAtLoginEnabled ? "checkmark.square.fill" : "square")
                    Text("Launch at Login")
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            Divider()

            // Quit Button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text("Quit Eyebreak")
                    Spacer()
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(width: 250)
    }
}
