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

        // Dismiss Settings sheet using inline Done button
        let doneButton = app.buttons["settingsDoneButton"].firstMatch
        // Wait for menu dismiss animation
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

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
    
    // MARK: - Subject System UI Tests
    func testSubjectSwitchButtonExists() throws {
        let app = launchReadyApp()
        let subjectButton = app.buttons["subjectSwitchButton"].firstMatch
        XCTAssertTrue(subjectButton.waitForExistence(timeout: 3))
    }
    
    func testCanSwitchToHistorySubject() throws {
        let app = launchReadyApp()
        
        // Tap subject switch
        let subjectButton = app.buttons["subjectSwitchButton"].firstMatch
        XCTAssertTrue(subjectButton.waitForExistence(timeout: 3))
        subjectButton.tap()
        
        // Select history
        let historyOption = app.buttons["subject_history"].firstMatch
        XCTAssertTrue(historyOption.waitForExistence(timeout: 3))
        historyOption.tap()
        
        // Tap Start Learning
        let startButton = app.buttons["Start Learning"].firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 3))
        startButton.tap()
        
        // Verify history dashboard elements
        let historyWorldView = app.otherElements["historyWorldView"].firstMatch
        XCTAssertTrue(historyWorldView.waitForExistence(timeout: 5))
    }
    
    func testHistoryWorldSelection() throws {
        let app = launchReadyApp()
        
        // Switch to history
        let subjectButton = app.buttons["subjectSwitchButton"].firstMatch
        XCTAssertTrue(subjectButton.waitForExistence(timeout: 3))
        subjectButton.tap()
        
        let historyOption = app.buttons["subject_history"].firstMatch
        XCTAssertTrue(historyOption.waitForExistence(timeout: 3))
        historyOption.tap()
        
        let startButton = app.buttons["Start Learning"].firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 3))
        startButton.tap()
        
        // Select Ancient Rome world
        let romeWorld = app.buttons["world_ancient-rome"].firstMatch
        XCTAssertTrue(romeWorld.waitForExistence(timeout: 5))
        romeWorld.tap()
        
        // Verify challenge appears
        let challengeView = app.otherElements["historyChallengeView"].firstMatch
        XCTAssertTrue(challengeView.waitForExistence(timeout: 3))
    }
    
    func testHistoryChallengeInteraction() throws {
        let app = launchReadyApp()
        
        // Switch to history and select Rome
        let subjectButton = app.buttons["subjectSwitchButton"].firstMatch
        XCTAssertTrue(subjectButton.waitForExistence(timeout: 3))
        subjectButton.tap()
        
        app.buttons["subject_history"].firstMatch.tap()
        app.buttons["Start Learning"].firstMatch.tap()
        app.buttons["world_ancient-rome"].firstMatch.tap()
        
        // Answer a history choice
        let choiceA = app.buttons["historyChoice_a"].firstMatch
        XCTAssertTrue(choiceA.waitForExistence(timeout: 5))
        choiceA.tap()
        
        // Verify result shows
        let nextButton = app.buttons["nextHistoryChallenge"].firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
    }
}
