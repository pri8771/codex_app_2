import Foundation

extension Int { var pointsText: String { "\(self) pts" } }
extension Double { func clamped(_ a: Double = 0, _ b: Double = 1) -> Double { min(max(self,a),b) } }
extension Date { var dayKey: String { ISO8601DateFormatter().string(from: Calendar.current.startOfDay(for:self)) } }
