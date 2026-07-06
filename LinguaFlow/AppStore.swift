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
    @Published var newlyUnlockedWorld: WorldRewardBadge? = nil
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
    var streakChest: StreakChest {
        let quest = dailyQuest
        let claimedToday = stats.lastStreakChestClaimDate.map { Calendar.current.isDateInToday($0) } ?? false
        let streakBonus = min(30, max(0, stats.streak - 1) * 3)
        let gemBonus = min(4, max(0, stats.streak / 3))
        return StreakChest(
            subject: stats.selectedSubject,
            streak: stats.streak,
            progress: quest.progress,
            rewardXP: 20 + streakBonus,
            rewardGems: 2 + gemBonus,
            isReady: quest.progress >= 1,
            isClaimedToday: claimedToday
        )
    }
    var dailyAdventure: DailyAdventure {
        let world: PlayableWorld?
        if stats.selectedSubject == .languages {
            world = nil
        } else {
            let currentWorldId = stats.subjectProgress[stats.selectedSubject.rawValue]?.currentWorldId
            world = stats.selectedSubject.worlds.first { $0.id == currentWorldId } ?? stats.selectedSubject.worlds.first
        }
        return DailyAdventure(subject: stats.selectedSubject, world: world, xp: stats.xp, streak: stats.streak)
    }
    var recommendedRun: RecommendedRun {
        let chest = streakChest
        if chest.isReady && !chest.isClaimedToday {
            return RecommendedRun(
                action: .claimStreakChest,
                title: "Open your streak chest",
                subtitle: "Daily Quest complete. Bank the reward before the next run.",
                reward: chest.rewardText,
                ctaTitle: "Open Chest",
                systemImage: "shippingbox.fill",
                subject: chest.subject,
                worldId: nil,
                progress: 1
            )
        }

        let quest = dailyQuest
        if quest.progress < 1 {
            let adventure = dailyAdventure
            return RecommendedRun(
                action: .dailyAdventure,
                title: adventure.title,
                subtitle: adventure.objective,
                reward: adventure.rewardLine,
                ctaTitle: "Start Run",
                systemImage: "play.circle.fill",
                subject: adventure.subject,
                worldId: adventure.world?.id,
                progress: quest.progress
            )
        }

        if let unlock = stats.nextWorldUnlockBadge {
            return RecommendedRun(
                action: .nextUnlock,
                title: "Chase \(unlock.world.name)",
                subtitle: "\(unlock.xpRemaining) XP left in \(unlock.subject.displayName). Focus the nearest locked world.",
                reward: unlock.world.rewardName,
                ctaTitle: "Focus Unlock",
                systemImage: "lock.open.fill",
                subject: unlock.subject,
                worldId: unlock.world.id,
                progress: unlock.world.unlockProgress(withXP: stats.xp)
            )
        }

        return RecommendedRun(
            action: .roulette,
            title: "Spin Quest Roulette",
            subtitle: "All current worlds are open. Jump somewhere unexpected.",
            reward: "+30 XP · Surprise run",
            ctaTitle: "Spin",
            systemImage: "shuffle.circle.fill",
            subject: stats.selectedSubject,
            worldId: nil,
            progress: 1
        )
    }
    var questBoardMissions: [QuestBoardMission] {
        let subject = stats.selectedSubject
        let adventure = dailyAdventure
        var missions: [QuestBoardMission] = [
            QuestBoardMission(
                id: "daily-adventure",
                kind: .dailyAdventure,
                title: adventure.title,
                subtitle: adventure.objective,
                reward: adventure.rewardLine,
                systemImage: "play.circle.fill",
                subject: subject,
                worldId: adventure.world?.id,
                progress: dailyQuest.progress
            )
        ]

        if subject == .languages {
            let totalCards = max(availableCards.count, 1)
            let reviewProgress = min(1, Double(max(learnedCount, masteredCount)) / Double(totalCards))
            missions.append(
                QuestBoardMission(
                    id: "language-review",
                    kind: .languageReview,
                    title: dueCount > 0 ? "Clear \(dueCount) due cards" : "Scout the next phrase",
                    subtitle: "\(stats.selectedLanguagePair.displayName) · \(masteredCount)/\(totalCards) mastered",
                    reward: "+16 XP · Fluency Drop",
                    systemImage: "textformat.abc",
                    subject: .languages,
                    worldId: nil,
                    progress: reviewProgress
                )
            )
        } else if let world = dailyAdventure.world {
            let progress = stats.progress(for: subject)
            let challengeIds = subject.challengeIds(for: world.id)
            let completed = progress.completedChallengeIds.filter { challengeIds.contains($0) }.count
            let total = max(challengeIds.count, 1)
            let remaining = max(0, total - completed)
            missions.append(
                QuestBoardMission(
                    id: "active-world-\(world.id)",
                    kind: .activeWorld,
                    title: "Finish \(world.name)",
                    subtitle: remaining == 0 ? "World cleared. Pick the next route." : "\(remaining) missions left in \(world.era)",
                    reward: "+25 XP · \(dailyQuest.rewardName)",
                    systemImage: subject.mapSystemImage,
                    subject: subject,
                    worldId: world.id,
                    progress: min(1, Double(completed) / Double(total))
                )
            )
        }

        if let unlock = stats.nextWorldUnlockBadge {
            missions.append(
                QuestBoardMission(
                    id: "next-unlock-\(unlock.id)",
                    kind: .nextUnlock,
                    title: "Unlock \(unlock.world.name)",
                    subtitle: "\(unlock.xpRemaining) XP left · \(unlock.subject.displayName)",
                    reward: unlock.world.rewardName,
                    systemImage: "lock.open.fill",
                    subject: unlock.subject,
                    worldId: unlock.world.id,
                    progress: unlock.world.unlockProgress(withXP: stats.xp)
                )
            )
        } else {
            missions.append(
                QuestBoardMission(
                    id: "roulette",
                    kind: .roulette,
                    title: "Spin Quest Roulette",
                    subtitle: "All current worlds are open. Jump somewhere unexpected.",
                    reward: "+30 XP · Surprise run",
                    systemImage: "shuffle.circle.fill",
                    subject: subject,
                    worldId: nil,
                    progress: 1
                )
            )
        }

        return Array(missions.prefix(3))
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
            if arguments.contains("--ui-testing-health-world") {
                stats.selectedSubject = .health
                var progress = stats.progress(for: .health)
                progress.currentWorldId = "energy-clinic"
                progress.completedChallengeIds = []
                stats.updateProgress(for: .health, progress)
            }
            if arguments.contains("--ui-testing-health-near-unlock") {
                stats.selectedSubject = .health
                stats.xp = 490
                var progress = stats.progress(for: .health)
                progress.currentWorldId = "energy-clinic"
                progress.completedChallengeIds = []
                stats.updateProgress(for: .health, progress)
            }
            if arguments.contains("--ui-testing-chest-ready") {
                stats.reviewedToday = max(stats.reviewedToday, min(10, max(4, stats.dailyGoal / 2)))
                stats.correctToday = stats.reviewedToday
                stats.streak = max(stats.streak, 3)
                stats.lastStreakChestClaimDate = nil
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

    func startRandomStudy() {
        let options = Subject.allCases
            .filter { $0 != .languages }
            .flatMap { subject in
                subject.worlds
                    .filter { $0.isUnlocked(withXP: stats.xp) }
                    .map { (subject: subject, world: $0) }
            }

        guard let pick = options.randomElement() else {
            select(subject: .languages)
            feedbackMessage = "Roulette picked Languages. Build XP to unlock more worlds."
            return
        }

        stats.selectedSubject = pick.subject
        var progress = stats.progress(for: pick.subject)
        progress.currentWorldId = pick.world.id
        stats.updateProgress(for: pick.subject, progress)
        feedbackMessage = "Roulette picked \(pick.world.name) in \(pick.subject.displayName)."
        save()
        objectWillChange.send()
    }

    func startRecommendedRun(_ recommendation: RecommendedRun) {
        switch recommendation.action {
        case .dailyAdventure:
            if recommendation.subject == .languages {
                stats.selectedSubject = .languages
                pickNextCard()
                feedbackMessage = "Recommended run opened today's language adventure."
            } else if let worldId = recommendation.worldId {
                stats.selectedSubject = recommendation.subject
                select(worldId: worldId, for: recommendation.subject)
                feedbackMessage = "Recommended run opened \(recommendation.title)."
            }
        case .claimStreakChest:
            _ = claimStreakChest()
            return
        case .nextUnlock:
            stats.selectedSubject = recommendation.subject
            if let playableWorld = recommendation.subject.worlds.first(where: { $0.isUnlocked(withXP: stats.xp) }) {
                select(worldId: playableWorld.id, for: recommendation.subject)
            }
            feedbackMessage = "Recommended run focused \(recommendation.title)."
        case .roulette:
            startRandomStudy()
            return
        }
        save()
        objectWillChange.send()
    }

    func startQuestBoardMission(_ mission: QuestBoardMission) {
        switch mission.kind {
        case .dailyAdventure:
            if mission.subject == .languages {
                stats.selectedSubject = .languages
                pickNextCard()
                feedbackMessage = "Quest Board opened today's language run."
            } else if let worldId = mission.worldId {
                stats.selectedSubject = mission.subject
                select(worldId: worldId, for: mission.subject)
                feedbackMessage = "Quest Board opened \(mission.title)."
            }
        case .languageReview:
            stats.selectedSubject = .languages
            pickNextCard()
            feedbackMessage = "Quest Board opened the review gate."
        case .activeWorld:
            stats.selectedSubject = mission.subject
            if let worldId = mission.worldId {
                select(worldId: worldId, for: mission.subject)
            }
            feedbackMessage = "Quest Board focused \(mission.title)."
        case .nextUnlock:
            stats.selectedSubject = mission.subject
            if let playableWorld = mission.subject.worlds.first(where: { $0.isUnlocked(withXP: stats.xp) }) {
                select(worldId: playableWorld.id, for: mission.subject)
            }
            feedbackMessage = "Quest Board target set: \(mission.title)."
        case .roulette:
            startRandomStudy()
            return
        }
        save()
        objectWillChange.send()
    }

    @discardableResult
    func claimStreakChest(now: Date = Date()) -> Bool {
        let chest = streakChest
        guard chest.isReady, !chest.isClaimedToday else {
            feedbackMessage = chest.isClaimedToday ? "Today's chest is already claimed." : "Finish the Daily Quest to open the chest."
            return false
        }

        let previouslyLocked = Set(stats.worldRewardBadges.filter { !$0.isEarned }.map(\.id))
        stats.xp += chest.rewardXP
        stats.gems += chest.rewardGems
        stats.lastStreakChestClaimDate = now

        let newlyEarned = stats.worldRewardBadges.filter { $0.isEarned && previouslyLocked.contains($0.id) }
        if let unlocked = newlyEarned.first {
            newlyUnlockedWorld = unlocked
            feedbackMessage = "Chest opened: \(chest.rewardText). \(unlocked.world.name) unlocked."
        } else {
            feedbackMessage = "Chest opened: \(chest.rewardText)."
        }
        save()
        objectWillChange.send()
        return true
    }
    
    func select(worldId: String, for subject: Subject) {
        var progress = stats.progress(for: subject)
        progress.currentWorldId = worldId
        stats.updateProgress(for: subject, progress)
        save()
    }
    
    func submitHistoryAnswer(challenge: HistoryChallenge, choice: HistoryChoice) {
        completeSubjectChallenge(subject: .history, challengeId: challenge.id, worldId: challenge.worldId, isCorrect: choice.isCorrect)
    }
    
    func submitScienceAnswer(challenge: ScienceChallenge, choice: ScienceChoice) {
        completeSubjectChallenge(subject: .science, challengeId: challenge.id, worldId: challenge.worldId, isCorrect: choice.isCorrect)
    }

    func submitGeographyAnswer(challenge: GeographyChallenge, choice: GeographyChoice) {
        completeSubjectChallenge(subject: .geography, challengeId: challenge.id, worldId: challenge.worldId, isCorrect: choice.isCorrect)
    }

    func submitMathAnswer(challenge: MathChallenge, choice: MathChoice) {
        completeSubjectChallenge(subject: .math, challengeId: challenge.id, worldId: challenge.worldId, isCorrect: choice.isCorrect)
    }

    func submitCultureAnswer(challenge: CultureChallenge, choice: CultureChoice) {
        completeSubjectChallenge(subject: .culture, challengeId: challenge.id, worldId: challenge.worldId, isCorrect: choice.isCorrect)
    }

    func submitBusinessAnswer(challenge: BusinessChallenge, choice: BusinessChoice) {
        completeSubjectChallenge(subject: .business, challengeId: challenge.id, worldId: challenge.worldId, isCorrect: choice.isCorrect)
    }

    func submitHealthAnswer(challenge: HealthChallenge, choice: HealthChoice) {
        completeSubjectChallenge(subject: .health, challengeId: challenge.id, worldId: challenge.worldId, isCorrect: choice.isCorrect)
    }

    private func completeSubjectChallenge(subject: Subject, challengeId: String, worldId: String, isCorrect: Bool) {
        let previouslyLocked = Set(stats.worldRewardBadges.filter { !$0.isEarned }.map(\.id))
        var progress = stats.progress(for: subject)
        if !progress.completedChallengeIds.contains(challengeId) {
            progress.completedChallengeIds.append(challengeId)
            let xpEarned = isCorrect ? 25 : 10
            progress.totalHistoryXP += xpEarned
            stats.xp += xpEarned
            stats.gems += isCorrect ? 2 : 0
            stats.reviewedToday += 1
            if isCorrect { stats.correctToday += 1 }
            progress.worldScores[worldId, default: 0] += xpEarned
            stats.updateProgress(for: subject, progress)
            let newlyEarned = stats.worldRewardBadges.filter { $0.isEarned && previouslyLocked.contains($0.id) }
            if let unlocked = newlyEarned.first(where: { $0.subject == subject }) ?? newlyEarned.first {
                newlyUnlockedWorld = unlocked
                feedbackMessage = "Reward unlocked: \(unlocked.world.name) opened."
                objectWillChange.send()
            }
            feedPet(correctCount: isCorrect ? 2 : 1)
        } else {
            stats.updateProgress(for: subject, progress)
        }
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

    var nextHealthChallenge: HealthChallenge? {
        let progress = stats.progress(for: .health)
        guard let worldId = progress.currentWorldId else { return nil }
        let challenges = HealthData.challenges(for: worldId)
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

    var healthProgressPercent: Double {
        let progress = stats.progress(for: .health)
        guard let worldId = progress.currentWorldId else { return 0 }
        let total = HealthData.challenges(for: worldId).count
        guard total > 0 else { return 0 }
        return Double(progress.completedChallengeIds.filter { id in
            HealthData.challenges(for: worldId).contains { $0.id == id }
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
