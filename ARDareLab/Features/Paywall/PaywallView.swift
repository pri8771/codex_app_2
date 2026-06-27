import SwiftUI

struct PaywallView: View { @EnvironmentObject private var store: StoreService; var body: some View { ZStack { NeonBackground(); VStack(spacing:18) { Text("AR Dare Lab Pro").font(.largeTitle.bold()); Text("All packs, party mode, no mark on shared scorecards.").multilineTextAlignment(.center).foregroundStyle(NeonTheme.softText); ForEach(store.products, id:\.id) { product in NeonCTA(title:"Buy \(product.displayPrice)", icon:"sparkles") { Task { await store.buy(product.id) } } }; Text("Sync buys").onTapGesture { Task { await store.restore() } } }.padding(28) } } }
