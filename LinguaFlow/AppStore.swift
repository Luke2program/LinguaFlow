import Foundation
import AVFoundation
import Speech
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published var stats: UserStats = UserStats()
    @Published var schedules: [String: CardSchedule] = [:]
    @Published var currentCard: VocabularyCard?
    @Published var activeDirection: ReviewDirection = .germanToSpanish
    @Published var challengeMode: ChallengeMode = .word
    @Published var combo = 0
    @Published var spokenTranscript = ""
    @Published var isListening = false
    @Published var feedbackMessage = ""
    @Published var speechMessage = "Tap Speak, say the answer, then tap Use speech."
    @Published var showingSettings = false
    @Published var newlyUnlockedLevel: CEFRLevel? = nil
    @Published var pomodoroRemaining = 25 * 60
    @Published var pomodoroRunning = false
    @Published var pomodoroIsBreak = false

    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()
    private var pomodoroTimer: Timer?

    private let scheduler = SpacedRepetitionScheduler()
    private let statsKey = "linguaflow.stats.v2"
    private let schedulesKey = "linguaflow.schedules.v1"
    private let synthesizer = AVSpeechSynthesizer()

    var availableCards: [VocabularyCard] {
        guard let level = stats.selectedLevel else { return [] }
        return VocabularyData.cards.filter { $0.level <= level }
    }
    var dueCount: Int { scheduler.dueCards(from: availableCards, schedules: schedules, limit: 999).count }
    var learnedCount: Int { schedules.values.filter { $0.repetitions > 0 }.count }
    var masteredCount: Int { schedules.values.filter { $0.repetitions >= 3 && $0.easeFactor >= 2.3 }.count }
    var currentPrompt: String { currentCard?.prompt(for: activeDirection, mode: challengeMode) ?? "" }
    var currentAnswer: String { currentCard?.answer(for: activeDirection, mode: challengeMode) ?? "" }
    var daysUntilGoal: Int { max(1, Calendar.current.dateComponents([.day], from: Date(), to: stats.goalDate).day ?? 1) }
    var realFluency: Double {
        let total = max(1, availableCards.count)
        return Double(masteredCount) / Double(total)
    }
    var goalDailyNeed: Int { max(5, Int(ceil(Double(availableCards.count - masteredCount) / Double(daysUntilGoal)))) }
    var learnedEnoughToday: Bool { stats.reviewedToday >= max(stats.dailyGoal, goalDailyNeed) }

    init() { load(); refreshPracticeDay(); resetPomodoro(); pickNextCard() }

    func finishTitle() { stats.hasSeenTitle = true; save() }

    func select(level: CEFRLevel) {
        stats.selectedLevel = level
        if !stats.unlockedLevels.contains(level) { stats.unlockedLevels.append(level) }
        for card in VocabularyData.cards where card.level <= level && schedules[card.id] == nil { schedules[card.id] = CardSchedule() }
        save(); pickNextCard()
    }

    func isLevelCompleted(_ level: CEFRLevel) -> Bool {
        let cards = VocabularyData.cards.filter { $0.level == level }
        guard !cards.isEmpty else { return false }
        let mastered = cards.filter { card in
            let s = schedules[card.id]
            return (s?.repetitions ?? 0) >= 3 && (s?.easeFactor ?? 0) >= 2.3
        }.count
        return Double(mastered) / Double(cards.count) >= 0.8
    }

    func checkForLevelUnlock() {
        guard let current = stats.selectedLevel else { return }
        guard isLevelCompleted(current) else { return }
        guard let nextIndex = CEFRLevel.allCases.firstIndex(of: current)?.advanced(by: 1),
              nextIndex < CEFRLevel.allCases.count else { return }
        let next = CEFRLevel.allCases[nextIndex]
        guard !stats.unlockedLevels.contains(next) else { return }
        stats.unlockedLevels.append(next)
        newlyUnlockedLevel = next
        save()
    }

    func toggleDirection() { stats.autoMixDirections.toggle(); feedbackMessage = stats.autoMixDirections ? "Auto-mix is on: German → Spanish and Spanish → German rotate automatically." : "Auto-mix off. Tap again to enable."; save() }

    func grade(_ grade: ReviewGrade, expected: String) {
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
        // Feed pet on correct answers
        if grade != .again {
            feedPet(correctCount: grade == .easy ? 2 : 1)
        }
        save()
        checkForLevelUnlock()
        pickNextCard(excluding: card.id)
    }

    func feedPet(correctCount: Int) {
        stats.pet.feed(correctAnswers: correctCount)
        // Add pet reaction to feedback
        let petReaction = stats.pet.mood == .happy ? " \(stats.pet.emoji)" : ""
        if !petReaction.isEmpty && !feedbackMessage.isEmpty {
            feedbackMessage += petReaction
        }
    }

    func pickNextCard(excluding id: String? = nil) {
        feedbackMessage = ""
        let due = scheduler.dueCards(from: availableCards, schedules: schedules, limit: 30).filter { $0.id != id }
        currentCard = due.first ?? availableCards.filter { $0.id != id }.randomElement() ?? availableCards.first
        activeDirection = stats.autoMixDirections ? (stats.totalReviews.isMultiple(of: 2) ? .germanToSpanish : .spanishToGerman) : stats.direction
        challengeMode = stats.totalReviews > 0 && stats.totalReviews.isMultiple(of: 4) ? .sentence : .word
    }

    @discardableResult
    func submit(answer attempt: String) -> AnswerEvaluator.Result {
        let expected = currentAnswer
        let result = AnswerEvaluator.evaluate(attempt, expected: expected)
        switch result {
        case .correct:
            feedbackMessage = "✅ Correct. +fluency 💧"
            grade(.good, expected: expected)
        case .almost:
            feedbackMessage = "🟡 Almost. Correct answer: \(expected). It comes back sooner."
            grade(.hard, expected: expected)
        case .wrong:
            feedbackMessage = "❌ Not quite. Correct answer: \(expected). It comes back in 10 minutes."
            grade(.again, expected: expected)
        }
        return result
    }

    func speakPrompt() { speak(currentPrompt, language: activeDirection.source) }
    func speakAnswer() { speak(currentAnswer, language: activeDirection.target) }

    func startSpeechInput() {
        guard !ProcessInfo.processInfo.arguments.contains("--ui-testing") else { speechMessage = "Speech is disabled during UI tests."; return }
        stopSpeechInput()
        spokenTranscript = ""
        speechMessage = "Listening…"
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: activeDirection.target.rawValue))
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                guard status == .authorized else { self?.speechMessage = "Speech permission is needed. You can still type the answer."; return }
                self?.beginRecognition(with: recognizer)
            }
        }
    }

    func stopSpeechInput() {
        if audioEngine.isRunning { audioEngine.stop(); audioEngine.inputNode.removeTap(onBus: 0) }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isListening = false
        if spokenTranscript.isEmpty { speechMessage = "I didn’t catch that. Try again or type it." }
    }

    private func beginRecognition(with recognizer: SFSpeechRecognizer?) {
        guard let recognizer, recognizer.isAvailable else { speechMessage = "Speech recognition is unavailable right now. Typing still works."; return }
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request
        let inputNode = audioEngine.inputNode
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            if let result { DispatchQueue.main.async { self?.spokenTranscript = result.bestTranscription.formattedString; self?.speechMessage = "Heard: \(result.bestTranscription.formattedString)" } }
            if error != nil || result?.isFinal == true { DispatchQueue.main.async { self?.stopSpeechInput() } }
        }
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in request.append(buffer) }
        do { try audioEngine.start(); isListening = true } catch { speechMessage = "Mic failed to start. Type the answer instead."; stopSpeechInput() }
    }

    func speak(_ text: String, language: AppLanguage) {
        guard !text.isEmpty else { return }
        guard !ProcessInfo.processInfo.arguments.contains("--ui-testing") else { return }
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text.replacingOccurrences(of: " / ", with: ", "))
        utterance.voice = AVSpeechSynthesisVoice(language: language.rawValue)
        utterance.rate = 0.46
        synthesizer.speak(utterance)
    }

    func updateGoal(name: String, date: Date, dailyGoal: Int) {
        stats.goalName = name.isEmpty ? "Speak fluently" : name
        stats.goalDate = date
        stats.dailyGoal = max(5, dailyGoal)
        save()
    }

    func resetPomodoro() { pomodoroRemaining = (pomodoroIsBreak ? stats.breakMinutes : stats.workMinutes) * 60 }
    func togglePomodoro() {
        pomodoroRunning.toggle()
        if pomodoroRunning { startPomodoroTimer() } else { pomodoroTimer?.invalidate() }
    }
    func setPomodoro(work: Int, pause: Int) { stats.workMinutes = max(5, work); stats.breakMinutes = max(1, pause); pomodoroIsBreak = false; resetPomodoro(); save() }
    private func startPomodoroTimer() {
        pomodoroTimer?.invalidate()
        pomodoroTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.pomodoroRemaining > 0 { self.pomodoroRemaining -= 1 }
                else { self.pomodoroIsBreak.toggle(); self.resetPomodoro() }
            }
        }
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
    func save() {
        let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601
        UserDefaults.standard.set(try? encoder.encode(stats), forKey: statsKey)
        UserDefaults.standard.set(try? encoder.encode(schedules), forKey: schedulesKey)
    }
}
