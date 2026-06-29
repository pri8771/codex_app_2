import Foundation

enum GameState: Equatable { case idle, intro, scanning, countdown(Int), running, success, failed(String), complete }

extension GameState {
    var isFinished: Bool {
        switch self {
        case .success, .failed, .complete:
            return true
        case .idle, .intro, .scanning, .countdown, .running:
            return false
        }
    }
}
