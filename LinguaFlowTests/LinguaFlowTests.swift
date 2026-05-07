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
        XCTAssertTrue(VocabularyData.cards.contains { $0.level == .a1 && $0.german == "Hallo" && $0.spanish == "Hola" })
        XCTAssertEqual(VocabularyCard(id: "x", german: "Wasser", spanish: "agua", level: .a1, category: "noun", exampleGerman: "", exampleSpanish: "", hint: "").prompt(for: .spanishToGerman), "agua")
    }

    func testAnswerEvaluatorAcceptsTypedAndNearSpeechAnswers() {
        XCTAssertEqual(AnswerEvaluator.evaluate("sí", expected: "sí"), .correct)
        XCTAssertEqual(AnswerEvaluator.evaluate("si", expected: "sí"), .correct)
        XCTAssertEqual(AnswerEvaluator.evaluate("buenno", expected: "bueno"), .almost)
        XCTAssertEqual(AnswerEvaluator.evaluate("adios", expected: "Hola"), .wrong)
        XCTAssertEqual(AnswerEvaluator.evaluate("estar", expected: "ser / estar"), .correct)
    }
}
