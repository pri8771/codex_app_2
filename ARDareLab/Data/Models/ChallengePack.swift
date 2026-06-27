import Foundation

struct ChallengePack: Identifiable, Hashable { let id:String; let title:String; let detail:String; let productID:String?; let challenges:[ChallengeKind]; let isBase:Bool; static let all:[ChallengePack] = [.init(id:"base", title:"Starter Arena", detail:"Five local party dares.", productID:nil, challenges:ChallengeKind.allCases, isBase:true), .init(id:"neon", title:"Neon Arcade", detail:"Fast rounds.", productID:StoreProductID.neonArcade.rawValue, challenges:[.beam,.portal], isBase:false)] }
