import Foundation
import AVFoundation
import Speech
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published var stats: UserStats = UserStats()
    @Published var schedules: [String: CardSchedule] = [:]
    @Published var currentCard: VocabularyCard?
    @Published var activeDirection: ReviewDirection = .sourceToTarget
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
        return VocabularyData.cards(for: stats.selectedLanguagePair).filter { $0.level <= level }
    }
    var dueCount: Int { scheduler.dueCards(from: availableCards, schedules: schedules, limit: 999).count }
    var learnedCount: Int { availableCards.filter { (schedules[$0.id]?.repetitions ?? 0) > 0 }.count }
    var masteredCount: Int { availableCards.filter { (schedules[$0.id]?.repetitions ?? 0) >= 3 && (schedules[$0.id]?.easeFactor ?? 0) >= 2.3 }.count }
    var currentPrompt: String { currentCard?.prompt(for: activeDirection, mode: challengeMode) ?? "" }
    var currentAnswer: String { currentCard?.answer(for: activeDirection, mode: challengeMode) ?? "" }
    var daysUntilGoal: Int { max(1, Calendar.current.dateComponents([.day], from: Date(), to: stats.goalDate).day ?? 1) }
    var realFluency: Double {
        let total = max(1, availableCards.count)
        return Double(masteredCount) / Double(total)
    }
    var goalDailyNeed: Int { max(5, Int(ceil(Double(availableCards.count - masteredCount) / Double(daysUntilGoal)))) }
    var learnedEnoughToday: Bool { stats.reviewedToday >= max(stats.dailyGoal, goalDailyNeed) }
    var dailyQuest: DailyQuest {
        DailyQuest(subject: stats.selectedSubject, completed: stats.reviewedToday, target: min(10, max(4, stats.dailyGoal / 2)))
    }

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--reset-ui-state") {
            UserDefaults.standard.removeObject(forKey: statsKey)
            UserDefaults.standard.removeObject(forKey: schedulesKey)
        }
        load()
        if arguments.contains("--ui-testing") {
            stats.hasSeenTitle = true
            stats.hasSkippedAuth = true
            stats.hasSeenPetPicker = true
            stats.hasSeenSubjectPicker = true
            if stats.selectedLevel == nil { stats.selectedLevel = .a1 }
            if arguments.contains("--ui-testing-history-world") {
                stats.selectedSubject = .history
                var progress = stats.progress(for: .history)
                progress.currentWorldId = "ancient-rome"
                progress.completedChallengeIds = []
                stats.updateProgress(for: .history, progress)
            }
            if arguments.contains("--ui-testing-science-world") {
                stats.selectedSubject = .science
                var progress = stats.progress(for: .science)
                progress.currentWorldId = "space-exploration"
                progress.completedChallengeIds = []
                stats.updateProgress(for: .science, progress)
            }
            if arguments.contains("--ui-testing-geography-world") {
                stats.selectedSubject = .geography
                var progress = stats.progress(for: .geography)
                progress.currentWorldId = "european-capitals"
                progress.completedChallengeIds = []
                stats.updateProgress(for: .geography, progress)
            }
            if arguments.contains("--ui-testing-math-world") {
                stats.selectedSubject = .math
                var progress = stats.progress(for: .math)
                progress.currentWorldId = "logic-gates"
                progress.completedChallengeIds = []
                stats.updateProgress(for: .math, progress)
            }
            if arguments.contains("--ui-testing-culture-world") {
                stats.selectedSubject = .culture
                var progress = stats.progress(for: .culture)
                progress.currentWorldId = "heritage-kitchens"
                progress.completedChallengeIds = []
                stats.updateProgress(for: .culture, progress)
            }
            if arguments.contains("--ui-testing-business-world") {
                stats.selectedSubject = .business
                var progress = stats.progress(for: .business)
                progress.currentWorldId = "founder-guild"
                progress.completedChallengeIds = []
                stats.updateProgress(for: .business, progress)
            }
            prepareSchedulesForCurrentSelection()
        }
        refreshPracticeDay(); resetPomodoro(); pickNextCard()
    }

    func finishTitle() { stats.hasSeenTitle = true; save() }

    func select(level: CEFRLevel) {
        stats.selectedLevel = level
        if !stats.unlockedLevels.contains(level) { stats.unlockedLevels.append(level) }
        prepareSchedulesForCurrentSelection()
        save(); pickNextCard()
    }

    func select(languagePair: LanguagePair) {
        stats.selectedLanguagePair = languagePair
        stats.direction = .sourceToTarget
        prepareSchedulesForCurrentSelection()
        feedbackMessage = "Learning language changed to \(languagePair.displayName)."
        save(); pickNextCard()
    }

    func prepareSchedulesForCurrentSelection() {
        guard let level = stats.selectedLevel else { return }
        for card in VocabularyData.cards(for: stats.selectedLanguagePair) where card.level <= level && schedules[card.id] == nil { schedules[card.id] = CardSchedule() }
    }

    func isLevelCompleted(_ level: CEFRLevel) -> Bool {
        let cards = VocabularyData.cards(for: stats.selectedLanguagePair).filter { $0.level == level }
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

    func toggleDirection() { stats.autoMixDirections.toggle(); feedbackMessage = stats.autoMixDirections ? "Auto-mix is on: languages rotate automatically." : "Auto-mix off. Tap again to enable."; save() }

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
        let bonusMultiplier = stats.pet.abilities.contains(where: { $0.name == "XP Boost" }) ? 1.1 : 1.0
        let gemsToAdd = stats.pet.abilities.contains(where: { $0.name == "Gem Hunter" }) ? correctCount : 0
        stats.pet.evolvedFeed(correctAnswers: correctCount)
        stats.gems += gemsToAdd
        let xpBonus = Int(Double(correctCount * 10) * bonusMultiplier)
        stats.pet.addXP(xpBonus)
        let petReaction = stats.pet.mood == .happy ? " \(stats.pet.currentEmoji)" : ""
        if !petReaction.isEmpty && !feedbackMessage.isEmpty {
            feedbackMessage += petReaction
        }
    }

    func pickNextCard(excluding id: String? = nil) {
        
        let due = scheduler.dueCards(from: availableCards, schedules: schedules, limit: 30).filter { $0.id != id }
        currentCard = due.first ?? availableCards.filter { $0.id != id }.randomElement() ?? availableCards.first
        activeDirection = stats.autoMixDirections ? (stats.totalReviews.isMultiple(of: 2) ? .sourceToTarget : .targetToSource) : stats.direction
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

    func speakPrompt() { speak(currentPrompt, language: activeDirection == .sourceToTarget ? stats.selectedLanguagePair.source : stats.selectedLanguagePair.target) }
    func speakAnswer() { speak(currentAnswer, language: activeDirection == .sourceToTarget ? stats.selectedLanguagePair.target : stats.selectedLanguagePair.source) }

    func startSpeechInput() {
        guard !ProcessInfo.processInfo.arguments.contains("--ui-testing") else { speechMessage = "Speech is disabled during UI tests."; return }
        stopSpeechInput()
        spokenTranscript = ""
        speechMessage = "Listening…"
        let targetLang = activeDirection == .sourceToTarget ? stats.selectedLanguagePair.target : stats.selectedLanguagePair.source
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: targetLang.rawValue))
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

    func select(subject: Subject) {
        stats.selectedSubject = subject
        feedbackMessage = "Now learning: \(subject.displayName)"
        if subject == .languages {
            pickNextCard()
        } else {
            var progress = stats.progress(for: subject)
            if progress.currentWorldId == nil, let firstWorld = subject.worlds.first {
                progress.currentWorldId = firstWorld.id
                stats.updateProgress(for: subject, progress)
            }
        }
        save()
        objectWillChange.send()
    }
    
    func select(worldId: String, for subject: Subject) {
        var progress = stats.progress(for: subject)
        progress.currentWorldId = worldId
        stats.updateProgress(for: subject, progress)
        save()
    }
    
    func submitHistoryAnswer(challenge: HistoryChallenge, choice: HistoryChoice) {
        var progress = stats.progress(for: .history)
        if !progress.completedChallengeIds.contains(challenge.id) {
            progress.completedChallengeIds.append(challenge.id)
            let xpEarned = choice.isCorrect ? 25 : 10
            progress.totalHistoryXP += xpEarned
            stats.xp += xpEarned
            stats.gems += choice.isCorrect ? 2 : 0
            stats.reviewedToday += 1
            if choice.isCorrect { stats.correctToday += 1 }
            progress.worldScores[challenge.worldId, default: 0] += xpEarned
            feedPet(correctCount: choice.isCorrect ? 2 : 1)
        }
        stats.updateProgress(for: .history, progress)
        refreshPracticeDay()
        save()
    }
    
    func submitScienceAnswer(challenge: ScienceChallenge, choice: ScienceChoice) {
        var progress = stats.progress(for: .science)
        if !progress.completedChallengeIds.contains(challenge.id) {
            progress.completedChallengeIds.append(challenge.id)
            let xpEarned = choice.isCorrect ? 25 : 10
            progress.totalHistoryXP += xpEarned
            stats.xp += xpEarned
            stats.gems += choice.isCorrect ? 2 : 0
            stats.reviewedToday += 1
            if choice.isCorrect { stats.correctToday += 1 }
            progress.worldScores[challenge.worldId, default: 0] += xpEarned
            feedPet(correctCount: choice.isCorrect ? 2 : 1)
        }
        stats.updateProgress(for: .science, progress)
        refreshPracticeDay()
        save()
    }

    func submitGeographyAnswer(challenge: GeographyChallenge, choice: GeographyChoice) {
        var progress = stats.progress(for: .geography)
        if !progress.completedChallengeIds.contains(challenge.id) {
            progress.completedChallengeIds.append(challenge.id)
            let xpEarned = choice.isCorrect ? 25 : 10
            progress.totalHistoryXP += xpEarned
            stats.xp += xpEarned
            stats.gems += choice.isCorrect ? 2 : 0
            stats.reviewedToday += 1
            if choice.isCorrect { stats.correctToday += 1 }
            progress.worldScores[challenge.worldId, default: 0] += xpEarned
            feedPet(correctCount: choice.isCorrect ? 2 : 1)
        }
        stats.updateProgress(for: .geography, progress)
        refreshPracticeDay()
        save()
    }

    func submitMathAnswer(challenge: MathChallenge, choice: MathChoice) {
        var progress = stats.progress(for: .math)
        if !progress.completedChallengeIds.contains(challenge.id) {
            progress.completedChallengeIds.append(challenge.id)
            let xpEarned = choice.isCorrect ? 25 : 10
            progress.totalHistoryXP += xpEarned
            stats.xp += xpEarned
            stats.gems += choice.isCorrect ? 2 : 0
            stats.reviewedToday += 1
            if choice.isCorrect { stats.correctToday += 1 }
            progress.worldScores[challenge.worldId, default: 0] += xpEarned
            feedPet(correctCount: choice.isCorrect ? 2 : 1)
        }
        stats.updateProgress(for: .math, progress)
        refreshPracticeDay()
        save()
    }

    func submitCultureAnswer(challenge: CultureChallenge, choice: CultureChoice) {
        var progress = stats.progress(for: .culture)
        if !progress.completedChallengeIds.contains(challenge.id) {
            progress.completedChallengeIds.append(challenge.id)
            let xpEarned = choice.isCorrect ? 25 : 10
            progress.totalHistoryXP += xpEarned
            stats.xp += xpEarned
            stats.gems += choice.isCorrect ? 2 : 0
            stats.reviewedToday += 1
            if choice.isCorrect { stats.correctToday += 1 }
            progress.worldScores[challenge.worldId, default: 0] += xpEarned
            feedPet(correctCount: choice.isCorrect ? 2 : 1)
        }
        stats.updateProgress(for: .culture, progress)
        refreshPracticeDay()
        save()
    }

    func submitBusinessAnswer(challenge: BusinessChallenge, choice: BusinessChoice) {
        var progress = stats.progress(for: .business)
        if !progress.completedChallengeIds.contains(challenge.id) {
            progress.completedChallengeIds.append(challenge.id)
            let xpEarned = choice.isCorrect ? 25 : 10
            progress.totalHistoryXP += xpEarned
            stats.xp += xpEarned
            stats.gems += choice.isCorrect ? 2 : 0
            stats.reviewedToday += 1
            if choice.isCorrect { stats.correctToday += 1 }
            progress.worldScores[challenge.worldId, default: 0] += xpEarned
            feedPet(correctCount: choice.isCorrect ? 2 : 1)
        }
        stats.updateProgress(for: .business, progress)
        refreshPracticeDay()
        save()
    }
    
    var currentWorld: PlayableWorld? {
        guard let worldId = stats.progress(for: stats.selectedSubject).currentWorldId else { return nil }
        return stats.selectedSubject.worlds.first { $0.id == worldId }
    }
    
    var nextHistoryChallenge: HistoryChallenge? {
        let progress = stats.progress(for: .history)
        guard let worldId = progress.currentWorldId else { return nil }
        let challenges = HistoryData.challenges(for: worldId)
        return challenges.first { !progress.completedChallengeIds.contains($0.id) }
    }
    
    var nextScienceChallenge: ScienceChallenge? {
        let progress = stats.progress(for: .science)
        guard let worldId = progress.currentWorldId else { return nil }
        let challenges = ScienceData.challenges(for: worldId)
        return challenges.first { !progress.completedChallengeIds.contains($0.id) }
    }

    var nextGeographyChallenge: GeographyChallenge? {
        let progress = stats.progress(for: .geography)
        guard let worldId = progress.currentWorldId else { return nil }
        let challenges = GeographyData.challenges(for: worldId)
        return challenges.first { !progress.completedChallengeIds.contains($0.id) }
    }

    var nextMathChallenge: MathChallenge? {
        let progress = stats.progress(for: .math)
        guard let worldId = progress.currentWorldId else { return nil }
        let challenges = MathData.challenges(for: worldId)
        return challenges.first { !progress.completedChallengeIds.contains($0.id) }
    }

    var nextCultureChallenge: CultureChallenge? {
        let progress = stats.progress(for: .culture)
        guard let worldId = progress.currentWorldId else { return nil }
        let challenges = CultureData.challenges(for: worldId)
        return challenges.first { !progress.completedChallengeIds.contains($0.id) }
    }

    var nextBusinessChallenge: BusinessChallenge? {
        let progress = stats.progress(for: .business)
        guard let worldId = progress.currentWorldId else { return nil }
        let challenges = BusinessData.challenges(for: worldId)
        return challenges.first { !progress.completedChallengeIds.contains($0.id) }
    }
    
    var historyProgressPercent: Double {
        let progress = stats.progress(for: .history)
        guard let worldId = progress.currentWorldId else { return 0 }
        let total = HistoryData.challenges(for: worldId).count
        guard total > 0 else { return 0 }
        return Double(progress.completedChallengeIds.filter { id in
            HistoryData.challenges(for: worldId).contains { $0.id == id }
        }.count) / Double(total)
    }
    
    var scienceProgressPercent: Double {
        let progress = stats.progress(for: .science)
        guard let worldId = progress.currentWorldId else { return 0 }
        let total = ScienceData.challenges(for: worldId).count
        guard total > 0 else { return 0 }
        return Double(progress.completedChallengeIds.filter { id in
            ScienceData.challenges(for: worldId).contains { $0.id == id }
        }.count) / Double(total)
    }

    var geographyProgressPercent: Double {
        let progress = stats.progress(for: .geography)
        guard let worldId = progress.currentWorldId else { return 0 }
        let total = GeographyData.challenges(for: worldId).count
        guard total > 0 else { return 0 }
        return Double(progress.completedChallengeIds.filter { id in
            GeographyData.challenges(for: worldId).contains { $0.id == id }
        }.count) / Double(total)
    }

    var mathProgressPercent: Double {
        let progress = stats.progress(for: .math)
        guard let worldId = progress.currentWorldId else { return 0 }
        let total = MathData.challenges(for: worldId).count
        guard total > 0 else { return 0 }
        return Double(progress.completedChallengeIds.filter { id in
            MathData.challenges(for: worldId).contains { $0.id == id }
        }.count) / Double(total)
    }

    var cultureProgressPercent: Double {
        let progress = stats.progress(for: .culture)
        guard let worldId = progress.currentWorldId else { return 0 }
        let total = CultureData.challenges(for: worldId).count
        guard total > 0 else { return 0 }
        return Double(progress.completedChallengeIds.filter { id in
            CultureData.challenges(for: worldId).contains { $0.id == id }
        }.count) / Double(total)
    }

    var businessProgressPercent: Double {
        let progress = stats.progress(for: .business)
        guard let worldId = progress.currentWorldId else { return 0 }
        let total = BusinessData.challenges(for: worldId).count
        guard total > 0 else { return 0 }
        return Double(progress.completedChallengeIds.filter { id in
            BusinessData.challenges(for: worldId).contains { $0.id == id }
        }.count) / Double(total)
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
