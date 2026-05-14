import XCTest

final class LinguaFlowUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func launchReadyApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-ui-state"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Today's Flow"].waitForExistence(timeout: 5))
        return app
    }

    func testRequiresTypedAnswerAndDirection() throws {
        let app = launchReadyApp()

        XCTAssertTrue(app.staticTexts["promptText"].exists)
        XCTAssertTrue(app.textFields["answerInput"].exists)
        app.textFields["answerInput"].tap()
        app.textFields["answerInput"].typeText("Hola")
        app.buttons["checkAnswerButton"].tap()
        XCTAssertTrue(app.staticTexts["answerFeedback"].waitForExistence(timeout: 3))
        app.buttons["directionToggle"].tap()
        XCTAssertTrue(app.staticTexts["promptText"].exists)
    }

    func testCanChangeLearningLanguageAfterOnboarding() throws {
        let app = launchReadyApp()

        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))

        app.descendants(matching: .any)["languagePairPicker"].tap()
        app.buttons["Learn 🇫🇷 French from 🇩🇪 German"].tap()

        app.navigationBars.buttons["Settings"].tap()
        app.buttons["Done"].tap()

        let frenchPair = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "French")).firstMatch
        XCTAssertTrue(frenchPair.waitForExistence(timeout: 3))
    }

    func testCanOpenLoginAgainAfterSkippingAccount() throws {
        let app = launchReadyApp()

        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
        app.buttons["Sign in or create account"].tap()

        XCTAssertTrue(app.staticTexts["Welcome Back"].waitForExistence(timeout: 3))
    }
}
