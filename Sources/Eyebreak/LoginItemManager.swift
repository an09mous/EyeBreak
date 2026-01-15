import Foundation
import ServiceManagement

class LoginItemManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isLaunchAtLoginEnabled: Bool = false

    // MARK: - Initialization
    init() {
        checkLoginItemStatus()
    }

    // MARK: - Public Methods
    func toggleLaunchAtLogin() {
        if isLaunchAtLoginEnabled {
            disableLaunchAtLogin()
        } else {
            enableLaunchAtLogin()
        }
    }

    func enableLaunchAtLogin() {
        do {
            try SMAppService.mainApp.register()
            isLaunchAtLoginEnabled = true
        } catch {
            print("Failed to enable launch at login: \(error.localizedDescription)")
        }
    }

    func disableLaunchAtLogin() {
        do {
            try SMAppService.mainApp.unregister()
            isLaunchAtLoginEnabled = false
        } catch {
            print("Failed to disable launch at login: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Methods
    private func checkLoginItemStatus() {
        isLaunchAtLoginEnabled = SMAppService.mainApp.status == .enabled
    }
}
