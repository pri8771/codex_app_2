import SwiftUI
import SwiftData

struct LeaderboardView: View { @Query private var sessions: [GameSessionRecord]; var body: some View { ZStack { NeonBackground(); List { ForEach(sessions.sorted { $0.score > $1.score }) { item in HStack { ChallengeBadge(kind:item.challenge); Spacer(); StarsView(count:item.stars); Text(item.score.pointsText).bold() } } }.scrollContentBackground(.hidden) }.navigationTitle("Scores") } }
