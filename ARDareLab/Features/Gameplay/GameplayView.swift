import SwiftUI
import SwiftData

struct GameplayView: View {
    let challenge: ChallengeKind
    let packID: String

    @Environment(\.modelContext) private var modelContext
    @StateObject private var engine = GameEngine()
    @StateObject private var gameplayState = ARGameplayState()

    private let analyzer = BodyPoseAnalyzer()

    @State private var task: Task<Void, any Error>?
    @State private var goResult = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(challenge: challenge, gameplayState: gameplayState)

            GameplayHUD(
                engine: engine,
                actionText: gameplayState.actionText,
                detailText: gameplayState.detailText
            )
        }
        .navigationTitle(challenge.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { begin() }
        .onDisappear {
            task?.cancel()
            task = nil
        }
        .navigationDestination(isPresented: $goResult) {
            ResultsView(
                summary: .init(
                    id: UUID(),
                    challenge: challenge,
                    score: engine.result.score,
                    stars: engine.result.stars,
                    didWin: engine.didWin
                )
            )
        }
    }

    private func begin() {
        guard task == nil else { return }

        gameplayState.reset(for: challenge)
        engine.prepare(challenge)
        engine.scan()

        task = Task { @MainActor in
            while !Task.isCancelled && !gameplayState.isReady {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }

            guard !Task.isCancelled else { return }

            engine.startNow()
            let started = Date()

            while !Task.isCancelled && engine.state == .running {
                let elapsed = Date().timeIntervalSince(started)
                let pose: PoseMetrics
                let hits: Int
                var portalTapped = gameplayState.consumePortalTap()

                if gameplayState.isLive {
                    pose = gameplayState.pose
                    hits = gameplayState.hits
                } else {
                    pose = await analyzer.demoTick(kind: challenge, elapsed: elapsed)
                    hits = 0
                    portalTapped = portalTapped || (challenge == .portal && elapsed > 4)
                }

                engine.tick(
                    input: .init(
                        elapsed: elapsed,
                        pose: pose,
                        portalTapped: portalTapped,
                        hits: hits
                    )
                )

                try? await Task.sleep(nanoseconds: 100_000_000)
            }

            guard !Task.isCancelled, engine.state.isFinished else { return }

            let record = GameSessionRecord(
                challenge: challenge,
                packID: packID,
                score: engine.result.score,
                stars: engine.result.stars,
                duration: challenge.seconds,
                didWin: engine.didWin
            )
            modelContext.insert(record)
            goResult = true
        }
    }
}
