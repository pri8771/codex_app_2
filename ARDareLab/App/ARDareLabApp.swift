import SwiftUI
import SwiftData

@main
struct ARDareLabApp: App {
    @StateObject private var store = StoreService()
    var body: some Scene { WindowGroup { RootView().environmentObject(store).task { await store.load() } }.modelContainer(for: [GameSessionRecord.self, ExportRecord.self, PlayerProfile.self]) }
}
