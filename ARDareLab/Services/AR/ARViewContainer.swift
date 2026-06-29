import SwiftUI

struct ARViewContainer: View {
    let challenge: ChallengeKind
    @ObservedObject var gameplayState: ARGameplayState

    @StateObject private var sessionManager = ARSessionManager()

    var body: some View {
        Group {
            if sessionManager.canStartAR {
                RealityArenaView(challenge: challenge, gameplayState: gameplayState)
                    .ignoresSafeArea()
            } else {
                FallbackArenaView(
                    challenge: challenge,
                    title: sessionManager.fallbackTitle,
                    message: sessionManager.fallbackMessage
                )
            }
        }
        .task {
            await sessionManager.requestCameraAccessIfNeeded()
            syncGameplayReadiness()
        }
        .onAppear {
            syncGameplayReadiness()
        }
        .onChange(of: sessionManager.cameraPermission) {
            syncGameplayReadiness()
        }
    }

    private func syncGameplayReadiness() {
        switch sessionManager.cameraPermission {
        case .authorized:
            break
        case .notDetermined:
            gameplayState.setWaiting(sessionManager.fallbackMessage)
        case .unavailable, .denied:
            gameplayState.setFallback(sessionManager.fallbackMessage)
        }
    }
}

#if canImport(ARKit) && canImport(RealityKit)
import ARKit
import RealityKit
import UIKit
import simd

private struct RealityArenaView: UIViewRepresentable {
    let challenge: ChallengeKind
    @ObservedObject var gameplayState: ARGameplayState

    func makeCoordinator() -> Coordinator {
        Coordinator(gameplayState: gameplayState)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.automaticallyConfigureSession = false
        context.coordinator.attach(to: arView, challenge: challenge)
        configureSession(on: arView, coordinator: context.coordinator)
        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {
        configureSession(on: arView, coordinator: context.coordinator)
        context.coordinator.setChallenge(challenge, in: arView)
    }

    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        coordinator.detach()
        uiView.session.pause()
    }

    private func configureSession(on arView: ARView, coordinator: Coordinator) {
        guard !coordinator.didStartSession, ARWorldTrackingConfiguration.isSupported else { return }

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        coordinator.didStartSession = true
    }

    @MainActor
    final class Coordinator: NSObject {
        private weak var arView: ARView?
        private let gameplayState: ARGameplayState
        var challenge: ChallengeKind?
        var didStartSession = false

        private var runtime: ArenaRuntime?
        private var displayLink: CADisplayLink?
        private var startDate = Date()
        private var originTransform: simd_float4x4?
        private var lastPosition = SIMD3<Float>(repeating: 0)
        private var lastTick = CACurrentMediaTime()
        private var stillSeconds: TimeInterval = 0
        private var centeredSeconds: TimeInterval = 0
        private var jumpCount = 0
        private var hitCount = 0
        private var lastHitTime: TimeInterval = -10
        private var jumpArmed = true

        init(gameplayState: ARGameplayState) {
            self.gameplayState = gameplayState
        }

        func attach(to arView: ARView, challenge: ChallengeKind) {
            self.arView = arView
            setChallenge(challenge, in: arView)
            addTapRecognizer(to: arView)
            startDisplayLink()
            gameplayState.setLiveReady()
        }

        func detach() {
            displayLink?.invalidate()
            displayLink = nil
        }

        func setChallenge(_ challenge: ChallengeKind, in arView: ARView) {
            guard self.challenge != challenge || runtime == nil else { return }

            self.challenge = challenge
            runtime = ArenaBuilder.build(in: arView, challenge: challenge)
            startDate = Date()
            originTransform = nil
            lastPosition = SIMD3<Float>(repeating: 0)
            lastTick = CACurrentMediaTime()
            stillSeconds = 0
            centeredSeconds = 0
            jumpCount = 0
            hitCount = 0
            lastHitTime = -10
            jumpArmed = true
            gameplayState.setLiveReady()
        }

        private func addTapRecognizer(to arView: ARView) {
            guard arView.gestureRecognizers?.contains(where: { $0.name == "PortalTapRecognizer" }) != true else { return }

            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            recognizer.name = "PortalTapRecognizer"
            arView.addGestureRecognizer(recognizer)
        }

