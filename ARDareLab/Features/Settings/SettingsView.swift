import SwiftUI

struct SettingsView: View { @EnvironmentObject private var store: StoreService; @AppStorage(AppStorageKeys.waterMark) private var waterMark = true; var body: some View { Form { Section("Privacy") { Text("No account, backend, cloud sync, or ads. Clips and scorecards stay local until you share.") }; Section("Sharing") { Toggle("Add scorecard mark", isOn:$waterMark) }; Section("Store") { Toggle("Pro demo flag", isOn:$store.isPro); Text("Sync buys").onTapGesture { Task { await store.restore() } } } }.navigationTitle("Settings") } }
