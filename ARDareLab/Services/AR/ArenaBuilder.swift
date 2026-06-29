#if canImport(RealityKit)
import RealityKit
import UIKit

struct ArenaRuntime {
    let anchor: AnchorEntity
    let primary: ModelEntity
    let target: Entity?
}

enum ArenaBuilder {
    static func build(in ar: ARView, challenge: ChallengeKind) -> ArenaRuntime {
        for anchor in ar.scene.anchors {
            ar.scene.removeAnchor(anchor)
        }

        let anchor = AnchorEntity(world: SIMD3<Float>(0, 0, -1.15))
        addFloor(to: anchor)
        let runtime = addChallengeMarker(to: anchor, challenge: challenge)
        ar.scene.addAnchor(anchor)

        return ArenaRuntime(anchor: anchor, primary: runtime.primary, target: runtime.target)
    }

    static func update(_ runtime: ArenaRuntime, challenge: ChallengeKind, elapsed: TimeInterval, playerX: Float) {
        switch challenge {
        case .beam:
            runtime.primary.position.x = sin(Float(elapsed) * 1.45) * 0.56
            runtime.primary.orientation = simd_quatf(angle: sin(Float(elapsed) * 0.7) * 0.25, axis: SIMD3<Float>(0, 0, 1))
            runtime.primary.model?.materials = [material(for: .beam, isHot: abs(playerX - runtime.primary.position.x) < 0.18)]
        case .jump:
            let pulse = max(0, sin(Float(elapsed) * 2.4))
            runtime.primary.position.y = -0.44 + pulse * 0.16
            runtime.primary.scale = SIMD3<Float>(1, 1 + pulse * 0.6, 1)
        case .freeze:
            let pulse = 1 + sin(Float(elapsed) * 3) * 0.06
            runtime.primary.scale = SIMD3<Float>(repeating: pulse)
        case .portal:
            runtime.primary.position.x = sin(Float(elapsed) * 0.85) * 0.34
            runtime.primary.position.y = -0.12 + cos(Float(elapsed) * 0.7) * 0.16
        case .crown:
            runtime.primary.position.x = sin(Float(elapsed) * 0.65) * 0.28
            runtime.primary.position.y = 0.02 + cos(Float(elapsed) * 0.5) * 0.12
        }
    }

    private static func addFloor(to anchor: AnchorEntity) {
        let material = SimpleMaterial(
            color: UIColor.systemTeal.withAlphaComponent(0.22),
            roughness: 0.6,
            isMetallic: false
        )
        let floor = ModelEntity(
            mesh: .generateBox(width: 1.5, height: 0.02, depth: 1.5),
            materials: [material]
        )
        floor.position = SIMD3<Float>(0, -0.55, 0)
        anchor.addChild(floor)
    }

    private static func addChallengeMarker(to anchor: AnchorEntity, challenge: ChallengeKind) -> (primary: ModelEntity, target: Entity?) {
        switch challenge {
        case .beam:
            let beam = makeBox(size: (0.28, 0.98, 0.08), position: SIMD3<Float>(0, -0.1, 0), challenge: challenge)
            beam.name = "beam"
            anchor.addChild(beam)
            addLaneMarkers(to: anchor)
            return (beam, beam)
        case .jump:
            let lava = makeBox(size: (1.15, 0.08, 0.12), position: SIMD3<Float>(0, -0.44, 0), challenge: challenge)
            lava.name = "lava"
            anchor.addChild(lava)
            let marker = makeBox(size: (0.1, 0.1, 0.1), position: SIMD3<Float>(0, -0.18, 0), challenge: challenge)
            marker.name = "jump-marker"
            anchor.addChild(marker)
            return (lava, marker)
        case .freeze:
            let orb = makeSphere(radius: 0.2, position: SIMD3<Float>(0, -0.08, 0), challenge: challenge)
            orb.name = "freeze-orb"
            anchor.addChild(orb)
            return (orb, orb)
        case .portal:
            let portal = addPortal(to: anchor, challenge: challenge)
            return (portal, portal)
        case .crown:
            let crown = addCrown(to: anchor, challenge: challenge)
            return (crown, crown)
        }
    }

    private static func addLaneMarkers(to anchor: AnchorEntity) {
        let left = makeBox(size: (0.04, 0.02, 1.0), position: SIMD3<Float>(-0.7, -0.53, 0), challenge: .beam)
        let right = makeBox(size: (0.04, 0.02, 1.0), position: SIMD3<Float>(0.7, -0.53, 0), challenge: .beam)
        left.model?.materials = [SimpleMaterial(color: UIColor.white.withAlphaComponent(0.4), roughness: 0.5, isMetallic: false)]
        right.model?.materials = [SimpleMaterial(color: UIColor.white.withAlphaComponent(0.4), roughness: 0.5, isMetallic: false)]
        anchor.addChild(left)
        anchor.addChild(right)
    }

    private static func addPortal(to anchor: AnchorEntity, challenge: ChallengeKind) -> ModelEntity {
        let portal = makeBox(size: (0.7, 0.7, 0.08), position: SIMD3<Float>(0, -0.12, 0), challenge: challenge)
        portal.name = "portal-target"
        portal.generateCollisionShapes(recursive: true)
        anchor.addChild(portal)

        let center = makeSphere(radius: 0.18, position: SIMD3<Float>(0, -0.12, 0.08), challenge: challenge)
        center.name = "portal-core"
        center.generateCollisionShapes(recursive: true)
        portal.addChild(center)

        return portal
    }

    private static func addCrown(to anchor: AnchorEntity, challenge: ChallengeKind) -> ModelEntity {
        let crown = makeBox(size: (0.46, 0.06, 0.08), position: SIMD3<Float>(0, 0.04, 0), challenge: challenge)
        crown.name = "crown-target"
        anchor.addChild(crown)

        let left = makeBox(size: (0.08, 0.28, 0.08), position: SIMD3<Float>(-0.18, 0.14, 0), challenge: challenge)
        let middle = makeBox(size: (0.08, 0.34, 0.08), position: SIMD3<Float>(0, 0.18, 0), challenge: challenge)
        let right = makeBox(size: (0.08, 0.28, 0.08), position: SIMD3<Float>(0.18, 0.14, 0), challenge: challenge)
        crown.addChild(left)
        crown.addChild(middle)
        crown.addChild(right)

        return crown
    }

    private static func makeBox(
        size: (width: Float, height: Float, depth: Float),
        position: SIMD3<Float>,
        challenge: ChallengeKind
    ) -> ModelEntity {
        let entity = ModelEntity(
            mesh: .generateBox(width: size.width, height: size.height, depth: size.depth),
            materials: [material(for: challenge)]
        )
        entity.position = position
        entity.generateCollisionShapes(recursive: true)
        return entity
    }

    private static func makeSphere(
        radius: Float,
        position: SIMD3<Float>,
        challenge: ChallengeKind
    ) -> ModelEntity {
        let entity = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [material(for: challenge)]
        )
        entity.position = position
        entity.generateCollisionShapes(recursive: true)
        return entity
    }

    private static func material(for challenge: ChallengeKind, isHot: Bool = false) -> SimpleMaterial {
        let color: UIColor

        switch challenge {
        case .beam:
            color = isHot ? .systemRed : .systemCyan
        case .jump:
            color = .systemOrange
        case .freeze:
            color = .systemBlue
        case .portal:
            color = .systemPurple
        case .crown:
            color = .systemYellow
        }

        return SimpleMaterial(color: color.withAlphaComponent(0.88), roughness: 0.35, isMetallic: false)
    }
}
#endif
