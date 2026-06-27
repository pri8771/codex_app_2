import Foundation
import SwiftData

@Model final class PlayerProfile { @Attribute(.unique) var id:UUID; var nickname:String; var partyMode:Bool; init(id:UUID = UUID(), nickname:String = "Player", partyMode:Bool = false) { self.id=id; self.nickname=nickname; self.partyMode=partyMode } }
