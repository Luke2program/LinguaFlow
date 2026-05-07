import XCTest

final class LinguaFlowUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testOnboardingReviewAndDirection() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        XCTAssertTrue(app.staticTexts["chooseNiveauTitle"].waitForExistence(timeout: 8))
        app.buttons["level_A1"].tap()
        XCTAssertTrue(app.staticTexts["dashboardReady"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["promptText"].exists)
        app.buttons["audioPromptButton"].tap()
        app.buttons["revealButton"].tap()
        XCTAssertTrue(app.staticTexts["answerText"].waitForExistence(timeout: 3))
        app.buttons["grade_Good"].tap()
        XCTAssertTrue(app.staticTexts["promptText"].waitForExistence(timeout: 3))
        app.buttons["directionToggle"].tap()
        XCTAssertTrue(app.staticTexts["promptText"].exists)
    }
}
