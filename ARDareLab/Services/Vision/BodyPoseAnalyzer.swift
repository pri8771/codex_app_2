import Foundation
import CoreVideo

actor BodyPoseAnalyzer { func analyze(pixelBuffer: CVPixelBuffer?, at date: Date = .now) async -> PoseMetrics { .demo }; func demoTick(kind: ChallengeKind, elapsed: TimeInterval) -> PoseMetrics { var p = PoseMetrics.demo; p.stillSeconds = kind == .freeze ? elapsed : 0; p.headCenteredSeconds = kind == .crown ? elapsed : 0; p.jumpCount = kind == .jump ? min(3, Int(elapsed / 2)) : 0; return p } }
