import SwiftUI

struct OnboardingView: View { let done: () -> Void; var body: some View { ZStack { NeonBackground(); VStack(spacing:24) { Image(systemName:"arkit").font(.system(size:72)); Text("AR Dare Lab").font(.largeTitle.bold()); Text("Turn a room into a local neon challenge arena. No account. No cloud.").multilineTextAlignment(.center).foregroundStyle(NeonTheme.softText); NeonCTA(title:"Start", icon:"play.fill", action: done) }.padding(28) } } }
