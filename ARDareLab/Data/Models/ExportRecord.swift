import Foundation
import SwiftData

@Model final class ExportRecord { var id:UUID; var createdAt:Date; var sessionID:UUID?; init(id:UUID = UUID(), createdAt:Date = .now, sessionID:UUID? = nil) { self.id=id; self.createdAt=createdAt; self.sessionID=sessionID } }
