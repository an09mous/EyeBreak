import SwiftUI

struct BlockerView: View {
    @ObservedObject var timerManager: TimerManager
    @State private var quote: String = ""

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                Spacer()

                // Countdown Timer
                Text(timerManager.formattedBreakTimeRemaining)
                    .font(.system(size: 120, weight: .thin, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()

                // "seconds" label
                Text("seconds")
                    .font(.title)
                    .foregroundColor(.gray)

                Spacer()

                // Quote
                Text(quote)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)
                    .frame(maxWidth: 800)

                Spacer()

                // Override hint
                Text("Press ⌥⇧⎋ to skip")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            quote = QuoteManager.shared.getRandomQuote()
        }
    }
}
