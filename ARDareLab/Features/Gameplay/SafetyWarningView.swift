import SwiftUI

struct SafetyWarningView: View { let challenge: ChallengeKind; let packID: String; var body: some View { ZStack { NeonBackground(); VStack(spacing:20) { Image(systemName:"exclamationmark.triangle.fill").font(.system(size:56)).foregroundStyle(NeonTheme.orange); Text("Clear your space").font(.largeTitle.bold()); Text("Play away from stairs, pets, and sharp items. Keep jumps low.").multilineTextAlignment(.center).foregroundStyle(NeonTheme.softText); NavigationLink("I am ready") { GameplayView(challenge:challenge, packID:packID) } }.padding(28) } } }
