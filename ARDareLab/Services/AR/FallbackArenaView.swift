import SwiftUI

struct FallbackArenaView: View {
    let challenge: ChallengeKind
    var title = "Demo mode"
    var message: String? = nil

    var body: some View {
        ZStack {
            NeonBackground()

            VStack(spacing: 14) {
                Image(systemName: challenge.symbol)
                    .font(.system(size: 60))

                Text(title)
                    .font(.title.bold())

                Text(message ?? challenge.goal)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(NeonTheme.softText)
            }
            .padding(24)
        }
    }
}
