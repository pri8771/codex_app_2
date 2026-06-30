# Floorless (AR Dare Lab) — Launch Readiness (v1)

> _Updated 2026-06-30 to match the shipped product and launch scope. This is the canonical launch-scope artifact for this repo._

> **What it is.** Floorless is a local-first iOS AR party-challenge game: point your iPhone at a room, pick a 15–20 second neon "dare," move your body (or the phone) to clear the challenge, and walk away with a star-rated scorecard you can share. It is for small in-person groups (friends, families, dorm/house parties) who want a fast, funny, no-setup physical game. The core loop is **pick a dare → clear your space → play one short round → see score/stars → share or replay**. No account, no backend, no cloud — all play, scores, and exports stay on device.
>
> **Implementation maturity: Building (working SwiftUI app + unit tests, partial AR/gameplay loop).** The app target compiles against iOS 17, the full screen-to-screen loop is wired (onboarding → home → play list → safety gate → gameplay → results → leaderboard), SwiftData persistence works, and three pure-logic units are unit-tested. However several pieces named in the README stack are **stubs or demo-only**: the "Vision" body-pose pipeline always returns demo metrics (live play tracks *phone motion*, not a person's pose), ReplayKit clip recording is a non-functional stub, StoreKit purchase/restore are faked (no real transactions), and share output is a plain-text file, not a video clip or rendered image. ~1,257 LOC across 53 Swift files. It has **not** been validated on a physical AR device.
>
> **Naming.** The portfolio/repo name is **Floorless**; the in-code product name, bundle id (`com.ardarelab.app`), and all UI strings are **AR Dare Lab**. This mismatch is unresolved and is a launch-blocking decision (see B1). This document uses "Floorless (AR Dare Lab)" until the name is reconciled.

---

## 1. PRD / Launch Scope

**Problem & insight.** In-person social games either need props/cards (Heads Up, Jackbox needs a TV), or are passive phone-passing. There is no instant, native, *physical* iPhone party game that uses the room itself and produces a shareable "look what just happened" moment. iPhones already ship ARKit, a depth-capable camera, haptics, and ReplayKit — the hardware for a room-scale party dare game is in everyone's pocket and underused.

**Target user.**
- **Primary:** small in-person friend/family groups (2–6 people), ages ~10–45, one host iPhone, casual, no gaming skill assumed. Sharpest-pain wedge per the product discussion: groups looking for a 60-second "let's all try this" laugh.
- **Secondary:** solo players doing quick challenge runs for personal scores; later, content creators who post funny dare clips.

**Value proposition (one sentence).** Turn any room into a neon AR challenge arena in seconds — no account, no setup, no cloud — and walk away with a shareable scorecard.

**Positioning / category & pitch.** Category: casual AR party game (Games → Casual/Family). One-sentence pitch: _"Floorless turns your room into a party game — pick a dare, move, and share the scorecard."_

**Platform & tech baseline (actually used in the repo).**
- iOS 17+ (`IPHONEOS_DEPLOYMENT_TARGET = 17.0`), iPhone only (`TARGETED_DEVICE_FAMILY = 1`).
- **SwiftUI** (all UI), **SwiftData** (`GameSessionRecord`, `ExportRecord`, `PlayerProfile`).
- **ARKit + RealityKit** — live arena via `ARWorldTrackingConfiguration` (horizontal plane detection) and `RealityView`/`ARView` entities (`ARViewContainer.swift`, `ArenaBuilder.swift`).
- **AVFoundation** — camera-permission gating (`ARSessionManager.swift`).
- **StoreKit 2** — product loading only; **purchase/restore are stubbed** (`StoreService.swift`).
- **Vision** — declared in the README but **not actually wired**: `BodyPoseAnalyzer.analyze(pixelBuffer:)` always returns `.demo`; no `VNDetectHumanBodyPose` request exists. Live metrics come from the AR camera transform (device motion), not human pose.
- **ReplayKit** — imported but the recorder is a stub (`ReplayKitRecorder.stop()` returns `nil`) and is **never referenced** by any view.
- Xcode project `codex_app_2.xcodeproj`, `objectVersion = 70` (Xcode 16 file-system-synchronized groups). Scheme `ARDareLab` runs the `ARDareLabTests` bundle.

**Business model (only what the repo supports/plans).** Freemium scaffolding present but inert: a free **base pack** (all five challenges) plus a locked **Neon Arcade** pack; a **Pro** subscription (monthly/yearly) that unlocks all packs, "party mode," and removes the scorecard mark; a free **5 shares/day** cap (`AppConstants.freeDailyShareCap`). Per the product discussion, **monetization is deferred** until live play is proven fun — StoreKit should remain scaffolded, not gating, for v1.

**North-star / success signals (local-only, beta-observable; privacy-respecting).** No analytics SDK exists and none should be added silently. Beta-observable signals: rounds played per session (`GameSessionRecord` count), repeat sessions in a sitting, share taps, and qualitative "is it fun in a real room with real people" from on-device playtests. North-star: **a group plays ≥3 rounds in one sitting and shares ≥1 scorecard.**

---

## 2. MVP Feature List (with acceptance criteria)

### F1. First-run onboarding — **Built**
One-screen intro that sets the local-first promise and enters the app.
- Given a fresh install, when the app launches, then `OnboardingView` shows "AR Dare Lab", the "No account. No cloud." promise, and a Start button.
- When the user taps Start, then `AppStorageKeys.hasSeenIntro` is set `true` and the app routes to `MainTabView`.
- Given a returning user, when the app launches, then onboarding is skipped and the tab bar shows directly.

### F2. Home dashboard — **Built**
Shows lifetime stats and plan status; entry point to play.
- Given saved sessions, when Home appears, then it displays round count and best score from `@Query` over `GameSessionRecord`.
- Given Pro inactive, when Home appears, then the plan card reads "Free plan / Base pack and five shares per day."
- When the user taps "Pick a dare", then `PlayView` is pushed.

### F3. Challenge catalog & selection — **Built**
Browse the five challenges grouped by pack; locked packs are visually gated.
- Given the base pack, when `PlayView` lists challenges, then Beam Dodge, Lava Jump, Freeze Pose, Portal Hunt, Crown Balance are all selectable.
- Given a pack the user does not own (Neon Arcade), then its rows show a lock and are `.disabled`.
- When a selectable challenge is tapped, then `SafetyWarningView` is pushed (never straight into gameplay).

### F4. Safety gate before play — **Partial**
A mandatory interstitial warning before every round.
- Given any challenge tap, when navigation proceeds, then `SafetyWarningView` appears before `GameplayView` (✅ present).
- It shows a warning icon, "Clear your space", and "Play away from stairs, pets, and sharp items. Keep jumps low." (✅ present).
- **Gap (acceptance not yet met):** copy does not include the discussion-mandated guidance to **"look up from your phone, don't run into things, play in a clear space"**, and the gate can be dismissed instantly with no acknowledgement checkbox or minimum dwell. Status **Partial** until copy is expanded and a deliberate "I'm ready" affirmation is required (see B2).

### F5. AR arena (live) — **Partial**
Real ARKit arena with horizontal-plane anchoring and per-challenge 3D markers.
- Given an AR-capable device with camera authorized, when gameplay starts, then `ARWorldTrackingConfiguration` runs with `.horizontal` plane detection and `ArenaBuilder` places a floor + challenge marker ~1.15 m ahead (✅ in code).
- Per-challenge marker animation runs each frame (beam sweep, lava pulse, portal drift, crown bob) via `ArenaBuilder.update` (✅ in code).
- **Gap:** never validated on a physical device; plane-detection / tracking robustness, anchor placement, and lighting behavior are unverified. Status **Partial** pending on-device validation (see B3).

### F6. Challenge mechanics & motion tracking — **Partial**
Five challenges each map a movement to a progress/score outcome.
- Freeze Pose: hold still 3 s (`stillSeconds` accrues when camera speed < 0.08). Crown Balance: keep the crown reticle centered 3 s. Lava Jump: 3 clears (camera Y rise). Beam Dodge: avoid the swept lane for the duration. Portal Hunt: tap the portal entity. All evaluated by `ChallengeRuleEvaluator` and scored by `ScoreCalculator` (✅, unit-tested).
- **Gap 1 (fidelity):** "pose" metrics are derived from the **phone's** camera transform, not the player's body (Vision is stubbed). Freeze = phone-still, Jump = phone-up, Crown = phone-aim. This is playable but is **not** the "body pose" experience the README implies (see B4/N5).
- **Gap 2 (rules):** Beam Dodge **auto-wins at timeout regardless of hits/dodging** (`ChallengeRuleEvaluator`: `kind == .beam ? .won`); Freeze/Crown win at ≥0.75 progress at timeout. Generous-but-confusing win logic needs a deliberate balance pass (see N1).
- Status **Partial** until fidelity decision (real Vision vs. honest re-labeling) and rule balancing land.

### F7. Demo / simulator-safe mode — **Built**
Game is fully playable without a device or camera via scripted demo metrics.
- Given the simulator or an AR-incapable/denied-camera device, when gameplay runs, then `FallbackArenaView` renders and `BodyPoseAnalyzer.demoTick` feeds scripted progress so every challenge can complete.
- Given demo mode, the Portal challenge auto-taps after 4 s so the loop always reaches Results (✅).
- Demo mode lets the whole UI loop, scoring, persistence, and share path be exercised headlessly (this is what the unit tests rely on).

### F8. Scoring, stars & results — **Built**
Deterministic score (0–1000) and 0–3 stars per round, shown on a results screen.
- `ScoreCalculator.score(accuracy:progress:penalty:didWin:)` clamps to 0–1000; stars at ≥850 (3) / ≥600 (2) / ≥350 (1) (✅, unit-tested in `ScoreCalculatorTests`).
- When a round finishes, then `ResultsView` shows win/lose title, stars, score, challenge name, and a Share CTA.
- The completed round is persisted as a `GameSessionRecord` before Results appears (✅ in `GameplayView.begin`).

### F9. Local leaderboard / history — **Built**
On-device ranked list of all past rounds.
- Given saved sessions, when `LeaderboardView` ("Scores") appears, then rows are sorted by score descending with challenge badge, stars, and points.
- No network call is made; data comes only from SwiftData (✅).

### F10. Share scorecard (export) — **Partial**
Share a scorecard from the results screen, rate-limited for free users.
- When Share is tapped, then `ExportLimiter` enforces the free cap (5/day) unless Pro, an `ExportRecord` is logged, and the system share sheet opens (✅ wiring present).
- **Gap:** `ScorecardRenderer` writes a **plain `.txt` file** (`"AR Dare Lab <challenge> <score> pts"`), not a rendered image or video. There is **no** shareable visual/clip — the ReplayKit "funny moment" clip discussed in the product thread does not exist. Status **Partial** until at least a rendered image scorecard ships (see B5).

### F11. Packs & paywall (monetization scaffolding) — **Partial**
Packs catalog, a Pro paywall, and a settings store toggle.
- `PacksView` lists packs and shows Unlock/Go-Pro CTAs; `PaywallView` lists StoreKit products with prices; `SettingsView` exposes a "Pro demo flag" and "Sync buys".
- **Gap (critical):** `StoreService.buy(_:)` **does not perform a real StoreKit purchase** — it just inserts the product id into a local set and flips `isPro` if the id contains "pro". `restore()` only reloads products; there is no `Transaction.currentEntitlements` verification. Selling these as IAP would mean **paid content unlocking with no payment**. Status **Partial**; must be either fully implemented or fully removed/hidden for v1 (see B6).

### F12. Privacy posture (local-first, on-device) — **Partial**
No account/backend/cloud; camera processing stays on device.
- `SettingsView` states "No account, backend, cloud sync, or ads. Clips and scorecards stay local until you share." (✅).
- `PrivacyInfo.xcprivacy` declares no tracking and no collected data types (✅).
- **Gap:** `NSPrivacyAccessedAPITypes` is **empty**; the app uses UserDefaults (`@AppStorage`) and file timestamps (`ExportRecord.createdAt`/`Calendar`), which require declared "required reason" API codes for App Store submission. Also `NSMicrophoneUsageDescription` is present but the mic is **never used**. Status **Partial** until the privacy manifest is completed and the unused mic string removed (see B7).

---

## 3. Out of Scope (v1 non-goals)

- **No accounts, login, or user identity.** Local-first is a core promise; do not add auth.
- **No backend, cloud sync, or remote leaderboards.** Scores stay on device. (Global/online leaderboards are explicitly deferred.)
- **No real-time multiplayer / shared AR session / SharePlay.** Play is single-device, pass-the-phone.
- **No real Vision body-pose recognition in v1 unless F6/B4 is resolved in its favor.** If not, v1 ships honest "device-motion" challenges and drops "Vision" from marketing.
- **No video/ReplayKit clip capture in v1** unless B5 is taken; v1 ships an image scorecard at most.
- **No analytics, ads, tracking, or third-party SDKs.** Privacy posture forbids it.
- **No live IAP monetization gating in v1.** Per the product discussion, defer paid packs/Pro until live play proves fun; scaffolding stays hidden or clearly non-functional.
- **No dares that encourage unsafe physical stunts.** Challenges must be safe-by-design (hold still, aim, low jumps); no "run/leap/spin faster" escalation, and shares must never frame danger as the goal (guardrail from the product thread).
- **No iPad / Mac / Vision Pro / Apple Watch targets.** iPhone only.
- **No user-generated content, social feed, comments, or profiles.** Sharing is an outbound system share only.

---

## 4. User Flows

**A. First run / onboarding**
1. Launch → `RootView` checks `hasSeenIntro` (false on fresh install).
2. `OnboardingView` shows brand + "No account. No cloud." + Start.
3. Tap **Start** → `hasSeenIntro = true` → `MainTabView` (Home/Play/Packs/Scores/Settings tabs).

**B. Core loop (play a dare)**
1. **Home** → tap "Pick a dare" (or the **Play** tab).
2. **PlayView** → choose a challenge from the base pack (locked packs disabled).
3. **SafetyWarningView** → read "Clear your space" warning → tap **"I am ready"**.
4. **GameplayView** mounts `ARViewContainer`:
   - On device w/ camera: requests camera permission, runs the AR arena (live metrics from camera transform).
   - On simulator / denied / unsupported: `FallbackArenaView` + scripted demo metrics.
5. Engine: `prepare → scan → startNow → running`; a 10 Hz loop feeds `ChallengeInput` to `GameEngine.tick`, which evaluates via `ChallengeRuleEvaluator` and scores via `ScoreCalculator`; the HUD (`GameplayHUD`) shows timer, action prompt, progress, stars, hits, score.
6. On `success` / `failed` / `complete`, a `GameSessionRecord` is inserted, then **ResultsView** appears.
7. **ResultsView**: win/lose, stars, score → optionally **Share scorecard**.

**C. Settings / privacy**
1. **Settings** tab → Privacy section states the local-first promise.
2. Sharing section: toggle scorecard mark (`AppStorageKeys.waterMark`).
3. Store section: "Pro demo flag" toggle and "Sync buys" (currently a demo flag, not real entitlement).

**D. Share / export**
1. From **ResultsView**, tap **Share scorecard**.
2. `ExportLimiter.canShare` checks Pro / daily cap (5/day free).
3. `ScorecardRenderer.make` writes a `.txt` scorecard to a temp URL; an `ExportRecord` is logged.
4. iOS **ShareSheet** opens with the file. (No image/video today — see B5/F10.)

**E. Packs / paywall (scaffold)**
1. **Packs** tab → see base + locked packs; **Go Pro** → `PaywallView`.
2. Tapping Unlock/Buy calls `StoreService.buy` (currently a local flag flip, **not** a real purchase — B6).

---

## 5. Acceptance Criteria Summary

| ID | Feature | Status | Launch pass/fail gate |
|----|---------|--------|------------------------|
| F1 | Onboarding | Built | Fresh install shows intro once; returning users skip it. |
| F2 | Home dashboard | Built | Shows real round count + best score; routes to Play. |
| F3 | Challenge catalog | Built | All 5 base challenges selectable; locked packs disabled. |
| F4 | Safety gate | **Partial** | **BLOCKER B2:** must show "clear space / look up / don't run into things" and require a deliberate acknowledgement. |
| F5 | AR arena (live) | **Partial** | **BLOCKER B3:** must be validated on a physical AR device (anchor, tracking, lighting). |
| F6 | Challenge mechanics | **Partial** | **BLOCKER B4 + N1:** resolve Vision-vs-device-motion truthfulness; balance Beam/Freeze/Crown win rules. |
| F7 | Demo / sim-safe mode | Built | Every challenge completes headlessly; UI loop exercisable without a device. |
| F8 | Scoring & results | Built | Deterministic 0–1000 + 0–3 stars; results screen correct; round persisted. |
| F9 | Local leaderboard | Built | Sorted on-device history; no network. |
| F10 | Share scorecard | **Partial** | **BLOCKER B5:** ship a rendered image scorecard (not a bare `.txt`); enforce safe, non-stunt framing. |
| F11 | Packs/paywall | **Partial** | **BLOCKER B6:** real StoreKit purchase+entitlement, or remove/hide IAP for v1. |
| F12 | Privacy posture | **Partial** | **BLOCKER B7:** complete `PrivacyInfo.xcprivacy` required-reason APIs; remove unused mic string. |

A feature passes launch only when its row's gate is green. F4, F5, F6, F10, F11, F12 are all gated by launch-blocking items below.

---

## 6. Known Limitations

- **"Vision" is aspirational, not implemented.** `BodyPoseAnalyzer.analyze(pixelBuffer:)` always returns `.demo`; there is no `VNDetectHumanBodyPose`. Live challenge metrics track the **phone's** motion (camera transform), not the player's body. Freeze = phone stillness, Jump = phone lift, Crown = phone aim. The game is playable this way, but it is a different (lower-fidelity) experience than the README implies.
- **Never run on a physical AR device.** All confidence in F5/F6 live play is code-reading + demo mode only. Plane detection, tracking jitter, anchor placement at 1.15 m, and lighting are unverified.
- **ReplayKit clip recording does not exist.** `ReplayKitRecorder` is a stub returning `nil` and is referenced by no view. The "funny moment clip" from the product discussion is unbuilt.
- **Share output is text-only.** `ScorecardRenderer` writes a `.txt` string; there is no branded image or video to share, undermining the viral-share thesis.
- **StoreKit purchases are simulated.** `StoreService.buy` flips local state without a transaction; `restore` doesn't read entitlements. Monetization is non-functional and, if shipped as-is, would unlock paid content for free.
- **Challenge win rules are loose.** Beam Dodge auto-wins at timeout; Freeze/Crown win at ≥0.75 progress. Scores are generous and not yet tuned for fairness or difficulty curve.
- **Only one pack has real content variety.** Neon Arcade is just a subset (beam, portal) of the base five; House Party and Chaos product ids exist in StoreKit config but have **no** challenges defined.
- **No CI, single commit.** No automated build/test pipeline; `.github/` absent.
- **Microphone permission requested but unused.** `NSMicrophoneUsageDescription` is declared in two places; no code records audio. App Review will ask why.
- **No haptics/audio polish, no countdown visualization.** `GameState.countdown` exists but is never entered; "scanning" is instantaneous.
- **No localization.** All copy is English-only despite an all-ages/worldwide ambition.
- **No accessibility pass.** Neon-on-dark contrast, Dynamic Type, VoiceOver labels for AR HUD unverified.

---

## 7. Bug & Risk Triage

### Launch-blocking (must fix before TestFlight / App Store)

- **B1 — Product name mismatch (Floorless vs AR Dare Lab).** Repo/portfolio is "Floorless"; all code, bundle id `com.ardarelab.app`, and UI say "AR Dare Lab". *Where:* `README.md`, `PROJECT_STATUS.md`, `Info.plist`, `AppConstants.appName`, every UI string, `StoreProductID` ids, `Log` subsystem. *Why blocking:* you cannot submit/market with two names; bundle id and StoreKit ids bake the chosen name in. **Decide one canonical name first** (recommendation: choose "Floorless" as the public product name or formally keep "AR Dare Lab"; then make README + PROJECT_STATUS authoritative and align UI/bundle).
- **B2 — Safety copy incomplete & gate skippable.** *Where:* `SafetyWarningView.swift`. *Why blocking:* this is a game that makes people move physically; the product guardrail requires explicit "clear a space, look up from your phone, don't run into things, keep jumps low" copy and a deliberate acknowledgement, not an instantly-tappable screen. Physical-safety copy is not optional for a movement game.
- **B3 — Zero physical-device AR validation.** *Where:* `ARViewContainer.swift`, `ArenaBuilder.swift`, `ARSessionManager.swift`. *Why blocking:* the entire product premise (room-scale AR play) is unproven on hardware; tracking/plane/anchoring may be broken or unsafe. Per the product thread, on-device validation of **one** challenge (Freeze Pose) is the go/no-go gate before anything else.
- **B4 — Truth-in-stack: Vision is stubbed but advertised.** *Where:* `BodyPoseAnalyzer.swift`, `README.md`. *Why blocking:* shipping/marketing "Vision body pose" while the code only tracks phone motion is a correctness and App-Store-metadata risk. Either implement real `VNDetectHumanBodyPose` for at least Freeze Pose, **or** remove "Vision" from the stack and re-label challenges honestly as device-motion. Cannot ship the contradiction.
- **B5 — Share output is a `.txt` file, not a scorecard.** *Where:* `ScorecardRenderer.swift`, `ResultsView.swift`. *Why blocking:* the share loop is the growth mechanism and the current artifact (a text string) is not shareable in any compelling way; it also can't carry the required safety-positive, non-stunt framing. Ship at least a rendered image scorecard. (ReplayKit video can be deferred — see N4.)
- **B6 — StoreKit purchase/restore are fake.** *Where:* `StoreService.swift`. *Why blocking:* `buy` unlocks paid content with **no payment** and `restore` ignores entitlements. If IAP is visible at launch this is a guideline violation and revenue/trust hole. Per the decision to defer monetization, the safest v1 move is to **hide/disable all purchase UI** (Packs unlock, Paywall, Pro toggle) until a real StoreKit 2 flow with `Transaction.currentEntitlements` verification is implemented.
- **B7 — Privacy manifest incomplete; unused mic permission.** *Where:* `PrivacyInfo.xcprivacy`, `Info.plist`, build settings. *Why blocking:* `NSPrivacyAccessedAPITypes` is empty although the app uses UserDefaults and file-timestamp APIs (required-reason APIs); App Store will reject/flag. The declared `NSMicrophoneUsageDescription` with no mic use invites a review rejection. Complete the manifest and remove the unused permission.

### Non-blocking (ship-with, fix later)

- **N1 — Loose/confusing win rules.** Beam auto-wins at timeout; Freeze/Crown win at ≥0.75. *Defer rationale:* tunable values; fix during the live-play balance pass after B3, not a submission blocker.
- **N2 — House Party & Chaos packs are empty.** Product ids exist with no challenges. *Defer:* only relevant once monetization is real (B6); hide them for v1.
- **N3 — Neon Arcade pack is just a subset of base challenges.** Low value-add. *Defer:* content/packaging decision, not a blocker.
- **N4 — No ReplayKit video clip.** Stub recorder unused. *Defer:* v1 can ship with an image scorecard (B5); video is a fast-follow once safe-framing rules are set.
- **N5 — `BodyPoseAnalyzer.analyze` is dead code in the live path.** Demo path uses `demoTick`; the async `analyze` is never called. *Defer:* harmless until/unless real Vision lands (B4).
- **N6 — `countdown` GameState never entered.** No pre-round countdown UX. *Defer:* polish.
- **N7 — No CI pipeline.** *Defer:* add a GitHub Actions `xcodebuild test` workflow; nice-to-have, not gating.
- **N8 — No localization / accessibility pass.** *Defer:* needed for the worldwide/all-ages ambition but not for an initial TestFlight.
- **N9 — `Info.plist` duplicates usage strings already generated via `INFOPLIST_KEY_*` build settings.** Potential drift. *Defer:* tidy during B7.
- **N10 — Single-commit history, no `PROJECT_STATUS` detail.** *Defer:* documentation hygiene improved by this package.

---

## 8. Production-Readiness Assessment

**Current estimated readiness: ~45%.**
Justification: the app **compiles and the full UI loop is wired and persists** (F1–F3, F7–F9 are genuinely done and three core algorithms are unit-tested), which is real progress beyond scaffolding. But every pillar that makes it *this product* — on-device AR validation, honest pose/motion fidelity, a shareable artifact, safe-by-design copy, a working store, and a clean privacy manifest — is partial or stubbed, and the app has never run on AR hardware. It is a solid **Building**-stage app, not MVP-ready.

**Ordered remaining work to reach 80–90% production-ready:**
1. **Resolve the name (B1).** Pick Floorless or AR Dare Lab; update README, PROJECT_STATUS, UI strings, `AppConstants.appName`, and (if changing) bundle id + StoreKit ids. Do this first — everything downstream bakes in the name.
2. **Complete + harden the safety gate (B2).** Expand copy to "clear a space, look up from your phone, don't run into things, keep jumps low"; require a deliberate "I'm ready" affirmation; show it before every round.
3. **On-device AR validation of Freeze Pose (B3).** Build to a physical iPhone, validate plane detection, anchoring, and that "hold still 3 s" reads reliably in a real room (3–6 people). This is the product go/no-go.
4. **Resolve Vision truthfulness (B4).** Either implement `VNDetectHumanBodyPose` for Freeze Pose (and feed `PoseMetrics` from real body landmarks) **or** strike "Vision" from the README and re-label challenges as device-motion. Make code, docs, and store metadata consistent.
5. **Ship a rendered image scorecard (B5).** Replace the `.txt` writer with an `ImageRenderer`/`UIGraphicsImageRenderer` neon scorecard (challenge, score, stars, branded mark, safety-positive tone). Wire watermark to `waterMark`/Pro.
6. **Make monetization safe (B6).** For v1: hide/disable Packs-unlock, Paywall, and the Pro toggle. (Or, if monetizing: implement real StoreKit 2 purchase + `Transaction.currentEntitlements` + restore, and gate `isPro` on verified entitlements.)
7. **Complete the privacy manifest (B7).** Add required-reason API entries for UserDefaults and file-timestamp APIs; remove the unused `NSMicrophoneUsageDescription`; de-dup usage strings between `Info.plist` and build settings.
8. **Balance challenge rules (N1).** Tune Beam/Freeze/Crown win thresholds and scoring during/after live play so wins feel earned.
9. **Polish the round (N6) and add app icon/launch checks.** Add a brief countdown, verify `AppIcon-1024.png` renders at all sizes, dark-mode contrast.
10. **Add CI (N7) + a smoke UI test.** GitHub Actions `xcodebuild test`; add at least one UI test that drives onboarding → play (demo) → results.
11. **Accessibility + (optionally) localization pass (N8).** VoiceOver labels for the HUD, Dynamic Type, contrast; localize core strings if pursuing worldwide launch.

Reaching items 1–7 moves the app to ~80% (submittable TestFlight build with honest scope); 8–11 push toward 90% and a public launch.

**Test coverage summary.**
- **Tested (unit, demo-path, deterministic):** `ChallengeRuleEvaluator` (freeze win, portal win, too-many-hits loss), `GameEngine` (state flow intro→scanning→running, portal-tap finish→success), `ScoreCalculator` (star bands, score clamp to 1000). These cover the pure game logic well.
- **Not tested:** all SwiftUI views; the AR layer (`ARViewContainer`, `ArenaBuilder`, `ARSessionManager`) — untestable in CI without a device and currently unmocked; `StoreService` (stubbed); `ReplayKitRecorder` (stub); `ScorecardRenderer`/`ExportLimiter`/share flow; SwiftData persistence and `@Query` views; camera-permission branching; demo-vs-live `GameplayView.begin` loop. **No UI tests, no integration tests, no CI.**

---

## 9. Launch Checklist

**Identity & metadata**
- [ ] **B1:** Single canonical product name resolved across README, PROJECT_STATUS, UI, `AppConstants.appName`, bundle id, StoreKit ids.
- [ ] App display name, marketing name, and App Store listing all match the chosen name.
- [ ] `MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` set intentionally for the build.
- [ ] `AppIcon-1024.png` validated for all required sizes; accent/launch colors correct.

**Privacy & permissions**
- [ ] **B7:** `PrivacyInfo.xcprivacy` lists required-reason API codes for UserDefaults (`CA92.1`/appropriate) and file-timestamp APIs; tracking = false confirmed.
- [ ] `NSCameraUsageDescription` copy says camera is **on-device only, not recorded or uploaded**.
- [ ] **Remove** unused `NSMicrophoneUsageDescription` (Info.plist + build settings) unless mic is actually used.
- [ ] Settings privacy statement matches the manifest (no account/cloud/ads; on-device camera/Vision processing; nothing uploaded).

**Safety & content (movement game — mandatory)**
- [ ] **B2:** Safety screen includes "clear a space, look up from your phone, don't run into things, keep jumps low" + deliberate acknowledgement before every round.
- [ ] No challenge encourages unsafe stunts; jumps stay low; no run/leap/spin escalation.
- [ ] Share artifact celebrates the funny moment and **never** frames danger as the goal.
- [ ] Age rating set appropriately (likely 4+/9+); confirm no objectionable content; "Made for Kids" considered if marketing to families (and COPPA implications avoided — no data collection helps here).

**AR / gameplay readiness**
- [ ] **B3:** Freeze Pose validated on a physical iPhone in a real room (3–6 players).
- [ ] **B4:** Vision implemented for real **or** removed from stack/metadata; challenge labeling honest.
- [ ] Graceful behavior on AR-incapable devices / denied camera (demo mode) verified.
- [ ] **N1:** Challenge win/scoring rules balanced after live play.

**Sharing & growth**
- [ ] **B5:** Rendered image scorecard ships (not `.txt`); watermark toggles with Pro.
- [ ] Free daily share cap (5) behaves; `ExportRecord` logging correct.

**Monetization (StoreKit)**
- [ ] **B6:** Either all purchase UI hidden/disabled for v1, **or** real StoreKit 2 purchase + entitlement verification + restore implemented and tested with `Products.storekit`.
- [ ] If IAP shown: products configured in App Store Connect; empty House Party/Chaos packs removed or filled (N2).

**Engineering hygiene**
- [ ] **N7:** CI workflow runs `xcodebuild test` on PRs; existing unit tests green.
- [ ] At least one UI smoke test (onboarding → demo round → results).
- [ ] Stale `docs/PROJECT_DOCUMENTATION.md` reconciled to the real product (done in this package).
- [ ] **N8:** Accessibility pass (VoiceOver/Dynamic Type/contrast); localization decision recorded.
