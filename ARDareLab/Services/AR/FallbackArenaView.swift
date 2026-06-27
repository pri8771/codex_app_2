import SwiftUI

struct FallbackArenaView: View { let challenge: ChallengeKind; var body: some View { ZStack { NeonBackground(); VStack(spacing:14) { Image(systemName: challenge.symbol).font(.system(size:60)); Text("Demo mode").font(.title.bold()); Text(challenge.goal).multilineTextAlignment(.center).foregroundStyle(NeonTheme.softText) }.padding(24) } } }
