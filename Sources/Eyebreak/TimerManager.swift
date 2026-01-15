import Foundation
import AppKit
import Combine

class TimerManager: ObservableObject {
    // MARK: - Config (source of truth from config.json)
    private let config = ConfigManager.shared.config

    private var workDuration: TimeInterval { config.workDuration }
    private var breakDuration: TimeInterval { config.breakDuration }
    private var warningTime: TimeInterval { config.warningTime }

    // MARK: - Published Properties
    @Published var timeRemaining: TimeInterval
    @Published var isPaused: Bool = false
    @Published var isOnBreak: Bool = false
    @Published var isInWarningPeriod: Bool = false
    @Published var breakTimeRemaining: TimeInterval

    // MARK: - Callbacks
    var onWarning: (() -> Void)?
    var onBreakStart: (() -> Void)?
    var onBreakEnd: (() -> Void)?
    var onStateChange: ((Bool) -> Void)?

    // MARK: - Private Properties
    private var workTimer: DispatchSourceTimer?
    private var breakTimer: DispatchSourceTimer?
    private var hasShownWarning: Bool = false
    private let timerQueue = DispatchQueue(label: "com.eyebreak.timer", qos: .userInteractive)

    // MARK: - Initialization
    init() {
        self.timeRemaining = ConfigManager.shared.config.workDuration
        self.breakTimeRemaining = ConfigManager.shared.config.breakDuration
        setupSleepWakeNotifications()
    }

    deinit {
        cancelWorkTimer()
        cancelBreakTimer()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    private func cancelWorkTimer() {
        workTimer?.cancel()
        workTimer = nil
    }

    private func cancelBreakTimer() {
        breakTimer?.cancel()
        breakTimer = nil
    }

    // MARK: - Public Methods
    func start() {
        guard !isPaused && !isOnBreak else { return }
        resetWorkTimer()
        startWorkTimer()
    }

    func pause() {
        isPaused = true
        cancelWorkTimer()
        onStateChange?(true)
    }

    func resume() {
        isPaused = false
        startWorkTimer()
        onStateChange?(false)
    }

    func togglePause() {
        if isPaused {
            resume()
        } else {
            pause()
        }
    }

    func skipBreak() {
        if isOnBreak {
            endBreak()
        } else {
            // Skip the upcoming break
            hasShownWarning = false
            resetWorkTimer()
            if !isPaused {
                startWorkTimer()
            }
        }
    }

    // MARK: - Private Methods
    private func resetWorkTimer() {
        timeRemaining = workDuration
        hasShownWarning = false
        isInWarningPeriod = false
    }

    private func startWorkTimer() {
        cancelWorkTimer()
        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer.schedule(deadline: .now() + 1.0, repeating: 1.0)
        timer.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.workTimerTick()
            }
        }
        workTimer = timer
        timer.resume()
    }

    private func workTimerTick() {
        guard !isPaused else { return }

        timeRemaining -= 1

        // Show warning when time remaining is at or below warning threshold
        if timeRemaining <= warningTime && !hasShownWarning {
            hasShownWarning = true
            isInWarningPeriod = true
            onWarning?()
        }

        // Start break when timer reaches 0
        if timeRemaining <= 0 {
            startBreak()
        }
    }

    private func startBreak() {
        cancelWorkTimer()
        isOnBreak = true
        breakTimeRemaining = breakDuration
        onBreakStart?()
        startBreakTimer()
    }

    private func startBreakTimer() {
        cancelBreakTimer()
        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer.schedule(deadline: .now() + 1.0, repeating: 1.0)
        timer.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.breakTimerTick()
            }
        }
        breakTimer = timer
        timer.resume()
    }

    private func breakTimerTick() {
        breakTimeRemaining -= 1

        if breakTimeRemaining <= 0 {
            endBreak()
        }
    }

    private func endBreak() {
        cancelBreakTimer()
        isOnBreak = false
        onBreakEnd?()
        resetWorkTimer()
        if !isPaused {
            startWorkTimer()
        }
    }

    // MARK: - Sleep/Wake Handling
    private func setupSleepWakeNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
    }

    @objc private func handleWake() {
        // Reset timer when Mac wakes from sleep
        if isOnBreak {
            endBreak()
        }
        hasShownWarning = false
        resetWorkTimer()
        if !isPaused {
            startWorkTimer()
        }
    }

    @objc private func handleSleep() {
        // Stop timers when Mac goes to sleep
        cancelWorkTimer()
        cancelBreakTimer()
    }

    // MARK: - Formatted Time String
    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var formattedBreakTimeRemaining: String {
        return String(format: "%d", Int(breakTimeRemaining))
    }
}
