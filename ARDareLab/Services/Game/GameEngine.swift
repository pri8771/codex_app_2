import SwiftUI

@MainActor
final class GameEngine: ObservableObject {
    @Published private(set) var state: GameState = .idle
    @Published private(set) var progress = 0.0
    @Published private(set) var secondsLeft = 0
    @Published private(set) var hits = 0
    @Published private(set) var result = ScoreBreakdown(score: 0, stars: 0)
    @Published private(set) var didWin = false

    private(set) var challenge: ChallengeKind = .beam

    func prepare(_ kind: ChallengeKind) {
        challenge = kind
        progress = 0
        hits = 0
        secondsLeft = Int(kind.seconds)
        result = ScoreBreakdown(score: 0, stars: 0)
        didWin = false
        state = .intro
    }

    func scan() {
        state = .scanning
    }

    func startNow() {
        state = .running
    }

    func tick(input: ChallengeInput) {
        guard state == .running else { return }

        secondsLeft = max(0, Int(ceil(challenge.seconds - input.elapsed)))
        hits = input.hits

        switch ChallengeRuleEvaluator.eval(kind: challenge, input: input) {
        case .running(let p):
            progress = p.clamped()
            result = ScoreCalculator.score(
                accuracy: max(0.2, 1.0 - Double(input.hits) * 0.16),
                progress: progress,
                penalty: input.hits,
                didWin: false
            )
        case .won:
            finish(didWin: true, progress: 1, penalty: input.hits)
        case .lost(let reason):
            finish(didWin: false, progress: progress, penalty: input.hits, failureReason: reason)
        }
    }

    func finish(didWin: Bool, progress: Double, penalty: Int, failureReason: String? = nil) {
        self.didWin = didWin
        self.progress = progress.clamped()
        result = ScoreCalculator.score(
            accuracy: didWin ? max(0.25, 1.0 - Double(penalty) * 0.12) : 0.35,
            progress: self.progress,
            penalty: penalty,
            didWin: didWin
        )

        if didWin {
            state = .success
        } else if let failureReason {
            state = .failed(failureReason)
        } else {
            state = .complete
        }
    }

    func reset() {
        state = .idle
    }
}
