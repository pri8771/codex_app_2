import SwiftUI

enum ChallengeKind: String, Codable, CaseIterable, Identifiable { case beam, jump, freeze, portal, crown; var id:String { rawValue }; var title:String { rawValue.capitalized }; var goal:String { "Move safely and score points." }; var seconds:TimeInterval { 15 }; var symbol:String { "sparkles" }; var tint:Color { NeonTheme.cyan } }
