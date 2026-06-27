import Foundation

struct PoseMetrics: Equatable { var isBodyFound = false; var stillSeconds: TimeInterval = 0; var headCenteredSeconds: TimeInterval = 0; var jumpCount = 0; var sway: Double = 0; static let demo = PoseMetrics(isBodyFound:true, stillSeconds:1, headCenteredSeconds:1, jumpCount:0, sway:0.1) }
