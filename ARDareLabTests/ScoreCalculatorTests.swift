import XCTest
@testable import ARDareLab

final class ScoreCalculatorTests: XCTestCase { func testStarBands() { XCTAssertEqual(ScoreCalculator.stars(for:900),3); XCTAssertEqual(ScoreCalculator.stars(for:650),2); XCTAssertEqual(ScoreCalculator.stars(for:400),1); XCTAssertEqual(ScoreCalculator.stars(for:100),0) }; func testScoreClamp() { XCTAssertEqual(ScoreCalculator.score(accuracy:9, progress:9, penalty:0, didWin:true).score, 1000) } }
