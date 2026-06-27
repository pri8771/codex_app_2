import SwiftUI

struct ChallengeBadge: View { let kind: ChallengeKind; var body: some View { HStack { Image(systemName: kind.symbol); Text(kind.title) }.font(.caption.bold()).padding(.horizontal,10).padding(.top,7).padding(.bottom,7).background(Capsule().fill(kind.tint.opacity(0.2))) } }
