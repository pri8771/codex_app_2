# Floorless (AR Dare Lab)

_Updated 2026-06-30 to match the shipped product and launch scope. See [`LAUNCH_READINESS.md`](LAUNCH_READINESS.md)._

Local-first iOS **AR party-challenge game**. Point your iPhone at a room, pick a short neon "dare," move to clear it, and share a star-rated scorecard. No account, no backend, no cloud — everything stays on device.

> **Name note:** the portfolio/repo name is **Floorless**; the in-code product name and UI strings are **AR Dare Lab**. This mismatch is an open, launch-blocking decision (see LAUNCH_READINESS.md §7, B1).

## Stack (as actually used)
- iOS 17+, iPhone only
- SwiftUI (UI), SwiftData (local persistence)
- ARKit + RealityKit (live arena, horizontal plane detection)
- AVFoundation (camera permission)
- Simulator-safe demo mode when AR/camera is unavailable

> **Partial / stubbed (do not assume these work):**
> - **Vision** is listed but not implemented — live challenge metrics track the *phone's* motion, not the player's body (`BodyPoseAnalyzer.analyze` returns demo data; no `VNDetectHumanBodyPose`).
> - **ReplayKit** clip recording is a stub and is unused; sharing currently exports a plain-text scorecard, not an image or video.
> - **StoreKit 2** loads products but purchase/restore are faked (no real transactions or entitlement verification).
>
> See LAUNCH_READINESS.md for the full Built/Partial/Not-built status and bug triage.

## Challenges
Beam Dodge, Lava Jump, Freeze Pose, Portal Hunt, Crown Balance. Recommended proving challenge for the first on-device playtest: **Freeze Pose**.

## Build & run
Open `codex_app_2.xcodeproj` in Xcode 16+ and run the **`ARDareLab`** scheme. On the simulator (or an AR-incapable device) the app runs in demo mode so the full loop is playable without a device.

## Tests
`ARDareLabTests` covers the pure game logic: `ChallengeRuleEvaluator`, `GameEngine`, `ScoreCalculator`. UI, AR, Vision, Store, and Recording are not yet covered.

## Status
**Building** (working SwiftUI app + unit tests; partial AR/gameplay loop; never run on AR hardware). Launch scope, feature acceptance criteria, known limitations, and the launch checklist are in [`LAUNCH_READINESS.md`](LAUNCH_READINESS.md). Project documentation: [`docs/PROJECT_DOCUMENTATION.md`](docs/PROJECT_DOCUMENTATION.md).
