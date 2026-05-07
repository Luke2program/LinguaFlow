import Foundation
import AVFoundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published var stats: UserStats = UserStats()
    @Published var schedules: [String: CardSchedule] = [:]
    @Published var currentCard: VocabularyCard?
    @Published var showingAnswer = false
    @Published var combo = 0

    private let scheduler = SpacedRepetitionScheduler()
    private let statsKey = "linguaflow.stats.v1"
    private let schedulesKey = "linguaflow.schedules.v1"
    private let synthesizer = AVSpeechSynthesizer()

    var availableCards: [VocabularyCard] {
        guard let level = stats.selectedLevel else { return [] }
        return VocabularyData.cards.filter { $0.level <= level }
    }
    var dueCount: Int { scheduler.dueCards(from: availableCards, schedules: schedules, limit: 999).count }
    var learnedCount: Int { schedules.values.filter { $0.repetitions > 0 }.count }

    init() { load(); refreshPracticeDay(); pickNextCard() }

    func select(level: CEFRLevel) {
        stats.selectedLevel = level
        for card in VocabularyData.cards where card.level <= level && schedules[card.id] == nil { schedules[card.id] = CardSchedule() }
        save(); pickNextCard()
    }

    func toggleDirection() { stats.direction = stats.direction == .germanToSpanish ? .spanishToGerman : .germanToSpanish; showingAnswer = false; save(); pickNextCard() }

    func reveal() { showingAnswer = true; speakAnswer() }

    func grade(_ grade: ReviewGrade) {
        guard let card = currentCard else { return }
        let old = schedules[card.id] ?? CardSchedule()
        schedules[card.id] = scheduler.nextSchedule(from: old, grade: grade)
        refreshPracticeDay()
        stats.totalReviews += 1
        stats.reviewedToday += 1
        stats.xp += grade.xp
        stats.gems += grade == .easy ? 2 : (grade == .good ? 1 : 0)
        stats.fluentDrops += grade.fluencyDrops
        if grade == .again { combo = 0 } else { combo += 1; stats.correctToday += 1 }
        save()
        showingAnswer = false
        pickNextCard(excluding: card.id)
    }

    func pickNextCard(excluding id: String? = nil) {
        let due = scheduler.dueCards(from: availableCards, schedules: schedules, limit: 30).filter { $0.id != id }
        currentCard = due.first ?? availableCards.filter { $0.id != id }.randomElement() ?? availableCards.first
    }

    func speakPrompt() { speak(currentCard?.prompt(for: stats.direction) ?? "", language: stats.direction.source) }
    func speakAnswer() { speak(currentCard?.answer(for: stats.direction) ?? "", language: stats.direction.target) }

    func speak(_ text: String, language: AppLanguage) {
        guard !text.isEmpty else { return }
        guard !ProcessInfo.processInfo.arguments.contains("--ui-testing") else { return }
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text.replacingOccurrences(of: " / ", with: ", "))
        utterance.voice = AVSpeechSynthesisVoice(language: language.rawValue)
        utterance.rate = 0.46
        synthesizer.speak(utterance)
    }

    private func refreshPracticeDay(now: Date = Date()) {
        let calendar = Calendar.current
        guard let last = stats.lastPracticeDay else {
            stats.lastPracticeDay = now; stats.streak = max(stats.streak, 1); stats.bestStreak = max(stats.bestStreak, stats.streak); return
        }
        if calendar.isDate(last, inSameDayAs: now) { return }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now), calendar.isDate(last, inSameDayAs: yesterday) { stats.streak += 1 }
        else { stats.streak = 1 }
        stats.reviewedToday = 0; stats.correctToday = 0; stats.lastPracticeDay = now; stats.bestStreak = max(stats.bestStreak, stats.streak)
    }

    private func load() {
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
        if let data = UserDefaults.standard.data(forKey: statsKey), let decoded = try? decoder.decode(UserStats.self, from: data) { stats = decoded }
        if let data = UserDefaults.standard.data(forKey: schedulesKey), let decoded = try? decoder.decode([String: CardSchedule].self, from: data) { schedules = decoded }
    }
    private func save() {
        let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601
        UserDefaults.standard.set(try? encoder.encode(stats), forKey: statsKey)
        UserDefaults.standard.set(try? encoder.encode(schedules), forKey: schedulesKey)
    }
}
