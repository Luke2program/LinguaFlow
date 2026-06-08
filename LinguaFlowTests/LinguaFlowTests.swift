import XCTest
@testable import LinguaFlow

final class LinguaFlowTests: XCTestCase {
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
        XCTAssertEqual(subjects.count, 6)
        XCTAssertTrue(subjects.contains(.languages))
        XCTAssertTrue(subjects.contains(.history))
        XCTAssertTrue(subjects.contains(.science))
        XCTAssertTrue(subjects.contains(.geography))
        XCTAssertTrue(subjects.contains(.math))
        XCTAssertTrue(subjects.contains(.culture))
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
            
            store.submitHistoryAnswer(challenge: challenge, choice: correctChoice)
            
            XCTAssertEqual(store.stats.xp, initialXP + 25)
            XCTAssertEqual(store.stats.gems, 2)
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
            
            store.submitScienceAnswer(challenge: challenge, choice: correctChoice)
            
            XCTAssertEqual(store.stats.xp, initialXP + 25)
            XCTAssertEqual(store.stats.gems, 2)
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
    
    func testSubjectDefaultIsLanguages() {
        let stats = UserStats()
        XCTAssertEqual(stats.selectedSubject, .languages)
    }
}
