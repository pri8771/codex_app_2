# Floorless (AR Dare Lab) — Project Documentation

_Updated 2026-06-30 to match the shipped product and launch scope. See LAUNCH_READINESS.md._

> **Doc-correction note.** An earlier version of this file described Floorless as a provisional "instability / movement-risk / survival-without-safe-ground arcade" candidate. That concept does **not** match the code in this repo. The repo is a local-first **AR party-challenge game** (in-code product name "AR Dare Lab"). This file has been rewritten to reflect the real product. The authoritative launch scope, feature status, and bug triage live in [`LAUNCH_READINESS.md`](../LAUNCH_READINESS.md). GitHub is the source of truth; Notion indexes this file in the Priyansh App Factory Command Center.

> **Open decision — product name.** Portfolio/repo name is **Floorless**; all code, bundle id (`com.ardarelab.app`), and UI strings say **AR Dare Lab**. This mismatch must be resolved before launch (LAUNCH_READINESS.md §7, B1). This doc uses "Floorless (AR Dare Lab)" until then.

## 00. Executive Summary
Floorless (AR Dare Lab) is a local-first iOS AR party-challenge game. Point an iPhone at a room, pick a 15–20 second neon "dare," move to clear it, and get a star-rated scorecard you can share. It is for small in-person groups (2–6 people) who want a fast, funny, no-setup physical game. No account, no backend, no cloud — everything stays on device. The end product should be a focused, genuinely-fun party loop proven on real hardware, or a clearly archived concept.

Implementation maturity: **Building**. The SwiftUI app compiles (iOS 17+), the full UI loop is wired (onboarding → home → play → safety → gameplay → results → leaderboard), SwiftData persistence works, and three pure-logic units are unit-tested. Several README-listed capabilities are stubs/demo-only: Vision body-pose is not implemented (live play tracks phone motion), ReplayKit clip recording is a stub, StoreKit purchase/restore are faked, and sharing exports a plain-text scorecard. Never validated on a physical AR device.

## 01. Product
**Core loop:** pick a dare → clear your space → play one short round → see score/stars → share or replay.
**Five challenges:** Beam Dodge, Lava Jump, Freeze Pose, Portal Hunt, Crown Balance.
**MVP scope:** one short AR challenge round end-to-end, scoring + 0–3 stars, local high-score/history, simple settings, a mandatory safety gate, and a shareable scorecard. **Acceptance:** the loop is explainable in one sentence and is fun for a small group in a real room. Recommended proving challenge: **Freeze Pose** (Vision-aligned, inherently safe, fast, social).

## 02. Design
Neon-on-dark arcade style (`NeonTheme`), high contrast, large legible HUD with timer, action prompt, progress, stars, hits, and score. Screens: onboarding, home dashboard, play/challenge list, **safety warning**, AR gameplay HUD, results, leaderboard, packs, paywall, settings. Failure/success feedback via haptics and clear status text. Safety-first framing for a movement game.

## 03. Frontend Technical
SwiftUI shell + SwiftData. AR via ARKit `ARWorldTrackingConfiguration` (horizontal plane detection) and RealityKit entities (`ARViewContainer`, `ArenaBuilder`). A simulator-safe demo mode (`FallbackArenaView` + `BodyPoseAnalyzer.demoTick`) lets the full loop run without a device. Game logic is isolated and testable: `GameEngine` (state machine), `ChallengeRuleEvaluator` (win/lose), `ScoreCalculator` (0–1000 + stars). SwiftData models: `GameSessionRecord`, `ExportRecord`, `PlayerProfile`.

Known fidelity gap: "pose" metrics are derived from the **phone's** camera transform (device motion), not the player's body — `BodyPoseAnalyzer.analyze` always returns demo metrics and no `VNDetectHumanBodyPose` exists. This must be resolved (implement real Vision, or re-label honestly) before launch.

## 04. Backend Technical
**No backend for v1.** No accounts, no cloud, no sync, no remote leaderboards. All data is on-device (SwiftData) and exports stay local until the user shares. Future, only if play proves fun and demand exists: optional online leaderboards or daily challenges — explicitly deferred.

## 05. Business
**Defer monetization until live play is proven fun.** StoreKit 2 scaffolding exists (free base pack, a locked Neon Arcade pack, Pro monthly/yearly, 5 free shares/day) but `StoreService.buy`/`restore` are **not real purchases** and unlock content without payment. For v1, hide/disable all purchase UI, or implement a real StoreKit 2 flow with entitlement verification before exposing it. Future models: Pro unlock, challenge packs, party mode, no-watermark sharing.

## 06. Marketing
Positioning: "Turn your room into a party game." Shareable object: a neon scorecard (and, later, a safe highlight clip of the funny moment). Channels: short demo videos of a group playing Freeze Pose, scorecard shares. Marketing must never frame unsafe physical stunts as the goal.

## 07. User Acquisition
Beta with 10–20 small-group testers playing in real rooms. Metrics (beta-observable, local, privacy-respecting): rounds per session, repeat sessions in a sitting, share taps, and qualitative fun. North-star: a group plays ≥3 rounds in one sitting and shares ≥1 scorecard.

## 08. Execution
Plan: (1) resolve the Floorless/AR Dare Lab name; (2) complete the safety gate; (3) validate Freeze Pose on a physical device (go/no-go); (4) resolve Vision truthfulness; (5) ship an image scorecard; (6) make monetization safe (hide or implement); (7) complete the privacy manifest. Then balance rules, add CI, accessibility/localization. See LAUNCH_READINESS.md §8 for the ordered checklist.

## 09. QA
Test launch, onboarding gate, challenge selection, safety gate, the demo-mode loop on simulator, scoring/stars, persistence, leaderboard sort, share rate-limit, and settings. Add a UI smoke test (onboarding → demo round → results) and CI (`xcodebuild test`). Physical-device AR validation is mandatory and cannot be covered by the simulator.

## 10. Legal / Compliance
No account or backend for v1, so data-collection exposure is minimal. Complete `PrivacyInfo.xcprivacy` (required-reason API codes for UserDefaults and file timestamps) before submission; remove the unused microphone permission. Camera/Vision processing is on-device only and not recorded or uploaded — state this in the permission copy and listing. Age rating likely 4+/9+; movement-game safety copy is mandatory.

## 11. Operations
Release only after the name is resolved, the safety gate is complete, Freeze Pose is validated on-device, the privacy manifest is clean, and monetization is either hidden or real. If the live-play test shows the loop isn't fun, hold or archive rather than ship breadth on an unproven loop.
