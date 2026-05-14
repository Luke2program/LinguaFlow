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

    private func openSettings(in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) {
        let settingsButton = app.buttons["settingsButton"].firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), file: file, line: line)
        for _ in 0..<3 {
            settingsButton.tap()
            if app.navigationBars["Settings"].waitForExistence(timeout: 2) { return }
        }
        XCTFail("Settings did not open", file: file, line: line)
    }

    func testRequiresTypedAnswerAndDirection() throws {
        let app = launchReadyApp()

        XCTAssertTrue(app.staticTexts["promptText"].exists)
        let answerField = app.textFields["answerInput"].firstMatch
        XCTAssertTrue(answerField.waitForExistence(timeout: 3))
        answerField.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 2))
        answerField.typeText("Hola")
        app.buttons["checkAnswerButton"].tap()
        XCTAssertTrue(app.staticTexts["answerFeedback"].waitForExistence(timeout: 3))
        app.buttons["directionToggle"].tap()
        XCTAssertTrue(app.staticTexts["promptText"].exists)
    }

    func testCanChangeLearningLanguageAfterOnboarding() throws {
        let app = launchReadyApp()

        openSettings(in: app)

        let learningPicker = app.descendants(matching: .any)["learningLanguagePicker"].firstMatch
        XCTAssertTrue(learningPicker.waitForExistence(timeout: 3))
        learningPicker.tap()
        let frenchOption = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", "French")).firstMatch
        XCTAssertTrue(frenchOption.waitForExistence(timeout: 3))
        frenchOption.tap()

        // Navigate back from picker to Settings
        let backButton = app.navigationBars.buttons.firstMatch
        if backButton.waitForExistence(timeout: 1) { backButton.tap() }

        // Now dismiss Settings sheet
        let doneButton = app.buttons["settingsDoneButton"].firstMatch
        if doneButton.waitForExistence(timeout: 1) { doneButton.tap() }

        // Verify dashboard reflects French
        let frenchPair = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "French")).firstMatch
        XCTAssertTrue(frenchPair.waitForExistence(timeout: 3))
    }

    func testCanOpenLoginAgainAfterSkippingAccount() throws {
        let app = launchReadyApp()

        openSettings(in: app)
        app.buttons["Sign in or create account"].tap()

        // Wait longer for sheet dismissal + AuthView to appear
        let welcomeText = app.staticTexts["Welcome Back"].firstMatch
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 10))
    }
}
