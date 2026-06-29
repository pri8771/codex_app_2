import SwiftUI

enum ChallengeKind: String, Codable, CaseIterable, Identifiable {
    case beam, jump, freeze, portal, crown

    var id: String { rawValue }

    var title: String {
        switch self {
        case .beam:
            return "Beam Dodge"
        case .jump:
            return "Lava Jump"
        case .freeze:
            return "Freeze Pose"
        case .portal:
            return "Portal Hunt"
        case .crown:
            return "Crown Balance"
        }
    }

    var goal: String {
        switch self {
        case .beam:
            return "Dodge the sweeping beam."
        case .jump:
            return "Clear three lava pulses."
        case .freeze:
            return "Hold still for three seconds."
        case .portal:
            return "Tap the portal."
        case .crown:
            return "Keep the crown centered."
        }
    }

    var seconds: TimeInterval {
        switch self {
        case .beam:
            return 18
        case .jump, .portal:
            return 20
        case .freeze, .crown:
            return 15
        }
    }

    var requiredProgress: Double {
        switch self {
        case .beam:
            return seconds
        case .jump:
            return 3
        case .freeze, .crown:
            return 3
        case .portal:
            return 1
        }
    }

    var maxHits: Int { 4 }

    var symbol: String {
        switch self {
        case .beam:
            return "laser.burst"
        case .jump:
            return "figure.jumprope"
        case .freeze:
            return "snowflake"
        case .portal:
            return "circle.dotted"
        case .crown:
            return "crown.fill"
        }
    }

    var tint: Color {
        switch self {
        case .beam:
            return NeonTheme.cyan
        case .jump:
            return NeonTheme.lime
        case .freeze:
            return .blue
        case .portal:
            return NeonTheme.magenta
        case .crown:
            return NeonTheme.orange
        }
    }
}
