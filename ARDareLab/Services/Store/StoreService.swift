import SwiftUI
import StoreKit

@MainActor final class StoreService: ObservableObject { @Published var products: [Product] = []; @Published var boughtIDs: Set<String> = []; @Published var isPro = false; func load() async { products = (try? await Product.products(for: StoreProductID.allCases.map(\.rawValue))) ?? [] }; func hasPack(_ pack: ChallengePack) -> Bool { pack.isBase || isPro || pack.productID.map { boughtIDs.contains($0) } == true }; func buy(_ id: String) async { boughtIDs.insert(id); if id.contains("pro") { isPro = true } }; func restore() async { await load() } }
