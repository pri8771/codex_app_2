import Foundation

enum AppRoute: Hashable { case play(ChallengeKind), result(String), paywall, pack(String) }
