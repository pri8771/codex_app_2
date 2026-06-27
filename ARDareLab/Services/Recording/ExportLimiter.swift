import SwiftUI

@MainActor final class ExportLimiter: ObservableObject { func canShare(isPro: Bool, usedToday: Int) -> Bool { isPro || usedToday < AppConstants.freeDailyShareCap }; func countToday(_ records: [ExportRecord]) -> Int { records.filter { Calendar.current.isDateInToday($0.createdAt) }.count } }
