import XCTest

final class LinguaFlowUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testOnboardingRequiresTypedAnswerAndDirection() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()

        // Handle title screen or skip if already past it
        if app.buttons["Get Started"].waitForExistence(timeout: 4) {
            app.buttons["Get Started"].tap()
        }
        if app.staticTexts["Choose your level"].waitForExistence(timeout: 4) {
            app.buttons["level_A1"].tap()
        }

        XCTAssertTrue(app.staticTexts["Today's Flow"].waitForExistence(timeout: 5))
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
