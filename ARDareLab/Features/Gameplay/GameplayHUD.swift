import SwiftUI

struct GameplayHUD: View { @ObservedObject var engine: GameEngine; var body: some View { VStack { HStack { Text(engine.challenge.title).font(.headline); Spacer(); Text("\(engine.secondsLeft)s") }; ProgressView(value:engine.progress).tint(NeonTheme.cyan); HStack { StarsView(count:engine.result.stars); Spacer(); Text(engine.result.score.pointsText) } }.padding(14).background(.black.opacity(0.45)) } }
