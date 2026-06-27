import SwiftUI

struct MetricPill: View { let title: String; let value: String; var color: Color = NeonTheme.cyan; var body: some View { VStack(spacing:5) { Text(value).font(.title3.bold()); Text(title).font(.caption).foregroundStyle(NeonTheme.softText) }.frame(maxWidth:.infinity).padding(.top,12).padding(.bottom,12).background(RoundedRectangle(cornerRadius:16).fill(color.opacity(0.15))) } }
