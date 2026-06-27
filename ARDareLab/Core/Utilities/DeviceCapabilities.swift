import Foundation
#if canImport(ARKit)
import ARKit
#endif

enum DeviceCapabilities { static var canRunAR: Bool { #if targetEnvironment(simulator)
false
#elseif canImport(ARKit)
ARWorldTrackingConfiguration.isSupported
#else
false
#endif } }
