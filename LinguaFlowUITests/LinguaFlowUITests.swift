import XCTest

final class LinguaFlowUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testOnboardingRequiresTypedAnswerAndDirection() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        // Handle all three possible launch states
        if app.otherElements["titleScreen"].waitForExistence(timeout: 4) {
            app.buttons["startLearningButton"].tap()
        }
        if app.staticTexts["chooseNiveauTitle"].waitForExistence(timeout: 4) {
            app.buttons["level_A1"].tap()
        }

        XCTAssertTrue(app.staticTexts["dashboardReady"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["promptText"].exists)
        XCTAssertTrue(app.textFields["answerInput"].exists)
        app.textFields["answerInput"].tap()
        app.textFields["answerInput"].typeText("Hola")
        app.buttons["checkAnswerButton"].tap()
        XCTAssertTrue(app.staticTexts["answerFeedback"].waitForExistence(timeout: 3))
        app.buttons["directionToggle"].tap()
        XCTAssertTrue(app.staticTexts["promptText"].exists)
    }
}
