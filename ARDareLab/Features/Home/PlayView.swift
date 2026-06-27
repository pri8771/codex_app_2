import SwiftUI

struct PlayView: View { @EnvironmentObject private var store: StoreService; var body: some View { ZStack { NeonBackground(); List { ForEach(ChallengePack.all) { pack in Section(pack.title) { ForEach(pack.challenges) { kind in NavigationLink { SafetyWarningView(challenge:kind, packID:pack.id) } label: { HStack { ChallengeBadge(kind:kind); Spacer(); if !store.hasPack(pack) { Image(systemName:"lock.fill") } } }.disabled(!store.hasPack(pack)) } } } }.scrollContentBackground(.hidden) }.navigationTitle("Play") } }
