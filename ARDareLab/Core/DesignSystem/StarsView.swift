import SwiftUI

struct StarsView: View { let count: Int; var body: some View { HStack(spacing:4) { ForEach(0..<3, id:\.self) { i in Image(systemName: i < count ? "star.fill" : "star").foregroundStyle(NeonTheme.orange) } } } }
