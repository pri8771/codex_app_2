# Floorless — Project Documentation

GitHub is the source of truth for this project documentation. Notion indexes this file in the Priyansh App Factory Command Center.

## 00. Executive Summary
Floorless is a provisional iOS game candidate built around instability, movement risk, or survival without safe ground. It is for casual arcade players who like fast retries and short challenge loops. The end product should be either a focused playable arcade MVP or a clearly archived/merged concept.

## 01. Product
MVP scope: one core action mechanic, start/retry loop, scoring or level completion, local high score/progress, and simple settings. Acceptance criteria: the concept can be explained in one sentence and creates one repeatable fun loop.

## 02. Design
High-contrast arcade style, clear risk zones, fast retry UI, simple scoring, satisfying failure feedback. Screens: start, gameplay HUD, fail state, score, settings.

## 03. Frontend Technical
SwiftUI shell with SpriteKit or pure SwiftUI gameplay depending on repo contents. GameSession stores active run, score, fail state, retry count, and level/round data.

## 04. Backend Technical
No backend for v1. Future services may include leaderboards, daily challenge, remote levels, or analytics config.

## 05. Business
Do not monetize heavily until fun is proven. Future options: pro unlock, skins, level packs, or challenge mode.

## 06. Marketing
Draft positioning: how long can you survive with no floor? Channels: fail clips, close saves, high-score challenges.

## 07. User Acquisition
Beta with 10-20 arcade-game testers. Metrics: first run completion, retries per session, average session length, D1 return, fun score.

## 08. Execution
Plan: audit repo, confirm product identity, decide continue/archive, freeze one-sentence loop, build 60-second playable MVP, test fun.

## 09. QA
Test launch, input responsiveness, fail state, retry, score persistence, pause/resume, device sizes, and accessibility.

## 10. Legal / Compliance
No account or backend for v1. Disclose data handling if analytics or leaderboards are added.

## 11. Operations
Release only after audit and fun validation. If product identity remains unclear, archive or merge useful ideas into another game.
