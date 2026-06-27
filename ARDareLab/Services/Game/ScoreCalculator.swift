import Foundation

struct ScoreBreakdown: Equatable { let score: Int; let stars: Int }
enum ScoreCalculator { static func score(accuracy: Double, progress: Double, penalty: Int, didWin: Bool) -> ScoreBreakdown { let base = Int((accuracy.clamped() * 650) + (progress.clamped() * 300)) + (didWin ? 50 : 0) - penalty * 40; let final = min(1000, max(0, base)); return .init(score: final, stars: stars(for: final)) }; static func stars(for score: Int) -> Int { score >= 850 ? 3 : score >= 600 ? 2 : score >= 350 ? 1 : 0 } }
