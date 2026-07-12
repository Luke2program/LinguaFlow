import XCTest

final class LinguaFlowUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testOnboardingStartLearningAdvancesFromPetStep() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-ui-state", "--ui-testing-onboarding-pet-step"]
        app.launch()

        let petNameField = app.textFields["Name your pet..."].firstMatch
        XCTAssertTrue(petNameField.waitForExistence(timeout: 5))
        petNameField.tap()
        petNameField.typeText("Mochi")

        let startButton = app.buttons["Start Learning"].firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        if !app.staticTexts["Today's Quest"].waitForExistence(timeout: 5) {
            XCTFail("Expected dashboard after onboarding. Current UI:\n\(app.debugDescription)")
        }
    }

    func testOnboardingChoosesSubjectBeforeLanguagePair() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--reset-ui-state"]
        app.launch()

        let continueButton = app.buttons["Continue"].firstMatch
        XCTAssertTrue(continueButton.waitForExistence(timeout: 5))

        let subjectTitle = app.staticTexts["What do you want to study first?"].firstMatch
        for _ in 0..<4 where !subjectTitle.exists {
            continueButton.tap()
            sleep(1)
        }

        XCTAssertTrue(subjectTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["onboardingSubject_languages"].waitForExistence(timeout: 5))

        continueButton.tap()

        XCTAssertTrue(app.staticTexts["Which languages?"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons.matching(identifier: "languagePair_de-DE-es-ES").firstMatch.waitForExistence(timeout: 5))
    }

    private func launchReadyApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing", "--reset-ui-state"] + arguments
        app.launch()
        XCTAssertTrue(app.staticTexts["Today's Quest"].waitForExistence(timeout: 5))
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
        for _ in 0..<6 {
            app.swipeUp()
            if target.waitForExistence(timeout: 1) { return target }
        }
        XCTFail("Button \(id) did not appear after scrolling", file: file, line: line)
        return target
    }

    private func element(_ id: String, in app: XCUIApplication, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        let target = app.descendants(matching: .any)[id].firstMatch
        if target.waitForExistence(timeout: 2) { return target }
        for _ in 0..<6 {
            app.swipeUp()
            if target.waitForExistence(timeout: 1) { return target }
        }
        XCTFail("Element \(id) did not appear after scrolling", file: file, line: line)
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
        let dashboard = app.staticTexts["Today's Quest"].firstMatch
        XCTAssertTrue(dashboard.waitForExistence(timeout: 3))
    }

    func testCanChangeSubjectFromSettings() throws {
        let app = launchReadyApp()

        openSettings(in: app)

        let subjectPicker = app.descendants(matching: .any)["subjectSettingsPicker"].firstMatch
        XCTAssertTrue(subjectPicker.waitForExistence(timeout: 3))
        subjectPicker.tap()

        let historyOption = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", "History")).firstMatch
        XCTAssertTrue(historyOption.waitForExistence(timeout: 3))
        historyOption.tap()

        let doneButton = app.buttons["settingsDoneButton"].firstMatch
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

        let historyHeader = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "History")).firstMatch
        XCTAssertTrue(historyHeader.waitForExistence(timeout: 3))
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
        XCTAssertTrue(app.buttons["randomStudyButton"].waitForExistence(timeout: 3))
        XCTAssertTrue(element("recommendedRunPanel", in: app).exists)
        XCTAssertTrue(element("recommendedRunTitle", in: app).exists)
        XCTAssertTrue(element("dailyWorldEventPanel", in: app).exists)
        XCTAssertTrue(element("dailyWorldEventTitle", in: app).exists)
        XCTAssertTrue(element("dailyWorldEventChapter_1", in: app).exists)
        XCTAssertTrue(element("dailyWorldEventProgressText", in: app).exists)
        XCTAssertTrue(element("dailyAdventurePanel", in: app).exists)
        XCTAssertTrue(app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Language Harbor Run")).firstMatch.waitForExistence(timeout: 3))
        XCTAssertTrue(element("dailyComboPanel", in: app).exists)
        XCTAssertTrue(element("dailyComboTitle", in: app).exists)
        XCTAssertTrue(element("dailyComboProgressText", in: app).exists)
        XCTAssertTrue(element("dailyBossPanel", in: app).exists)
        XCTAssertTrue(element("dailyBossTitle", in: app).exists)
        XCTAssertTrue(element("dailyBossProgressText", in: app).exists)
        XCTAssertTrue(element("dailyRelicPanel", in: app).exists)
        XCTAssertTrue(element("dailyRelicTitle", in: app).exists)
        XCTAssertTrue(element("dailyRelicProgressText", in: app).exists)
        XCTAssertTrue(element("questBoardPanel", in: app).exists)
        XCTAssertTrue(app.staticTexts["Quest Board"].waitForExistence(timeout: 3))
        XCTAssertTrue(element("questMission_language-review", in: app).exists)
        XCTAssertTrue(element("worldPathPanel", in: app).exists)
        XCTAssertTrue(app.staticTexts["Language Path"].waitForExistence(timeout: 3))
        XCTAssertTrue(element("dailyQuestPanel", in: app).exists)
        XCTAssertTrue(app.staticTexts["Decode the next phrase"].waitForExistence(timeout: 3))
        XCTAssertTrue(element("streakChestPanel", in: app).exists)
        XCTAssertTrue(element("levelTrackPanel", in: app).exists)
        XCTAssertTrue(app.staticTexts["Level 1 · Trail Starter"].waitForExistence(timeout: 3))
        XCTAssertTrue(element("worldAtlasPanel", in: app).exists)
        XCTAssertTrue(app.staticTexts["World Atlas"].waitForExistence(timeout: 3))
        XCTAssertTrue(element("worldAtlasSubject_languages", in: app).exists)
        XCTAssertTrue(element("worldAtlasSubject_history", in: app).exists)
        XCTAssertTrue(app.buttons["worldAtlasNextButton"].waitForExistence(timeout: 3))
        XCTAssertTrue(element("rewardVaultPanel", in: app).exists)
        XCTAssertTrue(app.staticTexts["7/15 world badges · 0/16 relics"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Relic Shelf"].waitForExistence(timeout: 3))
    }

    func testQuestBoardMissionTapStartsReviewGate() throws {
        let app = launchReadyApp()

        let mission = element("questMission_language-review", in: app)
        mission.tap()

        let feedback = app.staticTexts["answerFeedback"].firstMatch
        XCTAssertTrue(feedback.waitForExistence(timeout: 3))
        XCTAssertTrue(feedback.label.contains("review gate"))
    }

    func testRecommendedRunPanelStartsSuggestedAdventure() throws {
        let app = launchReadyApp()

        let panel = element("recommendedRunPanel", in: app)
        XCTAssertTrue(app.staticTexts["recommendedRunEyebrow"].label.contains("Recommended"))
        XCTAssertTrue(app.staticTexts["recommendedRunTitle"].label.contains("Language Harbor Run"))
        panel.tap()

        let feedback = app.staticTexts["answerFeedback"].firstMatch
        XCTAssertTrue(feedback.waitForExistence(timeout: 3))
        XCTAssertTrue(feedback.label.contains("Recommended run opened"))
    }

    func testCanClaimReadyStreakChest() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-chest-ready"])

        let panel = element("streakChestPanel", in: app)
        XCTAssertTrue(panel.exists)
        XCTAssertTrue(app.staticTexts["streakChestTitle"].label.contains("Ready"))

        let claimButton = app.buttons["claimStreakChestButton"].firstMatch
        XCTAssertTrue(claimButton.waitForExistence(timeout: 3))
        XCTAssertTrue(claimButton.isEnabled)
        claimButton.tap()

        XCTAssertTrue(app.staticTexts["streakChestTitle"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.staticTexts["streakChestTitle"].label, "Chest Claimed")
        XCTAssertFalse(app.buttons["claimStreakChestButton"].isEnabled)
    }

    func testCanDefeatReadyDailyBoss() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-chest-ready"])

        let panel = element("dailyBossPanel", in: app)
        XCTAssertTrue(panel.exists)
        XCTAssertTrue(app.staticTexts["dailyBossTitle"].label.contains("Grammar Kraken"))

        let fightButton = app.buttons["fightDailyBossButton"].firstMatch
        XCTAssertTrue(fightButton.waitForExistence(timeout: 3))
        XCTAssertTrue(fightButton.isEnabled)
        fightButton.tap()

        XCTAssertEqual(app.staticTexts["dailyBossTitle"].label, "Boss Defeated")
        XCTAssertFalse(app.buttons["fightDailyBossButton"].isEnabled)
    }

    func testCanClaimReadyDailyRelic() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-chest-ready"])

        let panel = element("dailyRelicPanel", in: app)
        XCTAssertTrue(panel.exists)
        XCTAssertTrue(app.staticTexts["dailyRelicTitle"].label.contains("Mystery Relic Ready"))

        let claimButton = app.buttons["claimDailyRelicButton"].firstMatch
        XCTAssertTrue(claimButton.waitForExistence(timeout: 3))
        XCTAssertTrue(claimButton.isEnabled)
        claimButton.tap()

        XCTAssertEqual(app.staticTexts["dailyRelicTitle"].label, "Relic Secured")
        XCTAssertFalse(app.buttons["claimDailyRelicButton"].isEnabled)
    }

    func testRandomStudyButtonJumpsIntoAWorld() throws {
        let app = launchReadyApp()

        let randomButton = app.buttons["randomStudyButton"].firstMatch
        XCTAssertTrue(randomButton.waitForExistence(timeout: 3))
        randomButton.tap()

        let pickedButton = app.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Roulette picked")).firstMatch
        XCTAssertTrue(pickedButton.waitForExistence(timeout: 3))
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

        XCTAssertTrue(app.descendants(matching: .any)["worldPathPanel"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["World Path"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["worldPathStop_history_ancient-rome"].waitForExistence(timeout: 3))

        // Verify challenge appears by looking for a year text like "BCE"
        let yearText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "BCE")).firstMatch
        XCTAssertTrue(yearText.waitForExistence(timeout: 3))
    }

    func testRubiconCampaignMapInteraction() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-history-world"])

        XCTAssertTrue(element("rubiconCampaignMap", in: app).exists)

        let rubiconPin = app.buttons["rubiconMapPin_rubicon"].firstMatch
        XCTAssertTrue(rubiconPin.waitForExistence(timeout: 3))
        rubiconPin.tap()

        let turnBackButton = app.buttons["rubiconDecision_Turnback"].firstMatch
        XCTAssertTrue(turnBackButton.waitForExistence(timeout: 3))
        turnBackButton.tap()

        let outcome = app.staticTexts["rubiconDecisionOutcome"].firstMatch
        XCTAssertTrue(outcome.waitForExistence(timeout: 3))
    }

    func testHistoryChallengeInteraction() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-history-world"])

        // Answer a history choice
        let choiceA = button("historyChoiceTestAction", in: app)
        choiceA.tap()

        // Verify result shows
        let nextButton = app.buttons["nextHistoryChallenge"].firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
    }

    func testWorldUnlockBannerAppearsAfterCrossingXPThreshold() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-health-world", "--ui-testing-health-near-unlock"])

        let choice = button("healthChoiceTestAction", in: app)
        choice.tap()

        let title = element("worldUnlockTitle", in: app)
        XCTAssertTrue(title.waitForExistence(timeout: 3))
        XCTAssertEqual(title.label, "Resilience Gym")
        XCTAssertTrue(element("worldUnlockMessage", in: app).label.contains("Reward Vault"))
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
        let choiceB = button("scienceChoiceTestAction", in: app)
        choiceB.tap()

        // Verify result shows
        let nextButton = app.buttons["nextScienceChallenge"].firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
    }

    // MARK: - Geography Subject UI Tests
    func testCanSwitchToGeographySubject() throws {
        let app = launchReadyApp()

        let subjectButton = app.buttons["subjectSwitchButton"].firstMatch
        XCTAssertTrue(subjectButton.waitForExistence(timeout: 3))
        subjectButton.tap()

        let geographyOption = app.buttons["subject_geography"].firstMatch
        XCTAssertTrue(geographyOption.waitForExistence(timeout: 3))
        geographyOption.tap()

        let startButton = app.buttons["Start Learning"].firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 3))
        startButton.tap()

        sleep(3)

        let capitalsText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "European Capitals")).firstMatch
        XCTAssertTrue(capitalsText.waitForExistence(timeout: 5))
    }

    func testGeographyWorldSelection() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-geography-world"])

        let worldText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "European Capitals")).firstMatch
        XCTAssertTrue(worldText.waitForExistence(timeout: 3))
        let routeText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Route")).firstMatch
        XCTAssertTrue(routeText.waitForExistence(timeout: 3))
    }

    func testGeographyChallengeInteraction() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-geography-world"])

        let choice = button("geographyChoiceTestAction", in: app)
        choice.tap()

        let nextButton = app.buttons["nextGeographyChallenge"].firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
    }

    // MARK: - Math Subject UI Tests
    func testCanSwitchToMathSubject() throws {
        let app = launchReadyApp()

        let subjectButton = app.buttons["subjectSwitchButton"].firstMatch
        XCTAssertTrue(subjectButton.waitForExistence(timeout: 3))
        subjectButton.tap()

        let mathOption = app.buttons["subject_math"].firstMatch
        XCTAssertTrue(mathOption.waitForExistence(timeout: 3))
        mathOption.tap()

        let startButton = app.buttons["Start Learning"].firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 3))
        startButton.tap()

        sleep(3)

        let logicText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Logic Gates")).firstMatch
        XCTAssertTrue(logicText.waitForExistence(timeout: 5))
    }

    func testMathWorldSelection() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-math-world"])

        let worldText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Logic Gates")).firstMatch
        XCTAssertTrue(worldText.waitForExistence(timeout: 3))
        let puzzleText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Puzzle")).firstMatch
        XCTAssertTrue(puzzleText.waitForExistence(timeout: 3))
    }

    func testMathChallengeInteraction() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-math-world"])

        let choice = button("mathChoiceTestAction", in: app)
        choice.tap()

        let nextButton = app.buttons["nextMathChallenge"].firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
    }

    // MARK: - Culture Subject UI Tests
    func testCanSwitchToCultureSubject() throws {
        let app = launchReadyApp()

        let subjectButton = app.buttons["subjectSwitchButton"].firstMatch
        XCTAssertTrue(subjectButton.waitForExistence(timeout: 3))
        subjectButton.tap()

        let cultureOption = app.buttons["subject_culture"].firstMatch
        XCTAssertTrue(cultureOption.waitForExistence(timeout: 3))
        cultureOption.tap()

        let startButton = app.buttons["Start Learning"].firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 3))
        startButton.tap()

        sleep(3)

        let kitchenText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Heritage Kitchens")).firstMatch
        XCTAssertTrue(kitchenText.waitForExistence(timeout: 5))
    }

    func testCultureWorldSelection() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-culture-world"])

        let worldText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Heritage Kitchens")).firstMatch
        XCTAssertTrue(worldText.waitForExistence(timeout: 3))
        let storyText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Story")).firstMatch
        XCTAssertTrue(storyText.waitForExistence(timeout: 3))
    }

    func testCultureChallengeInteraction() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-culture-world"])

        let choice = button("cultureChoiceTestAction", in: app)
        choice.tap()

        let nextButton = app.buttons["nextCultureChallenge"].firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
    }

    // MARK: - Business Subject UI Tests
    func testCanSwitchToBusinessSubject() throws {
        let app = launchReadyApp()

        let subjectButton = app.buttons["subjectSwitchButton"].firstMatch
        XCTAssertTrue(subjectButton.waitForExistence(timeout: 3))
        subjectButton.tap()

        let businessOption = app.buttons["subject_business"].firstMatch
        XCTAssertTrue(businessOption.waitForExistence(timeout: 3))
        businessOption.tap()

        let startButton = app.buttons["Start Learning"].firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 3))
        startButton.tap()

        sleep(3)

        let founderText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Founder Guild")).firstMatch
        XCTAssertTrue(founderText.waitForExistence(timeout: 5))
    }

    func testBusinessWorldSelection() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-business-world"])

        let worldText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Founder Guild")).firstMatch
        XCTAssertTrue(worldText.waitForExistence(timeout: 3))
        let decisionText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Decision")).firstMatch
        XCTAssertTrue(decisionText.waitForExistence(timeout: 3))
    }

    func testBusinessChallengeInteraction() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-business-world"])

        let choice = button("businessChoiceTestAction", in: app)
        choice.tap()

        let nextButton = app.buttons["nextBusinessChallenge"].firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
    }

    // MARK: - Health Subject UI Tests
    func testCanSwitchToHealthSubject() throws {
        let app = launchReadyApp()

        let subjectButton = app.buttons["subjectSwitchButton"].firstMatch
        XCTAssertTrue(subjectButton.waitForExistence(timeout: 3))
        subjectButton.tap()

        let healthOption = app.buttons["subject_health"].firstMatch
        XCTAssertTrue(healthOption.waitForExistence(timeout: 3))
        healthOption.tap()

        let startButton = app.buttons["Start Learning"].firstMatch
        XCTAssertTrue(startButton.waitForExistence(timeout: 3))
        startButton.tap()

        sleep(3)

        let clinicText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Energy Clinic")).firstMatch
        XCTAssertTrue(clinicText.waitForExistence(timeout: 5))
    }

    func testHealthWorldSelection() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-health-world"])

        let worldText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Energy Clinic")).firstMatch
        XCTAssertTrue(worldText.waitForExistence(timeout: 3))
        let habitText = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Habit")).firstMatch
        XCTAssertTrue(habitText.waitForExistence(timeout: 3))
        let unlockPanel = app.descendants(matching: .any)["nextWorldUnlock_health"].firstMatch
        if !unlockPanel.waitForExistence(timeout: 3) {
            app.swipeUp()
        }
        XCTAssertTrue(unlockPanel.waitForExistence(timeout: 3))
    }

    func testHealthChallengeInteraction() throws {
        let app = launchReadyApp(arguments: ["--ui-testing-health-world"])

        let choice = button("healthChoiceTestAction", in: app)
        choice.tap()

        let nextButton = app.buttons["nextHealthChallenge"].firstMatch
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))
    }
}
