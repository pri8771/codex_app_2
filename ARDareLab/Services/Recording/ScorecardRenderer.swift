import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum ScorecardRenderer { static func make(summary: GameSessionSummary, waterMark: Bool) -> URL? { #if canImport(UIKit)
let text = "AR Dare Lab \(summary.challenge.title) \(summary.score) pts"; let url = FileManager.default.temporaryDirectory.appendingPathComponent("scorecard-\(summary.id.uuidString).txt"); try? text.write(to: url, atomically: true, encoding: .utf8); return url
#else
return nil
#endif
} }