        private func startDisplayLink() {
            guard displayLink == nil else { return }

            let link = CADisplayLink(target: self, selector: #selector(frameTick(_:)))
            link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
            link.add(to: .main, forMode: .common)
            displayLink = link
        }

        @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard challenge == .portal, let arView else { return }

            let location = recognizer.location(in: arView)
            if let entity = arView.entity(at: location), entity.name.contains("portal") {
                Haptics.tap()
                gameplayState.registerPortalTap()
            }
        }

        @objc private func frameTick(_ link: CADisplayLink) {
            guard let arView, let challenge, let runtime else { return }
            guard let transform = arView.session.currentFrame?.camera.transform else { return }

            if originTransform == nil {
                originTransform = transform
            }

            let now = CACurrentMediaTime()
            let dt = max(1.0 / 60.0, min(0.2, now - lastTick))
            lastTick = now

            let position = localCameraPosition(from: transform)
            let speed = Double(simd_length(position - lastPosition)) / dt
            lastPosition = position

            let elapsed = Date().timeIntervalSince(startDate)
            ArenaBuilder.update(runtime, challenge: challenge, elapsed: elapsed, playerX: position.x)

            updateMotionMetrics(
                challenge: challenge,
                runtime: runtime,
                arView: arView,
                position: position,
                speed: speed,
                elapsed: elapsed,
                dt: dt
            )
        }

        private func localCameraPosition(from transform: simd_float4x4) -> SIMD3<Float> {
            guard let originTransform else {
                return SIMD3<Float>(repeating: 0)
            }

            let localTransform = simd_inverse(originTransform) * transform
            return SIMD3<Float>(
                localTransform.columns.3.x,
                localTransform.columns.3.y,
                localTransform.columns.3.z
            )
        }

        private func updateMotionMetrics(
            challenge: ChallengeKind,
            runtime: ArenaRuntime,
            arView: ARView,
            position: SIMD3<Float>,
            speed: Double,
            elapsed: TimeInterval,
            dt: TimeInterval
        ) {
            var action = challenge.goal
            var detail = "Move in the camera view"

            switch challenge {
            case .beam:
                let beamX = runtime.primary.position.x
                let isHit = abs(position.x - beamX) < 0.18

                action = isHit ? "Move!" : "Dodge"
                detail = isHit ? "The beam is on you" : "Keep the lane clear"

                if isHit && elapsed - lastHitTime > 0.9 {
                    lastHitTime = elapsed
                    hitCount += 1
                    Haptics.tap()
                }
            case .jump:
                action = "Lift"
                detail = "\(jumpCount)/3 clears"

                if position.y > 0.18, jumpArmed {
                    jumpCount += 1
                    jumpArmed = false
                    Haptics.tap()
                } else if position.y < 0.06 {
                    jumpArmed = true
                }
            case .freeze:
                if speed < 0.08 {
                    stillSeconds += dt
                    action = "Hold"
                    detail = String(format: "%.1fs still", stillSeconds)
                } else {
                    stillSeconds = max(0, stillSeconds - dt * 0.8)
                    action = "Freeze"
                    detail = "Too much motion"

                    if elapsed - lastHitTime > 1.0 {
                        lastHitTime = elapsed
                        hitCount += 1
                    }
                }
            case .portal:
                action = "Tap"
                detail = "Hit the portal"
            case .crown:
                let centered = isTargetCentered(runtime.target, in: arView)

                if centered {
                    centeredSeconds += dt
                    action = "Steady"
                    detail = String(format: "%.1fs centered", centeredSeconds)
                } else {
                    centeredSeconds = max(0, centeredSeconds - dt * 0.45)
                    action = "Center"
                    detail = "Aim at the crown"
                }
            }

            let pose = PoseMetrics(
                isBodyFound: true,
                stillSeconds: stillSeconds,
                headCenteredSeconds: centeredSeconds,
                jumpCount: jumpCount,
                sway: speed
            )

            gameplayState.update(pose: pose, hits: hitCount, actionText: action, detailText: detail)
        }

        private func isTargetCentered(_ target: Entity?, in arView: ARView) -> Bool {
            guard let target else { return false }

            let targetPosition = target.position(relativeTo: nil)
            guard let point = arView.project(targetPosition) else { return false }

            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
            let distance = hypot(point.x - center.x, point.y - center.y)
            return distance < 85
        }
    }
}
#else
private struct RealityArenaView: View {
    let challenge: ChallengeKind
    @ObservedObject var gameplayState: ARGameplayState

    var body: some View {
        FallbackArenaView(challenge: challenge)
    }
}
#endif
