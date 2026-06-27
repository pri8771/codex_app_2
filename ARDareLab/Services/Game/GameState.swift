import Foundation

enum GameState: Equatable { case idle, intro, scanning, countdown(Int), running, success, failed(String), complete }
