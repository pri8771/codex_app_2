import Foundation

@MainActor
final class ARGameplayState: ObservableObject {
    @Published private(set) var pose = PoseMetrics(isBodyFound: true)
    @Published private(set) var hits = 0
    @Published private(set) var actionText = "Scanning arena"
    @Published private(set) var detailText = "Hold the phone steady"
    @Published private(set) var isReady = false
    @Published private(set) var isLive = false

    private var pendingPortalTap = false

    func reset(for challenge: ChallengeKind) {
        pose = PoseMetrics(isBodyFound: true)
        hits = 0
        pendingPortalTap = false
        isReady = false
        isLive = false
        actionText = "Scanning arena"
        detailText = challenge.goal
    }

    func setWaiting(_ message: String) {
        isReady = false
        isLive = false
        actionText = "Preparing"
        detailText = message
    }

    func setFallback(_ message: String) {
        isReady = true
        isLive = false
        actionText = "Demo arena"
        detailText = message
    }

    func setLiveReady() {
        isReady = true
        isLive = true
    }

    func update(pose: PoseMetrics, hits: Int, actionText: String, detailText: String) {
        self.pose = pose
        self.hits = hits
        self.actionText = actionText
        self.detailText = detailText
        isReady = true
        isLive = true
    }

    func registerHit() {
        hits += 1
    }

    func registerPortalTap() {
        pendingPortalTap = true
        actionText = "Portal captured"
        detailText = "Nice tap"
    }

    func consumePortalTap() -> Bool {
        let didTap = pendingPortalTap
        pendingPortalTap = false
        return didTap
    }
}
