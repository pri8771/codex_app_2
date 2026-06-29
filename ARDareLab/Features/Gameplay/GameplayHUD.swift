import SwiftUI

struct GameplayHUD: View {
    @ObservedObject var engine: GameEngine
    let actionText: String
    let detailText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(engine.challenge.title, systemImage: engine.challenge.symbol)
                    .font(.headline)
                Spacer()
                Label("\(engine.secondsLeft)s", systemImage: "timer")
                    .font(.headline.monospacedDigit())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(statusText)
                    .font(.title3.bold())
                Text(detailText)
                    .font(.caption)
                    .foregroundStyle(NeonTheme.softText)
            }

            ProgressView(value: engine.progress)
                .tint(engine.challenge.tint)

            HStack {
                StarsView(count: engine.result.stars)
                Spacer()
                Label("\(engine.hits)", systemImage: "bolt.slash.fill")
                    .foregroundStyle(engine.hits > 0 ? NeonTheme.orange : NeonTheme.softText)
                Text(engine.result.score.pointsText)
                    .font(.headline.monospacedDigit())
            }
        }
        .padding(14)
        .background(.black.opacity(0.58))
    }

    private var statusText: String {
        switch engine.state {
        case .idle, .intro:
            return engine.challenge.goal
        case .scanning:
            return "Scanning"
        case .countdown(let value):
            return "\(value)"
        case .running:
            return actionText
        case .success:
            return "Complete"
        case .failed(let reason):
            return reason
        case .complete:
            return "Round done"
        }
    }
}
