import Foundation

class QuoteManager {
    // MARK: - Properties
    private var quotes: [String] = []
    private var lastQuoteIndex: Int = -1

    // MARK: - Singleton
    static let shared = QuoteManager()

    // MARK: - Initialization
    private init() {
        loadQuotes()
    }

    // MARK: - Load Quotes
    private func loadQuotes() {
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json") else {
            print("quotes.json not found in bundle")
            loadFallbackQuotes()
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(QuotesData.self, from: data)
            quotes = decoded.quotes
        } catch {
            print("Failed to load quotes: \(error.localizedDescription)")
            loadFallbackQuotes()
        }
    }

    private func loadFallbackQuotes() {
        quotes = [
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

    // MARK: - Get Random Quote
    func getRandomQuote() -> String {
        guard !quotes.isEmpty else {
            return "Take a moment to rest your eyes."
        }

        // Avoid repeating the same quote twice in a row
        var newIndex: Int
        repeat {
            newIndex = Int.random(in: 0..<quotes.count)
        } while newIndex == lastQuoteIndex && quotes.count > 1

        lastQuoteIndex = newIndex
        return quotes[newIndex]
    }
}

// MARK: - Data Model
private struct QuotesData: Codable {
    let quotes: [String]
}
