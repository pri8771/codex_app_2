import XCTest
@testable import ARDareLab

final class ChallengeRuleEvaluatorTests: XCTestCase { func testFreezeWin() { let out = ChallengeRuleEvaluator.eval(kind:.freeze, input:.init(elapsed:2, pose:.init(isBodyFound:true, stillSeconds:3))); XCTAssertEqual(out,.running(1.0)) }; func testPortalWin() { let out = ChallengeRuleEvaluator.eval(kind:.portal, input:.init(elapsed:3, pose:.demo, portalTapped:true)); XCTAssertEqual(out,.won) } }
