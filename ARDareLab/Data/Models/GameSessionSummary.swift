import Foundation

struct GameSessionSummary: Identifiable, Hashable { let id:UUID; let challenge:ChallengeKind; let score:Int; let stars:Int; let didWin:Bool }
