import Foundation

struct AppConfig: Codable {
    let workDurationMinutes: Int
    let breakDurationSeconds: Int
    let warningTimeSeconds: Int

    // Computed properties for TimeInterval values
    var workDuration: TimeInterval {
        TimeInterval(workDurationMinutes * 60)
    }

    var breakDuration: TimeInterval {
        TimeInterval(breakDurationSeconds)
    }

    var warningTime: TimeInterval {
        TimeInterval(warningTimeSeconds)
    }

    // Default fallback values
    static let fallback = AppConfig(
        workDurationMinutes: 20,
        breakDurationSeconds: 20,
        warningTimeSeconds: 30
    )
}

class ConfigManager {
    // MARK: - Singleton
    static let shared = ConfigManager()

    // MARK: - Properties
    let config: AppConfig

    // MARK: - Initialization
    private init() {
        config = ConfigManager.loadConfig()
    }

    // MARK: - Private Methods
    private static func loadConfig() -> AppConfig {
        // Try to load from bundle
        guard let url = Bundle.main.url(forResource: "config", withExtension: "json") else {
            print("config.json not found in bundle, using fallback values")
            return AppConfig.fallback
        }

        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(AppConfig.self, from: data)
            print("Loaded config: work=\(config.workDurationMinutes)min, break=\(config.breakDurationSeconds)s, warning=\(config.warningTimeSeconds)s")
            return config
        } catch {
            print("Failed to load config: \(error.localizedDescription), using fallback values")
            return AppConfig.fallback
        }
    }
}
