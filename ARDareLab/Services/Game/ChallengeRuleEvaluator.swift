import Foundation

struct ChallengeInput: Equatable { var elapsed: TimeInterval; var pose: PoseMetrics; var portalTapped = false; var hits = 0 }
enum ChallengeOutcome: Equatable { case running(Double), won, lost(String) }
enum ChallengeRuleEvaluator {
    static func eval(kind: ChallengeKind, input: ChallengeInput) -> ChallengeOutcome {
        if input.hits >= kind.maxHits {
            return .lost("Too many hits")
        }

        if kind == .portal, input.portalTapped {
            return .won
        }

        let currentProgress = progress(for: kind, input: input).clamped()

        if currentProgress >= 1 {
            return .won
        }

        if input.elapsed >= kind.seconds {
            return kind == .beam || currentProgress >= 0.75 ? .won : .lost("Missed the goal")
        }

        return .running(currentProgress)
    }

    private static func progress(for kind: ChallengeKind, input: ChallengeInput) -> Double {
        switch kind {
        case .beam:
            return input.elapsed / kind.seconds
        case .jump:
            return Double(input.pose.jumpCount) / kind.requiredProgress
        case .freeze:
            return input.pose.stillSeconds / kind.requiredProgress
        case .portal:
            return input.portalTapped ? 1 : 0
        case .crown:
            return input.pose.headCenteredSeconds / kind.requiredProgress
        }
    }
}
