import SwiftUI

struct NeonCTA: View { let title: String; var icon: String = "bolt.fill"; var color: Color = NeonTheme.cyan; var action: () -> Void; var body: some View { HStack { Image(systemName: icon); Text(title).fontWeight(.bold) }.frame(maxWidth:.infinity).padding(.top,14).padding(.bottom,14).background(Capsule().fill(color.opacity(0.22))).foregroundStyle(.white).onTapGesture { action() } } }
