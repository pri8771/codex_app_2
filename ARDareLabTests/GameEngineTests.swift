import XCTest
@testable import ARDareLab

@MainActor final class GameEngineTests: XCTestCase { func testFlow() { let e = GameEngine(); e.prepare(.beam); XCTAssertEqual(e.state,.intro); e.scan(); XCTAssertEqual(e.state,.scanning); e.startNow(); XCTAssertEqual(e.state,.running) }; func testFinish() { let e = GameEngine(); e.prepare(.portal); e.startNow(); e.tick(input:.init(elapsed:5, pose:.demo, portalTapped:true)); XCTAssertEqual(e.state,.success) } }
