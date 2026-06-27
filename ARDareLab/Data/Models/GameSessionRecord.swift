import Foundation
import SwiftData

@Model final class GameSessionRecord { @Attribute(.unique) var id:UUID; var challengeRaw:String; var packID:String; var score:Int; var stars:Int; var duration:TimeInterval; var didWin:Bool; var createdAt:Date; init(id:UUID = UUID(), challenge:ChallengeKind, packID:String, score:Int, stars:Int, duration:TimeInterval, didWin:Bool, createdAt:Date = .now) { self.id=id; self.challengeRaw=challenge.rawValue; self.packID=packID; self.score=score; self.stars=stars; self.duration=duration; self.didWin=didWin; self.createdAt=createdAt }; var challenge:ChallengeKind { ChallengeKind(rawValue:challengeRaw) ?? .beam } }
