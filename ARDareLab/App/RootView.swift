import SwiftUI

struct RootView: View { @AppStorage(AppStorageKeys.hasSeenIntro) private var hasSeenIntro = false; var body: some View { Group { if hasSeenIntro { MainTabView() } else { OnboardingView { hasSeenIntro = true } } }.preferredColorScheme(.dark) } }
