import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum Haptics { static func tap() { #if canImport(UIKit)
UIImpactFeedbackGenerator(style:.medium).impactOccurred()
#endif } }
