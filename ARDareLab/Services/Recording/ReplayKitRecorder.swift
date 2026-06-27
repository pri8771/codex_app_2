import SwiftUI
import ReplayKit

@MainActor final class ReplayKitRecorder: ObservableObject { @Published var isRecording = false; func start() { isRecording = true }; func stop() async -> URL? { isRecording = false; return nil } }
