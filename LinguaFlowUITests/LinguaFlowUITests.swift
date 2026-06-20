import XCTest

final class LinguaFlowUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    private func launchReadyApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-ui-state"] + arguments
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

    private func button(_ id: String, in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        let target = app.buttons[id].firstMatch
        if target.waitForExistence(timeout: 2) { return target }
        for _ in 0..<4 {
            app.swipeUp()
            if target.waitForExistence(timeout: 1) { return target }
        }
        XCTFail("Button \(id) did not appear after scrolling", file: file, line: line)
        return target
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
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

        // Verify settings dismissed by checking dashboard is visible
        let dashboard = app.staticTexts["Today's Flow"].firstMatch
        XCTAssertTrue(dashboard.waitForExistence(timeout: 3))
    }

    func testCanOpenLoginAgainAfterSkippingAccount() throws {
        let app = launchReadyApp()

        openSettings(in: app)
        app.buttons["Sign in or create account"].tap()

        app.terminate()
        let authApp = XCUIApplication()
        authApp.launchArguments = []
        authApp.launch()
        XCTAssertTrue(authApp.staticTexts["Welcome Back"].waitForExistence(timeout: 10))
    }
    
    // MARK: - Subject System UI Tests
    func testSubjectSwitchButtonExists() throws {
        let app = launchReadyApp()
        let subjectButton = app.buttons["subjectSwitchButton"].firstMatch
        XCTAssertTrue(subjectButton.waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["dailyQuestPanel"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Decode the next phrase"].waitForExistence(timeout: 3))
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
        
        // Wait for sheet dismissal and view update
        sleep(3)
        
        // Verify history content appears - look for Ancient Rome text
        let romeText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Ancient Rome")).firstMatch
        XCTAssertTrue(romeText.waitForExistence(timeout: 5))
    }
    
    func testHistoryWorldSelection() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-history-world"])

        // Verify challenge appears by looking for a year text like "BCE"
        let yearText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "BCE")).firstMatch
        XCTAssertTrue(yearText.waitForExistence(timeout: 3))
    }
    
    func testHistoryChallengeInteraction() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-history-world"])

        // Answer a history choice
        let choiceA = button("historyChoice_a", in: app)
        choiceA.tap()
        
        // Verify result shows
        let nextButton = app.buttons["nextHistoryChallenge"].firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
    }
    
    // MARK: - Science Subject UI Tests
    func testCanSwitchToScienceSubject() throws {
        let app = launchReadyApp()
        
        let subjectButton = app.buttons["subjectSwitchButton"].firstMatch
        XCTAssertTrue(subjectButton.waitForExistence(timeout: 3))
        subjectButton.tap()
        
        let scienceOption = app.buttons["subject_science"].firstMatch
        XCTAssertTrue(scienceOption.waitForExistence(timeout: 3))
        scienceOption.tap()
        
        let startButton = app.buttons["Start Learning"].firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 3))
        startButton.tap()
        
        sleep(3)
        
        // Verify science content appears - look for Space Frontiers text
        let spaceText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Space Frontiers")).firstMatch
        XCTAssertTrue(spaceText.waitForExistence(timeout: 5))
    }
    
    func testScienceWorldSelection() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-science-world"])

        // Verify challenge appears by looking for Mission label
        let missionText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Mission")).firstMatch
        XCTAssertTrue(missionText.waitForExistence(timeout: 3))
    }
    
    func testScienceChallengeInteraction() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-science-world"])

        // Answer a science choice
        let choiceB = button("scienceChoice_b", in: app)
        choiceB.tap()
        
        // Verify result shows
        let nextButton = app.buttons["nextScienceChallenge"].firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
    }
}
