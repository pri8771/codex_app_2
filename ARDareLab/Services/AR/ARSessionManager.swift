import AVFoundation
import SwiftUI

@MainActor
final class ARSessionManager: ObservableObject {
    enum CameraPermission: Equatable {
        case unavailable
        case notDetermined
        case authorized
        case denied
    }

    @Published private(set) var cameraPermission: CameraPermission = .notDetermined

    var canStartAR: Bool {
        DeviceCapabilities.canRunAR && cameraPermission == .authorized
    }

    var fallbackTitle: String {
        switch cameraPermission {
        case .unavailable:
            return "Demo mode"
        case .notDetermined:
            return "Preparing camera"
        case .authorized:
            return "Demo mode"
        case .denied:
            return "Camera access needed"
        }
    }

    var fallbackMessage: String {
        switch cameraPermission {
        case .unavailable:
            return "AR requires a supported iPhone. This device is running the simulator-safe arena."
        case .notDetermined:
            return "iOS should ask for camera access before the live AR arena starts."
        case .authorized:
            return "Move safely and score points."
        case .denied:
            return "Enable camera access in Settings to use the live AR arena."
        }
    }

    init() {
        refreshCameraPermission()
    }

    func refreshCameraPermission() {
        guard DeviceCapabilities.canRunAR else {
            cameraPermission = .unavailable
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermission = .authorized
        case .notDetermined:
            cameraPermission = .notDetermined
        case .denied, .restricted:
            cameraPermission = .denied
        @unknown default:
            cameraPermission = .denied
        }
    }

    func requestCameraAccessIfNeeded() async {
        guard DeviceCapabilities.canRunAR else {
            cameraPermission = .unavailable
            return
        }

        guard AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined else {
            refreshCameraPermission()
            return
        }

        let granted = await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }

        cameraPermission = granted ? .authorized : .denied
    }
}
