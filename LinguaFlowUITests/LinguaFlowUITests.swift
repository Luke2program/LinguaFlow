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

        let settingsBackButton = app.navigationBars.buttons["Settings"].firstMatch
        if settingsBackButton.waitForExistence(timeout: 1) { settingsBackButton.tap() }
        let doneButton = app.buttons["Done"].firstMatch
        if doneButton.waitForExistence(timeout: 1) { doneButton.tap() }

        let frenchPair = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "French")).firstMatch
        XCTAssertTrue(frenchPair.waitForExistence(timeout: 3))
    }

    func testCanOpenLoginAgainAfterSkippingAccount() throws {
        let app = launchReadyApp()

        openSettings(in: app)
        app.buttons["Sign in or create account"].tap()

        // After dismissing settings, RootView should present AuthView because hasSkippedAuth is now false
        // Wait for AuthView title; increase timeout for sheet dismissal + view transition
        let welcomeText = app.staticTexts["Welcome Back"].firstMatch
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 6))
    }
}
