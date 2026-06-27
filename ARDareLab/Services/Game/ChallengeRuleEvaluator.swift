import Foundation

struct ChallengeInput: Equatable { var elapsed: TimeInterval; var pose: PoseMetrics; var portalTapped = false; var hits = 0 }
enum ChallengeOutcome: Equatable { case running(Double), won, lost(String) }
enum ChallengeRuleEvaluator { static func eval(kind: ChallengeKind, input: ChallengeInput) -> ChallengeOutcome { if input.portalTapped { return .won }; if input.elapsed >= kind.seconds { return .won }; return .running(input.elapsed / kind.seconds) } }
