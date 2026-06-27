import SwiftUI

struct NeonBackground: View { var body: some View { LinearGradient(colors:[NeonTheme.ink, .black, NeonTheme.panel], startPoint:.topLeading, endPoint:.bottomTrailing).ignoresSafeArea() } }
