import XCTest
@testable import LinguaFlow

final class LinguaFlowTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        UserDefaults.standard.removeObject(forKey: "linguaflow.stats.v2")
        UserDefaults.standard.removeObject(forKey: "linguaflow.schedules.v1")
    }

    func testSchedulerGraduatesLikeAnki() {
        let scheduler = SpacedRepetitionScheduler(calendar: Calendar(identifier: .gregorian))
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let first = scheduler.nextSchedule(from: CardSchedule(), grade: .good, now: now)
        XCTAssertEqual(first.repetitions, 1)
        XCTAssertEqual(first.intervalDays, 1)
        XCTAssertGreaterThan(first.dueDate, now)
        let second = scheduler.nextSchedule(from: first, grade: .easy, now: now)
        XCTAssertEqual(second.repetitions, 2)
        XCTAssertGreaterThan(second.easeFactor, first.easeFactor)
        XCTAssertGreaterThanOrEqual(second.intervalDays, 5)
    }

    func testAgainCreatesShortRetryAndLapse() {
        let scheduler = SpacedRepetitionScheduler()
        let now = Date()
        let failed = scheduler.nextSchedule(from: CardSchedule(repetitions: 4, intervalDays: 20, easeFactor: 2.5, dueDate: now, lapses: 0), grade: .again, now: now)
        XCTAssertEqual(failed.repetitions, 0)
        XCTAssertEqual(failed.intervalDays, 0)
        XCTAssertEqual(failed.lapses, 1)
        XCTAssertLessThan(failed.dueDate.timeIntervalSince(now), 700)
    }

    func testVocabularyContainsBothDirectionsAndLevels() {
        XCTAssertGreaterThanOrEqual(VocabularyData.cards.count, 125)
        let hasHelloCard = VocabularyData.cards.contains { card in
            card.level == .a1 && card.sourceText == "Hallo" && card.targetText == "Hola"
        }
        XCTAssertTrue(hasHelloCard)

        let waterCard = VocabularyCard(
            id: "x",
            german: "Wasser",
            spanish: "agua",
            level: .a1,
            category: "noun",
            exampleGerman: "",
            exampleSpanish: "",
            hint: ""
        )
        XCTAssertEqual(waterCard.prompt(for: .targetToSource), "agua")
    }

    func testAnswerEvaluatorAcceptsTypedAndNearSpeechAnswers() {
        XCTAssertEqual(AnswerEvaluator.evaluate("sí", expected: "sí"), .correct)
        XCTAssertEqual(AnswerEvaluator.evaluate("si", expected: "sí"), .correct)
        XCTAssertEqual(AnswerEvaluator.evaluate("buenno", expected: "bueno"), .almost)
        XCTAssertEqual(AnswerEvaluator.evaluate("adios", expected: "Hola"), .wrong)
        XCTAssertEqual(AnswerEvaluator.evaluate("estar", expected: "ser / estar"), .correct)
    }
    
    // MARK: - Subject System Tests
    func testSubjectEnumHasAllCases() {
        let subjects = Subject.allCases
        XCTAssertEqual(subjects.count, 8)
        XCTAssertTrue(subjects.contains(.languages))
        XCTAssertTrue(subjects.contains(.history))
        XCTAssertTrue(subjects.contains(.science))
        XCTAssertTrue(subjects.contains(.geography))
        XCTAssertTrue(subjects.contains(.math))
        XCTAssertTrue(subjects.contains(.culture))
        XCTAssertTrue(subjects.contains(.business))
        XCTAssertTrue(subjects.contains(.health))
    }

    func testDailyQuestProgressAndRewardScaleWithTarget() {
        let quest = DailyQuest(subject: .history, completed: 3, target: 6)
        XCTAssertEqual(quest.title, "Recover a real timeline")
        XCTAssertEqual(quest.progressText, "3/6 encounters")
        XCTAssertEqual(quest.reward, "+18 XP · Archive Seal")
        XCTAssertEqual(quest.progress, 0.5, accuracy: 0.001)

        let completedQuest = DailyQuest(subject: .business, completed: 12, target: 6)
        XCTAssertEqual(completedQuest.progressText, "6/6 encounters")
        XCTAssertEqual(completedQuest.progress, 1.0, accuracy: 0.001)
        XCTAssertEqual(completedQuest.reward, "+18 XP · Guild Coin")
    }

    func testPlayableSubjectsHaveGeneratedMapMetadata() {
        XCTAssertEqual(Subject.history.mapTitle, "History Map")
        XCTAssertEqual(Subject.geography.mapTitle, "Atlas Map")
        XCTAssertEqual(Subject.math.mapTitle, "Puzzle Map")
        XCTAssertFalse(Subject.history.mapSystemImage.isEmpty)
        XCTAssertFalse(Subject.culture.mapSystemImage.isEmpty)
    }
    
    func testHistoryWorldsExist() {
        let historyWorlds = Subject.history.worlds
        XCTAssertGreaterThanOrEqual(historyWorlds.count, 3)
        XCTAssertTrue(historyWorlds.contains { $0.id == "ancient-rome" })
        XCTAssertTrue(historyWorlds.contains { $0.id == "medieval-europe" })
    }
    
    func testAncientRomeChallengesLoaded() {
        let challenges = HistoryData.challenges(for: "ancient-rome")
        XCTAssertGreaterThanOrEqual(challenges.count, 3)
        let rubicon = challenges.first { $0.id == "rome-01" }
        XCTAssertNotNil(rubicon)
        XCTAssertEqual(rubicon?.year, -49)
        XCTAssertEqual(rubicon?.choices.count, 2)
        XCTAssertTrue(rubicon?.choices.contains { $0.isCorrect } ?? false)
    }
    
    func testWorldUnlockRequirement() {
        let unlocked = PlayableWorld(id: "test", name: "Test", emoji: "🧪", era: "Now", description: "Test", unlockRequirement: .none)
        let locked = PlayableWorld(id: "test2", name: "Test2", emoji: "🧪", era: "Now", description: "Test", unlockRequirement: .xpRequired(1000))
        XCTAssertTrue(unlocked.isUnlocked)
        XCTAssertEqual(locked.unlockRequirement.xpRequired, 1000)
    }
    
    func testHistoryChallengeScoring() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .history
            store.select(worldId: "ancient-rome", for: .history)
            
            let challenge = HistoryData.challenges(for: "ancient-rome")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            let initialXP = store.stats.xp
            let initialGems = store.stats.gems
            
            store.submitHistoryAnswer(challenge: challenge, choice: correctChoice)
            
            XCTAssertEqual(store.stats.xp, initialXP + 25)
            XCTAssertEqual(store.stats.gems, initialGems + 2)
            let progress = store.stats.progress(for: .history)
            XCTAssertTrue(progress.completedChallengeIds.contains(challenge.id))
        }
    }
    
    func testSubjectProgressPersistence() {
        var stats = UserStats()
        stats.selectedSubject = .history
        var progress = stats.progress(for: .history)
        progress.currentWorldId = "ancient-rome"
        progress.completedChallengeIds = ["rome-01"]
        progress.totalHistoryXP = 25
        stats.updateProgress(for: .history, progress)
        
        let retrieved = stats.progress(for: .history)
        XCTAssertEqual(retrieved.currentWorldId, "ancient-rome")
        XCTAssertEqual(retrieved.completedChallengeIds, ["rome-01"])
        XCTAssertEqual(retrieved.totalHistoryXP, 25)
    }
    
    func testScienceWorldsExist() {
        let scienceWorlds = Subject.science.worlds
        XCTAssertGreaterThanOrEqual(scienceWorlds.count, 2)
        XCTAssertTrue(scienceWorlds.contains { $0.id == "space-exploration" })
        XCTAssertTrue(scienceWorlds.contains { $0.id == "quantum-realm" })
    }
    
    func testSpaceExplorationChallengesLoaded() {
        let challenges = ScienceData.challenges(for: "space-exploration")
        XCTAssertGreaterThanOrEqual(challenges.count, 3)
        let sputnik = challenges.first { $0.id == "space-01" }
        XCTAssertNotNil(sputnik)
        XCTAssertEqual(sputnik?.era, "1957")
        XCTAssertEqual(sputnik?.choices.count, 4)
        XCTAssertTrue(sputnik?.choices.contains { $0.isCorrect } ?? false)
    }
    
    func testScienceChallengeScoring() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .science
            store.select(worldId: "space-exploration", for: .science)
            
            let challenge = ScienceData.challenges(for: "space-exploration")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            let initialXP = store.stats.xp
            let initialGems = store.stats.gems
            
            store.submitScienceAnswer(challenge: challenge, choice: correctChoice)
            
            XCTAssertEqual(store.stats.xp, initialXP + 25)
            XCTAssertEqual(store.stats.gems, initialGems + 2)
            let progress = store.stats.progress(for: .science)
            XCTAssertTrue(progress.completedChallengeIds.contains(challenge.id))
        }
    }
    
    func testScienceProgressPercent() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .science
            store.select(worldId: "space-exploration", for: .science)
            
            let challenges = ScienceData.challenges(for: "space-exploration")
            XCTAssertGreaterThan(challenges.count, 0)
            
            // Complete first challenge
            let challenge = challenges[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            store.submitScienceAnswer(challenge: challenge, choice: correctChoice)
            
            let percent = store.scienceProgressPercent
            XCTAssertGreaterThan(percent, 0)
            XCTAssertLessThanOrEqual(percent, 1.0)
        }
    }

    func testGeographyWorldsExist() {
        let geographyWorlds = Subject.geography.worlds
        XCTAssertGreaterThanOrEqual(geographyWorlds.count, 2)
        XCTAssertTrue(geographyWorlds.contains { $0.id == "european-capitals" })
        XCTAssertTrue(geographyWorlds.contains { $0.id == "african-wonders" })
    }

    func testEuropeanCapitalsChallengesLoaded() {
        let challenges = GeographyData.challenges(for: "european-capitals")
        XCTAssertGreaterThanOrEqual(challenges.count, 4)
        let vienna = challenges.first { $0.id == "geo-eu-01" }
        XCTAssertNotNil(vienna)
        XCTAssertEqual(vienna?.region, "Central Europe")
        XCTAssertEqual(vienna?.choices.count, 4)
        XCTAssertTrue(vienna?.choices.contains { $0.isCorrect && $0.text == "Vienna" } ?? false)
    }

    func testGeographyChallengeScoring() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .geography
            store.select(worldId: "european-capitals", for: .geography)

            let challenge = GeographyData.challenges(for: "european-capitals")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            let initialXP = store.stats.xp
            let initialGems = store.stats.gems

            store.submitGeographyAnswer(challenge: challenge, choice: correctChoice)

            XCTAssertEqual(store.stats.xp, initialXP + 25)
            XCTAssertEqual(store.stats.gems, initialGems + 2)
            let progress = store.stats.progress(for: .geography)
            XCTAssertTrue(progress.completedChallengeIds.contains(challenge.id))
        }
    }

    func testGeographyProgressPercent() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .geography
            store.select(worldId: "european-capitals", for: .geography)

            let challenge = GeographyData.challenges(for: "european-capitals")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            store.submitGeographyAnswer(challenge: challenge, choice: correctChoice)

            let percent = store.geographyProgressPercent
            XCTAssertGreaterThan(percent, 0)
            XCTAssertLessThanOrEqual(percent, 1.0)
        }
    }

    func testMathWorldsExist() {
        let mathWorlds = Subject.math.worlds
        XCTAssertGreaterThanOrEqual(mathWorlds.count, 2)
        XCTAssertTrue(mathWorlds.contains { $0.id == "logic-gates" })
        XCTAssertTrue(mathWorlds.contains { $0.id == "probability-casino" })
    }

    func testLogicGateChallengesLoaded() {
        let challenges = MathData.challenges(for: "logic-gates")
        XCTAssertGreaterThanOrEqual(challenges.count, 4)
        let doubling = challenges.first { $0.id == "math-logic-01" }
        XCTAssertNotNil(doubling)
        XCTAssertEqual(doubling?.domain, "Sequences")
        XCTAssertEqual(doubling?.choices.count, 4)
        XCTAssertTrue(doubling?.choices.contains { $0.isCorrect && $0.text == "48" } ?? false)
    }

    func testMathChallengeScoring() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .math
            store.select(worldId: "logic-gates", for: .math)

            let challenge = MathData.challenges(for: "logic-gates")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            let initialXP = store.stats.xp
            let initialGems = store.stats.gems

            store.submitMathAnswer(challenge: challenge, choice: correctChoice)

            XCTAssertEqual(store.stats.xp, initialXP + 25)
            XCTAssertEqual(store.stats.gems, initialGems + 2)
            let progress = store.stats.progress(for: .math)
            XCTAssertTrue(progress.completedChallengeIds.contains(challenge.id))
        }
    }

    func testMathProgressPercent() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .math
            store.select(worldId: "logic-gates", for: .math)

            let challenge = MathData.challenges(for: "logic-gates")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            store.submitMathAnswer(challenge: challenge, choice: correctChoice)

            let percent = store.mathProgressPercent
            XCTAssertGreaterThan(percent, 0)
            XCTAssertLessThanOrEqual(percent, 1.0)
        }
    }

    func testCultureWorldsExist() {
        let cultureWorlds = Subject.culture.worlds
        XCTAssertGreaterThanOrEqual(cultureWorlds.count, 2)
        XCTAssertTrue(cultureWorlds.contains { $0.id == "heritage-kitchens" })
        XCTAssertTrue(cultureWorlds.contains { $0.id == "festival-roads" })
    }

    func testHeritageKitchenChallengesLoaded() {
        let challenges = CultureData.challenges(for: "heritage-kitchens")
        XCTAssertGreaterThanOrEqual(challenges.count, 4)
        let ramen = challenges.first { $0.id == "culture-kitchen-01" }
        XCTAssertNotNil(ramen)
        XCTAssertEqual(ramen?.region, "Japan")
        XCTAssertEqual(ramen?.choices.count, 4)
        XCTAssertTrue(ramen?.choices.contains { $0.isCorrect && $0.text.contains("Slurp") } ?? false)
    }

    func testCultureChallengeScoring() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .culture
            store.select(worldId: "heritage-kitchens", for: .culture)

            let challenge = CultureData.challenges(for: "heritage-kitchens")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            let initialXP = store.stats.xp
            let initialGems = store.stats.gems

            store.submitCultureAnswer(challenge: challenge, choice: correctChoice)

            XCTAssertEqual(store.stats.xp, initialXP + 25)
            XCTAssertEqual(store.stats.gems, initialGems + 2)
            let progress = store.stats.progress(for: .culture)
            XCTAssertTrue(progress.completedChallengeIds.contains(challenge.id))
        }
    }

    func testCultureProgressPercent() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .culture
            store.select(worldId: "heritage-kitchens", for: .culture)

            let challenge = CultureData.challenges(for: "heritage-kitchens")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            store.submitCultureAnswer(challenge: challenge, choice: correctChoice)

            let percent = store.cultureProgressPercent
            XCTAssertGreaterThan(percent, 0)
            XCTAssertLessThanOrEqual(percent, 1.0)
        }
    }

    func testSelectingGeographyStartsFirstWorld() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true

            store.select(subject: .geography)

            XCTAssertEqual(store.stats.selectedSubject, .geography)
            XCTAssertEqual(store.currentWorld?.id, "european-capitals")
            XCTAssertNotNil(store.nextGeographyChallenge)
        }
    }

    func testSelectingMathStartsFirstWorld() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true

            store.select(subject: .math)

            XCTAssertEqual(store.stats.selectedSubject, .math)
            XCTAssertEqual(store.currentWorld?.id, "logic-gates")
            XCTAssertNotNil(store.nextMathChallenge)
        }
    }

    func testSelectingCultureStartsFirstWorld() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true

            store.select(subject: .culture)

            XCTAssertEqual(store.stats.selectedSubject, .culture)
            XCTAssertEqual(store.currentWorld?.id, "heritage-kitchens")
            XCTAssertNotNil(store.nextCultureChallenge)
        }
    }
    
    func testSubjectDefaultIsLanguages() {
        let stats = UserStats()
        XCTAssertEqual(stats.selectedSubject, .languages)
    }
}
