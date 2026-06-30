# Floorless (AR Dare Lab) — Project Status

_Updated 2026-06-30 to match the shipped product and launch scope. See [`LAUNCH_READINESS.md`](LAUNCH_READINESS.md)._

**Status: Building** (not "MVP complete").

A local-first SwiftUI AR party-challenge game is committed: the full UI loop (onboarding → home → play → safety → gameplay → results → leaderboard) is wired, SwiftData persistence works, a simulator-safe demo mode runs the loop without a device, and the core game logic (`GameEngine`, `ChallengeRuleEvaluator`, `ScoreCalculator`) is unit-tested.

**Not yet MVP-ready.** Key gaps:
- Vision body-pose is not implemented (live play tracks phone motion, not the player's body).
- ReplayKit clip recording is a stub; sharing exports plain text, not an image/video.
- StoreKit purchase/restore are faked (no real transactions or entitlement checks).
- Never validated on a physical AR device.
- Product name unresolved: **Floorless** (repo/portfolio) vs **AR Dare Lab** (code/UI/bundle).
- Privacy manifest incomplete; unused microphone permission declared.

**Estimated production readiness: ~45%.** The ordered path to 80–90%, the per-feature acceptance criteria, the launch-blocking vs non-blocking bug triage, and the full launch checklist are in [`LAUNCH_READINESS.md`](LAUNCH_READINESS.md). Recommended next action: resolve the name, complete the safety gate, then validate **Freeze Pose** on a physical device as the go/no-go.
