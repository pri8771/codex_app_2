import XCTest
@testable import ARDareLab

final class ChallengeRuleEvaluatorTests: XCTestCase {
    func testFreezeWin() {
        let out = ChallengeRuleEvaluator.eval(
            kind: .freeze,
            input: .init(elapsed: 2, pose: .init(isBodyFound: true, stillSeconds: 3))
        )
        XCTAssertEqual(out, .won)
    }

    func testPortalWin() {
        let out = ChallengeRuleEvaluator.eval(
            kind: .portal,
            input: .init(elapsed: 3, pose: .demo, portalTapped: true)
        )
        XCTAssertEqual(out, .won)
    }

    func testTooManyHitsLoses() {
        let out = ChallengeRuleEvaluator.eval(
            kind: .beam,
            input: .init(elapsed: 4, pose: .demo, hits: ChallengeKind.beam.maxHits)
        )
        XCTAssertEqual(out, .lost("Too many hits"))
    }
}
