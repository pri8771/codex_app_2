import SwiftUI

struct MainTabView: View { var body: some View { TabView { NavigationStack { HomeView() }.tabItem { Label("Home", systemImage: "house.fill") }; NavigationStack { PlayView() }.tabItem { Label("Play", systemImage: "gamecontroller.fill") }; NavigationStack { PacksView() }.tabItem { Label("Packs", systemImage: "shippingbox.fill") }; NavigationStack { LeaderboardView() }.tabItem { Label("Scores", systemImage: "trophy.fill") }; NavigationStack { SettingsView() }.tabItem { Label("Settings", systemImage: "gearshape.fill") } }.tint(NeonTheme.cyan) } }
