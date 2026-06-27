import SwiftUI

struct NeonCard<Content: View>: View { let content: Content; init(@ViewBuilder content: () -> Content) { self.content = content() }; var body: some View { content.padding(16).background(RoundedRectangle(cornerRadius:22).fill(NeonTheme.panel.opacity(0.9))) } }
