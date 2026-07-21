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

    func testDailyComboShowsNextRewardAndCompletedChain() {
        let earlyCombo = DailyCombo(subject: .science, correctToday: 2, target: 3)
        XCTAssertEqual(earlyCombo.title, "Build a Focus Combo")
        XCTAssertEqual(earlyCombo.subtitle, "1 correct move to trigger the next reward.")
        XCTAssertEqual(earlyCombo.rewardText, "+5 XP · +1 gem")
        XCTAssertEqual(earlyCombo.progressText, "2/3 chain")
        XCTAssertEqual(earlyCombo.progress, 2.0 / 3.0, accuracy: 0.001)

        let completedCombo = DailyCombo(subject: .history, correctToday: 6, target: 3)
        XCTAssertEqual(completedCombo.title, "Focus Combo x2")
        XCTAssertEqual(completedCombo.subtitle, "Combo banked. Start the next chain for another bonus.")
        XCTAssertEqual(completedCombo.progressText, "3/3 chain")
        XCTAssertEqual(completedCombo.progress, 1.0, accuracy: 0.001)
    }

    func testDailyBossChargesAndDefeatsOncePerDay() async {
        await MainActor.run {
            var charging = DailyBoss(subject: .math, correctToday: 4, target: 5, isDefeatedToday: false)
            XCTAssertEqual(charging.title, "Pattern Hydra Appears")
            XCTAssertFalse(charging.isReady)
            XCTAssertEqual(charging.progressText, "4/5 charge")
            XCTAssertEqual(charging.subtitle, "1 correct move to charge the boss encounter.")

            charging = DailyBoss(subject: .math, correctToday: 5, target: 5, isDefeatedToday: false)
            XCTAssertTrue(charging.isReady)
            XCTAssertEqual(charging.subtitle, "Your combo chain is charged. Finish the boss for a bigger prize.")

            let store = AppStore()
            store.stats.selectedSubject = .math
            store.stats.correctToday = 5
            store.stats.xp = 365
            store.stats.gems = 1

            XCTAssertTrue(store.defeatDailyBoss(now: Date()))
            XCTAssertEqual(store.stats.xp, 400)
            XCTAssertEqual(store.stats.gems, 4)
            XCTAssertTrue(store.dailyBoss.isDefeatedToday)
            XCTAssertTrue(store.feedbackMessage.contains("Boss defeated"))

            XCTAssertFalse(store.defeatDailyBoss(now: Date()))
            XCTAssertEqual(store.stats.xp, 400)
            XCTAssertEqual(store.stats.gems, 4)
        }
    }

    func testDailyRelicRevealsCollectibleOncePerDay() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .history
            store.stats.correctToday = 3
            store.stats.xp = 100
            store.stats.gems = 1

            let relicDrop = store.dailyRelic
            XCTAssertTrue(relicDrop.isReady)
            XCTAssertEqual(relicDrop.relic.subject, .history)
            XCTAssertFalse(store.stats.collectedRelicSet.contains(relicDrop.relic.id))

            XCTAssertTrue(store.claimDailyRelic(now: Date()))
            XCTAssertEqual(store.stats.xp, 118)
            XCTAssertEqual(store.stats.gems, 3)
            XCTAssertTrue(store.stats.collectedRelicSet.contains(relicDrop.relic.id))
            XCTAssertEqual(store.stats.collectedRelicCount, 1)
            XCTAssertTrue(store.feedbackMessage.contains("Relic secured"))

            XCTAssertFalse(store.claimDailyRelic(now: Date()))
            XCTAssertEqual(store.stats.xp, 118)
            XCTAssertEqual(store.stats.gems, 3)
        }
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

    func testWorldUnlockProgressAndRewards() {
        let locked = Subject.health.nextLockedWorld(withXP: 125)
        XCTAssertEqual(locked?.id, "resilience-gym")
        XCTAssertEqual(locked?.rewardName, "Resilience Gym Badge")
        XCTAssertEqual(locked?.xpRemaining(withXP: 125), 375)
        XCTAssertEqual(locked?.unlockProgress(withXP: 125) ?? 0, 0.25, accuracy: 0.001)
        XCTAssertEqual(Subject.health.unlockedWorldCount(withXP: 125), 1)

        XCTAssertNil(Subject.health.nextLockedWorld(withXP: 500))
        XCTAssertEqual(Subject.health.unlockedWorldCount(withXP: 500), 2)
    }

    func testLearningLevelTrackAndNextUnlock() {
        var stats = UserStats()
        stats.xp = 275
        stats.streak = 4

        XCTAssertEqual(stats.learningLevel, 3)
        XCTAssertEqual(stats.levelTitle, "World Walker")
        XCTAssertEqual(stats.xpIntoCurrentLevel, 75)
        XCTAssertEqual(stats.xpNeededForNextLevel, 25)
        XCTAssertEqual(stats.levelProgress, 0.75, accuracy: 0.001)
        XCTAssertEqual(stats.streakBoostText, "4-day streak · +8% momentum")
        XCTAssertEqual(stats.nextWorldUnlockBadge?.world.name, "African Wonders")
        XCTAssertEqual(stats.nextWorldUnlockBadge?.xpRemaining, 25)
    }

    func testWorldAtlasSummarizesAllLearningDomainsAndNextUnlock() {
        var stats = UserStats()
        stats.xp = 275
        stats.reviewedToday = 6
        stats.dailyGoal = 12
        var history = stats.progress(for: .history)
        history.currentWorldId = "ancient-rome"
        history.completedChallengeIds = ["rome-01", "rome-02"]
        stats.updateProgress(for: .history, history)

        let atlas = stats.atlasSubjectProgress

        XCTAssertEqual(atlas.count, Subject.allCases.count)
        XCTAssertEqual(stats.atlasOpenWorldCount, 8)
        XCTAssertEqual(stats.atlasTotalWorldCount, 16)
        XCTAssertEqual(stats.atlasProgress, 8.0 / 16.0, accuracy: 0.001)
        XCTAssertEqual(atlas.first { $0.subject == .history }?.missionText, "2/5 missions")
        XCTAssertEqual(stats.atlasNextTarget?.subject, .geography)
        XCTAssertEqual(stats.atlasNextTarget?.nextWorld?.name, "African Wonders")
        XCTAssertEqual(stats.atlasNextTarget?.nextText, "25 XP to African Wonders")
    }

    func testWorldAtlasFocusJumpsToNearestUnlockSubject() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .math
            store.stats.xp = 275

            store.focusAtlasNextWorld()

            XCTAssertEqual(store.stats.selectedSubject, .geography)
            XCTAssertEqual(store.currentWorld?.id, "european-capitals")
            XCTAssertTrue(store.feedbackMessage.contains("Atlas focused African Wonders"))
        }
    }

    func testCampaignSpotlightShowsNextGroundedHistoryEncounter() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .history
            store.stats.xp = 125
            var progress = store.stats.progress(for: .history)
            progress.currentWorldId = "ancient-rome"
            progress.completedChallengeIds = ["rome-01", "rome-02"]
            store.stats.updateProgress(for: .history, progress)

            let spotlight = store.campaignSpotlight

            XCTAssertEqual(spotlight.title, "Ancient Rome Campaign")
            XCTAssertEqual(spotlight.encounter.title, "Crisis · 476 CE")
            XCTAssertTrue(spotlight.encounter.context.contains("Odoacer"))
            XCTAssertEqual(spotlight.progressText, "2/5 encounters cleared")
            XCTAssertEqual(spotlight.rewardText, "+25 XP · Chronicle Page")
            XCTAssertFalse(spotlight.isComplete)
        }
    }

    func testWorldJournalFramesCurrentHistoryWorldAsExpedition() {
        var stats = UserStats()
        stats.selectedSubject = .history
        stats.xp = 125
        stats.streak = 2
        var history = stats.progress(for: .history)
        history.currentWorldId = "ancient-rome"
        history.completedChallengeIds = ["rome-01", "rome-02"]
        stats.updateProgress(for: .history, history)

        let journal = stats.worldJournal

        XCTAssertEqual(journal.title, "Ancient Rome Journal")
        XCTAssertEqual(journal.eyebrow, "History Map Expedition")
        XCTAssertEqual(journal.sceneTitle, "Forum at a Turning Point")
        XCTAssertTrue(journal.sceneText.contains("grounded choices"))
        XCTAssertEqual(journal.objective, "Complete 3 more missions to close this world chapter.")
        XCTAssertTrue(journal.choiceText.contains("actually happened"))
        XCTAssertEqual(journal.progressText, "2/5 missions")
        XCTAssertEqual(journal.progress, 0.4, accuracy: 0.001)
        XCTAssertEqual(journal.rewardText, "+30 XP · Chronicle Page")
        XCTAssertEqual(journal.nextUnlockText, "375 XP to unlock Medieval Europe.")
    }

    func testWorldJournalLanguageRouteUsesDailyPromptProgressAndNextUnlock() {
        var stats = UserStats()
        stats.selectedSubject = .languages
        stats.dailyGoal = 12
        stats.reviewedToday = 5
        stats.xp = 275

        let journal = stats.worldJournal

        XCTAssertEqual(journal.title, "Language Harbor Journal")
        XCTAssertEqual(journal.eyebrow, "Playable Lesson")
        XCTAssertEqual(journal.sceneTitle, "Harbor Gate")
        XCTAssertEqual(journal.objective, "Clear 7 more mixed prompts to fill today's fluency drop.")
        XCTAssertEqual(journal.choiceText, "Speak first, then type from memory.")
        XCTAssertEqual(journal.progressText, "5/12 prompts")
        XCTAssertEqual(journal.progress, 5.0 / 12.0, accuracy: 0.001)
        XCTAssertEqual(journal.nextUnlockText, "25 XP to African Wonders.")
    }

    func testPlayMenuBuildsSprintExpeditionAndBossModes() {
        var stats = UserStats()
        stats.selectedSubject = .history
        stats.xp = 125
        stats.correctToday = 4
        var history = stats.progress(for: .history)
        history.currentWorldId = "ancient-rome"
        history.completedChallengeIds = ["rome-01", "rome-02"]
        stats.updateProgress(for: .history, history)

        let menu = stats.playMenu

        XCTAssertEqual(menu.title, "Choose Your Run")
        XCTAssertEqual(menu.modes.map(\.kind), [.sprint, .expedition, .boss])
        XCTAssertEqual(menu.modes[0].title, "🏛️ History Sprint")
        XCTAssertEqual(menu.modes[0].worldId, "ancient-rome")
        XCTAssertEqual(menu.modes[1].title, "Ancient Rome Journal")
        XCTAssertEqual(menu.modes[1].progress, 0.4, accuracy: 0.001)
        XCTAssertEqual(menu.modes[2].title, "Timeline Warden Appears")
        XCTAssertEqual(menu.modes[2].ctaTitle, "Charge")
        XCTAssertEqual(menu.modes[2].progress, 0.8, accuracy: 0.001)
    }

    func testPlayMenuModeRoutesSprintAndReadyBoss() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .health
            store.stats.correctToday = 5
            store.stats.xp = 100
            store.stats.gems = 0
            var progress = store.stats.progress(for: .health)
            progress.currentWorldId = "energy-clinic"
            store.stats.updateProgress(for: .health, progress)

            let sprint = store.stats.playMenu.modes.first { $0.kind == .sprint }!
            store.startPlayMenuMode(sprint)

            XCTAssertEqual(store.stats.selectedSubject, .health)
            XCTAssertEqual(store.currentWorld?.id, "energy-clinic")
            XCTAssertTrue(store.feedbackMessage.contains("Sprint opened"))

            let boss = store.stats.playMenu.modes.first { $0.kind == .boss }!
            store.startPlayMenuMode(boss)

            XCTAssertEqual(store.stats.xp, 135)
            XCTAssertEqual(store.stats.gems, 3)
            XCTAssertTrue(store.dailyBoss.isDefeatedToday)
            XCTAssertTrue(store.feedbackMessage.contains("Boss defeated"))
        }
    }

    func testQuestEnergyTracksGateProgressAndSpendState() {
        var stats = UserStats()
        stats.selectedSubject = .history
        stats.xp = 275
        stats.gems = 4
        stats.streak = 3
        stats.reviewedToday = 2
        stats.correctToday = 2

        let energy = stats.questEnergy

        XCTAssertEqual(energy.title, "Quest Energy")
        XCTAssertEqual(energy.progressText, "61% charged")
        XCTAssertEqual(energy.gateText, "25 XP to African Wonders")
        XCTAssertEqual(energy.rewardText, "+26 XP · -3 gems")
        XCTAssertTrue(energy.canSpend)
        XCTAssertEqual(energy.ctaTitle, "Boost Gate")
    }

    func testQuestEnergyBoostSpendsGemsAndCanUnlockWorld() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .geography
            store.stats.xp = 280
            store.stats.gems = 3
            store.stats.streak = 3

            XCTAssertTrue(store.spendQuestEnergyBoost())
            XCTAssertEqual(store.stats.gems, 0)
            XCTAssertEqual(store.stats.xp, 306)
            XCTAssertEqual(store.newlyUnlockedWorld?.world.name, "African Wonders")
            XCTAssertTrue(store.feedbackMessage.contains("Quest Energy boosted +26 XP"))
            XCTAssertTrue(store.feedbackMessage.contains("African Wonders unlocked"))
        }
    }

    func testStartWorldJournalRoutesToCurrentWorld() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .business
            store.stats.xp = 0
            var progress = store.stats.progress(for: .business)
            progress.currentWorldId = "founder-guild"
            store.stats.updateProgress(for: .business, progress)

            store.startWorldJournal()

            XCTAssertEqual(store.stats.selectedSubject, .business)
            XCTAssertEqual(store.currentWorld?.id, "founder-guild")
            XCTAssertTrue(store.feedbackMessage.contains("World Journal opened"))
            XCTAssertTrue(store.feedbackMessage.contains("Founder Guild Journal"))
        }
    }

    func testContinueCampaignSpotlightRoutesToCurrentWorld() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .health
            store.stats.xp = 150
            var progress = store.stats.progress(for: .health)
            progress.currentWorldId = "energy-clinic"
            store.stats.updateProgress(for: .health, progress)

            store.continueCampaignSpotlight()

            XCTAssertEqual(store.stats.selectedSubject, .health)
            XCTAssertEqual(store.currentWorld?.id, "energy-clinic")
            XCTAssertTrue(store.feedbackMessage.contains("Campaign continued"))
        }
    }

    func testMasteryLeagueRanksDomainsAndSuggestsCatchUp() async {
        await MainActor.run {
            var stats = UserStats()
            stats.selectedSubject = .history
            stats.xp = 500
            stats.streak = 0
            stats.reviewedToday = 0
            var history = stats.progress(for: .history)
            history.currentWorldId = "ancient-rome"
            history.completedChallengeIds = ["rome-01", "rome-02"]
            history.worldScores = ["ancient-rome": 50]
            stats.updateProgress(for: .history, history)
            stats.collectedRelicIds = ["history-bronze-denarius"]

            let league = stats.masteryLeague

            XCTAssertEqual(league.standings.count, Subject.allCases.count)
            XCTAssertEqual(league.standings.first?.subject, .history)
            XCTAssertEqual(league.selectedStanding?.rank, 1)
            XCTAssertEqual(league.selectedStanding?.detailText, "2/5 missions · 2/3 worlds")
            XCTAssertEqual(league.catchUpTarget?.subject, .languages)
            XCTAssertTrue(league.catchUpTitle.contains("Languages"))
            XCTAssertEqual(league.topThree.count, 3)
        }
    }

    func testMasteryLeagueCatchUpStartsTargetSubject() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .languages
            store.stats.xp = 0

            store.startMasteryLeagueCatchUp()

            XCTAssertEqual(store.stats.selectedSubject, .business)
            XCTAssertEqual(store.currentWorld?.id, "founder-guild")
            XCTAssertTrue(store.feedbackMessage.contains("Mastery League boosted"))
        }
    }

    func testLearningPassportTracksDomainStampsAndNextTarget() {
        var stats = UserStats()
        stats.selectedSubject = .history
        stats.totalReviews = 3
        var history = stats.progress(for: .history)
        history.currentWorldId = "ancient-rome"
        history.completedChallengeIds = ["rome-01"]
        history.worldScores = ["ancient-rome": 25]
        stats.updateProgress(for: .history, history)

        let passport = stats.learningPassport

        XCTAssertEqual(passport.stamps.count, Subject.allCases.count)
        XCTAssertEqual(passport.earnedCount, 2)
        XCTAssertEqual(passport.progressText, "2/8 stamps")
        XCTAssertTrue(passport.stamps.first { $0.subject == .languages }?.isEarned ?? false)
        XCTAssertTrue(passport.stamps.first { $0.subject == .history }?.subtitle.contains("1 mission") ?? false)
        XCTAssertEqual(passport.nextStamp?.subject, .science)
        XCTAssertEqual(passport.ctaTitle, "Stamp 🔬 Science")
    }

    func testLearningPassportButtonStartsNextUnstampedDomain() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .history
            store.stats.xp = 0
            var history = store.stats.progress(for: .history)
            history.completedChallengeIds = ["rome-01"]
            store.stats.updateProgress(for: .history, history)

            store.startPassportNextStamp()

            XCTAssertEqual(store.stats.selectedSubject, .languages)
            XCTAssertTrue(store.feedbackMessage.contains("Passport opened Languages"))
        }
    }

    func testKnowledgeCodexCollectsCompletedMissionLessons() {
        var stats = UserStats()
        stats.selectedSubject = .history
        stats.totalReviews = 1
        var history = stats.progress(for: .history)
        history.currentWorldId = "ancient-rome"
        history.completedChallengeIds = ["rome-01", "rome-02"]
        stats.updateProgress(for: .history, history)

        let codex = stats.knowledgeCodex

        XCTAssertEqual(codex.title, "Knowledge Codex")
        XCTAssertGreaterThan(codex.totalCount, 20)
        XCTAssertEqual(codex.unlockedCount, 3)
        XCTAssertEqual(codex.progressText, "3/\(codex.totalCount) lessons")
        XCTAssertTrue(codex.entries.contains { $0.id == "rome-01" && $0.isUnlocked && $0.body.contains("Rubicon") })
        XCTAssertTrue(codex.entries.contains { $0.id == "languages-review-gate" && $0.isUnlocked })
        XCTAssertTrue(codex.featuredEntries.contains { $0.id == "rome-01" || $0.id == "rome-02" })
    }

    func testQuestRouletteIncludesLanguageAndUnlockedWorldRoutes() {
        var stats = UserStats()
        stats.xp = 0
        stats.reviewedToday = 2

        let roulette = stats.questRoulette

        XCTAssertEqual(roulette.title, "Quest Roulette")
        XCTAssertTrue(roulette.options.contains { $0.id == "languages-harbor" })
        XCTAssertTrue(roulette.options.contains { $0.id == "history-ancient-rome" })
        XCTAssertTrue(roulette.options.contains { $0.id == "business-founder-guild" })
        XCTAssertFalse(roulette.options.contains { $0.id == "history-medieval-europe" })
        XCTAssertEqual(roulette.featuredOptions.count, 4)
        XCTAssertEqual(roulette.progressText, "\(roulette.options.count) live routes")
        XCTAssertEqual(roulette.rewardText, "+30 XP · +2 gems · Surprise stamp")
    }

    func testQuestRouletteCanStartSpecificWorldOption() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.xp = 0
            let founderGuild = store.stats.questRoulette.options.first { $0.id == "business-founder-guild" }
            XCTAssertNotNil(founderGuild)

            store.startRandomStudy(option: founderGuild)

            XCTAssertEqual(store.stats.selectedSubject, .business)
            XCTAssertEqual(store.currentWorld?.id, "founder-guild")
            XCTAssertTrue(store.feedbackMessage.contains("Roulette picked Founder Guild"))
        }
    }

    func testRewardVaultSummarizesEarnedAndNextLockedWorldBadges() {
        var stats = UserStats()
        stats.xp = 0

        XCTAssertEqual(stats.totalWorldRewardCount, 15)
        XCTAssertEqual(stats.earnedWorldRewardCount, 7)
        XCTAssertEqual(stats.worldRewardProgress, 7.0 / 15.0, accuracy: 0.001)
        XCTAssertTrue(stats.worldRewardBadges.contains { $0.id == "history-ancient-rome" && $0.isEarned })
        XCTAssertTrue(stats.worldRewardBadges.contains { $0.id == "history-medieval-europe" && !$0.isEarned && $0.xpRemaining == 500 })

        stats.xp = 500
        XCTAssertEqual(stats.earnedWorldRewardCount, 12)
        XCTAssertTrue(stats.worldRewardBadges.contains { $0.id == "health-resilience-gym" && $0.isEarned })
        XCTAssertTrue(stats.featuredWorldRewardBadges.contains { !$0.isEarned && $0.world.name == "Age of Discovery" })
    }

    func testWorldPathStopsTrackActiveLockedAndChallengeProgress() {
        var stats = UserStats()
        stats.xp = 125
        var progress = stats.progress(for: .history)
        progress.currentWorldId = "ancient-rome"
        progress.completedChallengeIds = ["rome-01", "rome-02"]
        stats.updateProgress(for: .history, progress)

        let stops = stats.worldPathStops(for: .history)

        XCTAssertEqual(stops.count, 3)
        XCTAssertEqual(stops[0].world.name, "Ancient Rome")
        XCTAssertTrue(stops[0].isSelected)
        XCTAssertFalse(stops[0].isLocked)
        XCTAssertEqual(stops[0].progressText, "2/5 missions")
        XCTAssertEqual(stops[0].progress, 0.4, accuracy: 0.001)

        XCTAssertEqual(stops[1].world.name, "Medieval Europe")
        XCTAssertTrue(stops[1].isLocked)
        XCTAssertEqual(stops[1].xpRemaining, 375)
        XCTAssertEqual(stops[1].statusText, "375 XP")

        XCTAssertTrue(stats.worldPathStops(for: .languages).isEmpty)
    }

    func testDailyAdventureFramesSubjectWorldAndUnlockReward() {
        let rome = Subject.history.worlds.first { $0.id == "ancient-rome" }
        let adventure = DailyAdventure(subject: .history, world: rome, xp: 125, streak: 3)

        XCTAssertEqual(adventure.title, "Ancient Rome Run")
        XCTAssertTrue(adventure.objective.contains("real turning point"))
        XCTAssertEqual(adventure.rewardLine, "+30 XP · Chronicle Page · streak x3")
        XCTAssertEqual(adventure.unlockHint, "375 XP to unlock Medieval Europe.")

        let languageAdventure = DailyAdventure(subject: .languages, world: nil, xp: 0, streak: 0)
        XCTAssertEqual(languageAdventure.title, "Language Harbor Run")
        XCTAssertTrue(languageAdventure.objective.contains("mixed prompts"))
        XCTAssertEqual(languageAdventure.rewardLine, "+30 XP · Fluency Drop")
    }

    func testDailyWorldEventBuildsCrossSubjectTour() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.xp = 0
            store.stats.reviewedToday = 1

            let event = store.buildDailyWorldEvent(dayIndex: 0)

            XCTAssertEqual(event.title, "World Tour: Evidence Trail")
            XCTAssertEqual(event.chapters.count, 4)
            XCTAssertEqual(event.chapters.map(\.subject), [.languages, .history, .science, .geography])
            XCTAssertEqual(event.chapters[0].title, "Language Harbor")
            XCTAssertEqual(event.chapters[1].world?.id, "ancient-rome")
            XCTAssertEqual(event.chapters[2].world?.id, "space-exploration")
            XCTAssertEqual(event.progressText, "1/4 worlds")
            XCTAssertEqual(event.currentChapter?.subject, .history)
            XCTAssertTrue(event.chapters[1].isCurrent)
            XCTAssertEqual(event.rewardText, "+45 XP · +4 gems · Crown")
        }
    }

    func testDailyWorldEventStartOpensCurrentChapter() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.reviewedToday = 0
            store.stats.xp = 0
            let expected = store.dailyWorldEvent.currentChapter

            store.startDailyWorldEvent()

            XCTAssertEqual(store.stats.selectedSubject, expected?.subject)
            XCTAssertTrue(store.feedbackMessage.contains("World Tour opened step"))
            XCTAssertTrue(store.feedbackMessage.contains(expected?.title ?? ""))
        }
    }

    func testStoreDailyAdventureUsesSelectedWorld() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .geography
            store.stats.xp = 350
            var progress = store.stats.progress(for: .geography)
            progress.currentWorldId = "african-wonders"
            store.stats.updateProgress(for: .geography, progress)

            XCTAssertEqual(store.dailyAdventure.title, "African Wonders Run")
            XCTAssertEqual(store.dailyAdventure.unlockHint, "Complete today's run to push your level track forward.")
        }
    }

    func testQuestBoardBuildsLanguageReviewAndUnlockTargets() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .languages
            store.stats.selectedLevel = .a1
            store.prepareSchedulesForCurrentSelection()

            let missions = store.questBoardMissions

            XCTAssertEqual(missions.count, 3)
            XCTAssertEqual(missions[0].kind, .dailyAdventure)
            XCTAssertEqual(missions[0].title, "Language Harbor Run")
            XCTAssertTrue(missions.contains { $0.kind == .languageReview && $0.id == "language-review" })
            XCTAssertTrue(missions.contains { $0.kind == .nextUnlock && $0.title == "Unlock African Wonders" })
        }
    }

    func testQuestBoardTracksActiveWorldProgressAndCanFocusUnlockTarget() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .history
            store.stats.xp = 125
            var progress = store.stats.progress(for: .history)
            progress.currentWorldId = "ancient-rome"
            progress.completedChallengeIds = ["rome-01", "rome-02"]
            store.stats.updateProgress(for: .history, progress)

            let missions = store.questBoardMissions
            let activeWorld = missions.first { $0.kind == .activeWorld }
            let nextUnlock = missions.first { $0.kind == .nextUnlock }

            XCTAssertEqual(activeWorld?.title, "Finish Ancient Rome")
            XCTAssertEqual(activeWorld?.progress ?? 0, 0.4, accuracy: 0.001)
            XCTAssertEqual(nextUnlock?.title, "Unlock African Wonders")

            store.startQuestBoardMission(nextUnlock!)

            XCTAssertEqual(store.stats.selectedSubject, .geography)
            XCTAssertEqual(store.currentWorld?.id, "european-capitals")
            XCTAssertTrue(store.feedbackMessage.contains("Unlock African Wonders"))
        }
    }

    func testSubjectChallengeUnlocksNextWorldRewardAtXPThreshold() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .health
            store.stats.xp = 490
            var progress = store.stats.progress(for: .health)
            progress.currentWorldId = "energy-clinic"
            progress.completedChallengeIds = []
            store.stats.updateProgress(for: .health, progress)

            let challenge = HealthData.challenges(for: "energy-clinic")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!

            store.submitHealthAnswer(challenge: challenge, choice: correctChoice)

            XCTAssertEqual(store.stats.xp, 515)
            XCTAssertEqual(store.newlyUnlockedWorld?.world.name, "Resilience Gym")
            XCTAssertEqual(store.newlyUnlockedWorld?.title, "Resilience Gym Badge")
            XCTAssertTrue(store.feedbackMessage.contains("Reward unlocked"))
            XCTAssertTrue(store.stats.worldRewardBadges.contains { $0.id == "health-resilience-gym" && $0.isEarned })
        }
    }

    func testDailyComboGrantsBonusEveryThirdCorrectSubjectMission() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .health
            store.stats.xp = 0
            store.stats.gems = 0
            var progress = store.stats.progress(for: .health)
            progress.currentWorldId = "energy-clinic"
            progress.completedChallengeIds = []
            store.stats.updateProgress(for: .health, progress)

            let challenges = HealthData.challenges(for: "energy-clinic")
            for challenge in challenges.prefix(3) {
                let correctChoice = challenge.choices.first { $0.isCorrect }!
                store.submitHealthAnswer(challenge: challenge, choice: correctChoice)
            }

            XCTAssertEqual(store.stats.correctToday, 3)
            XCTAssertEqual(store.stats.xp, 80)
            XCTAssertEqual(store.stats.gems, 7)
            XCTAssertEqual(store.dailyCombo.title, "Focus Combo x1")
            XCTAssertTrue(store.feedbackMessage.contains("Combo x1"))
        }
    }

    func testStreakChestRequiresDailyQuestAndClaimsOnce() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .health
            store.stats.xp = 485
            store.stats.gems = 1
            store.stats.streak = 4
            store.stats.reviewedToday = store.dailyQuest.target

            XCTAssertTrue(store.streakChest.isReady)
            XCTAssertFalse(store.streakChest.isClaimedToday)
            XCTAssertEqual(store.streakChest.rewardXP, 29)
            XCTAssertEqual(store.streakChest.rewardGems, 3)

            XCTAssertTrue(store.claimStreakChest(now: Date()))
            XCTAssertEqual(store.stats.xp, 514)
            XCTAssertEqual(store.stats.gems, 4)
            XCTAssertEqual(store.newlyUnlockedWorld?.world.name, "Resilience Gym")
            XCTAssertTrue(store.streakChest.isClaimedToday)

            XCTAssertFalse(store.claimStreakChest(now: Date()))
            XCTAssertEqual(store.stats.xp, 514)
            XCTAssertEqual(store.stats.gems, 4)
        }
    }

    func testRecommendedRunPrioritizesDailyAdventureThenReadyChest() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .history
            store.stats.streak = 3
            store.stats.reviewedToday = 0
            var progress = store.stats.progress(for: .history)
            progress.currentWorldId = "ancient-rome"
            store.stats.updateProgress(for: .history, progress)

            let adventure = store.recommendedRun
            XCTAssertEqual(adventure.action, .dailyAdventure)
            XCTAssertEqual(adventure.title, "Ancient Rome Run")
            XCTAssertEqual(adventure.ctaTitle, "Start Run")
            XCTAssertLessThan(adventure.progress, 1)

            store.stats.reviewedToday = store.dailyQuest.target
            let chest = store.recommendedRun
            XCTAssertEqual(chest.action, .claimStreakChest)
            XCTAssertEqual(chest.title, "Open your streak chest")
            XCTAssertEqual(chest.reward, "+26 XP · +3 gems")
            XCTAssertEqual(chest.progress, 1)
        }
    }

    func testRecommendedRunFocusesNextUnlockAfterClaimedChest() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .math
            store.stats.xp = 275
            store.stats.reviewedToday = store.dailyQuest.target
            store.stats.lastStreakChestClaimDate = Date()

            let recommendation = store.recommendedRun
            XCTAssertEqual(recommendation.action, .nextUnlock)
            XCTAssertEqual(recommendation.title, "Chase African Wonders")
            XCTAssertEqual(recommendation.subject, .geography)

            store.startRecommendedRun(recommendation)

            XCTAssertEqual(store.stats.selectedSubject, .geography)
            XCTAssertEqual(store.currentWorld?.id, "european-capitals")
            XCTAssertTrue(store.feedbackMessage.contains("Recommended run focused"))
        }
    }

    func testDailyTrainingPlanBuildsActionableRunCards() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .languages
            store.stats.xp = 0
            store.stats.reviewedToday = 1

            let plan = store.dailyTrainingPlan

            XCTAssertEqual(plan.title, "Daily Training Plan")
            XCTAssertEqual(plan.cards.count, 3)
            XCTAssertEqual(plan.cards.map(\.id), ["best-run", "cross-train", "world-tour"])
            XCTAssertEqual(plan.cards[0].action, .recommendedRun)
            XCTAssertTrue(plan.cards[0].isPrimary)
            XCTAssertEqual(plan.cards[1].action, .masteryCatchUp)
            XCTAssertEqual(plan.cards[2].action, .worldTour)
            XCTAssertEqual(plan.progressText, "3 live routes")
            XCTAssertTrue(plan.subtitle.contains(plan.cards[0].title))
        }
    }

    func testDailyTrainingPlanCardRoutesToWorldTour() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.xp = 0
            store.stats.reviewedToday = 1
            let worldTour = store.dailyTrainingPlan.cards.first { $0.action == .worldTour }
            XCTAssertNotNil(worldTour)
            let expectedSubject = worldTour!.subject
            let expectedWorld = expectedSubject.worlds.first { $0.isUnlocked(withXP: store.stats.xp) }

            store.startTrainingPlanCard(worldTour!)

            XCTAssertEqual(store.stats.selectedSubject, expectedSubject)
            if expectedSubject == .languages {
                XCTAssertNil(store.currentWorld)
            } else {
                XCTAssertEqual(store.currentWorld?.id, expectedWorld?.id)
            }
            XCTAssertTrue(store.feedbackMessage.contains("World Tour opened step 2"))
        }
    }

    func testRepeatedSubjectChallengeDoesNotDuplicateUnlockBanner() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .health
            store.stats.xp = 490
            var progress = store.stats.progress(for: .health)
            progress.currentWorldId = "energy-clinic"
            progress.completedChallengeIds = []
            store.stats.updateProgress(for: .health, progress)

            let challenge = HealthData.challenges(for: "energy-clinic")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!

            store.submitHealthAnswer(challenge: challenge, choice: correctChoice)
            store.newlyUnlockedWorld = nil
            store.submitHealthAnswer(challenge: challenge, choice: correctChoice)

            XCTAssertEqual(store.stats.xp, 515)
            XCTAssertNil(store.newlyUnlockedWorld)
        }
    }

    func testRewardShopUnlocksAndEquipsAffordableCosmetic() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .history
            store.stats.xp = 125
            store.stats.gems = 8

            let shop = store.stats.rewardShop
            XCTAssertEqual(shop.items.count, 4)
            XCTAssertEqual(shop.featuredItem?.id, "aura-trail-starter")
            XCTAssertEqual(shop.affordabilityText, "Ready to unlock")

            let item = shop.items.first { $0.id == "aura-trail-starter" }!
            XCTAssertTrue(store.activateRewardShopItem(item))

            XCTAssertEqual(store.stats.gems, 2)
            XCTAssertEqual(store.stats.ownedRewardIds ?? [], ["aura-trail-starter"])
            XCTAssertEqual(store.stats.equippedRewardId, "aura-trail-starter")
            XCTAssertEqual(store.stats.rewardShop.progressText, "1/4 owned")
            XCTAssertTrue(store.feedbackMessage.contains("Unlocked and equipped"))
        }
    }

    func testRewardShopBlocksLockedAndUnaffordableItems() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.xp = 0
            store.stats.gems = 0

            let locked = store.stats.rewardShop.items.first { $0.id == "aura-trail-starter" }!
            XCTAssertFalse(locked.isUnlocked)
            XCTAssertFalse(store.activateRewardShopItem(locked))
            XCTAssertTrue(store.feedbackMessage.contains("locked"))

            store.stats.xp = 100
            let unaffordable = store.stats.rewardShop.items.first { $0.id == "aura-trail-starter" }!
            XCTAssertTrue(unaffordable.isUnlocked)
            XCTAssertFalse(store.activateRewardShopItem(unaffordable))
            XCTAssertTrue(store.feedbackMessage.contains("more gems"))
        }
    }

    func testCompletingWorldGrantsOneTimeCompletionReward() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .history
            store.stats.xp = 420
            store.stats.gems = 3

            let challenges = HistoryData.challenges(for: "ancient-rome")
            XCTAssertGreaterThan(challenges.count, 1)
            var progress = store.stats.progress(for: .history)
            progress.currentWorldId = "ancient-rome"
            progress.completedChallengeIds = challenges.dropLast().map(\.id)
            store.stats.updateProgress(for: .history, progress)

            let finalChallenge = challenges.last!
            let correctChoice = finalChallenge.choices.first { $0.isCorrect }!

            store.submitHistoryAnswer(challenge: finalChallenge, choice: correctChoice)

            XCTAssertEqual(store.stats.xp, 485)
            XCTAssertEqual(store.stats.gems, 9)
            XCTAssertEqual(store.newlyCompletedWorld?.title, "Ancient Rome Cleared")
            XCTAssertEqual(store.newlyCompletedWorld?.progressText, "\(challenges.count)/\(challenges.count) missions complete")
            XCTAssertEqual(store.newlyCompletedWorld?.nextWorld?.id, "medieval-europe")
            XCTAssertEqual(store.newlyCompletedWorld?.nextWorldXPRemaining, 15)
            XCTAssertTrue(store.feedbackMessage.contains("World cleared"))
        }
    }

    func testCompletedWorldRewardDoesNotRepeatForFinishedChallenge() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.selectedSubject = .science
            store.stats.xp = 100
            store.stats.gems = 2

            let challenges = ScienceData.challenges(for: "space-exploration")
            var progress = store.stats.progress(for: .science)
            progress.currentWorldId = "space-exploration"
            progress.completedChallengeIds = challenges.map(\.id)
            store.stats.updateProgress(for: .science, progress)

            let challenge = challenges[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!

            store.submitScienceAnswer(challenge: challenge, choice: correctChoice)

            XCTAssertEqual(store.stats.xp, 100)
            XCTAssertEqual(store.stats.gems, 2)
            XCTAssertNil(store.newlyCompletedWorld)
        }
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
        XCTAssertEqual(vienna?.mapTargetLabel, "Austria")
        XCTAssertEqual(vienna?.mapTargetX ?? 0, 0.54, accuracy: 0.001)
        XCTAssertEqual(vienna?.mapTargetY ?? 0, 0.48, accuracy: 0.001)
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

    func testBusinessWorldsExist() {
        let businessWorlds = Subject.business.worlds
        XCTAssertGreaterThanOrEqual(businessWorlds.count, 2)
        XCTAssertTrue(businessWorlds.contains { $0.id == "founder-guild" })
        XCTAssertTrue(businessWorlds.contains { $0.id == "wall-street-desk" })
    }

    func testFounderGuildChallengesLoaded() {
        let challenges = BusinessData.challenges(for: "founder-guild")
        XCTAssertGreaterThanOrEqual(challenges.count, 4)
        let discovery = challenges.first { $0.id == "business-founder-01" }
        XCTAssertNotNil(discovery)
        XCTAssertEqual(discovery?.domain, "Customer Discovery")
        XCTAssertEqual(discovery?.choices.count, 4)
        XCTAssertTrue(discovery?.choices.contains { $0.isCorrect && $0.text.contains("Interview") } ?? false)
    }

    func testBusinessChallengeScoring() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .business
            store.select(worldId: "founder-guild", for: .business)

            let challenge = BusinessData.challenges(for: "founder-guild")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            let initialXP = store.stats.xp
            let initialGems = store.stats.gems

            store.submitBusinessAnswer(challenge: challenge, choice: correctChoice)

            XCTAssertEqual(store.stats.xp, initialXP + 25)
            XCTAssertEqual(store.stats.gems, initialGems + 2)
            let progress = store.stats.progress(for: .business)
            XCTAssertTrue(progress.completedChallengeIds.contains(challenge.id))
        }
    }

    func testBusinessProgressPercent() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .business
            store.select(worldId: "founder-guild", for: .business)

            let challenge = BusinessData.challenges(for: "founder-guild")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            store.submitBusinessAnswer(challenge: challenge, choice: correctChoice)

            let percent = store.businessProgressPercent
            XCTAssertGreaterThan(percent, 0)
            XCTAssertLessThanOrEqual(percent, 1.0)
        }
    }

    func testHealthWorldsExist() {
        let healthWorlds = Subject.health.worlds
        XCTAssertGreaterThanOrEqual(healthWorlds.count, 2)
        XCTAssertTrue(healthWorlds.contains { $0.id == "energy-clinic" })
        XCTAssertTrue(healthWorlds.contains { $0.id == "resilience-gym" })
    }

    func testEnergyClinicChallengesLoaded() {
        let challenges = HealthData.challenges(for: "energy-clinic")
        XCTAssertGreaterThanOrEqual(challenges.count, 4)
        let sleep = challenges.first { $0.id == "health-energy-01" }
        XCTAssertNotNil(sleep)
        XCTAssertEqual(sleep?.domain, "Sleep")
        XCTAssertEqual(sleep?.choices.count, 4)
        XCTAssertTrue(sleep?.choices.contains { $0.isCorrect && $0.text.contains("Dim lights") } ?? false)
    }

    func testHealthChallengeScoring() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .health
            store.select(worldId: "energy-clinic", for: .health)

            let challenge = HealthData.challenges(for: "energy-clinic")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            let initialXP = store.stats.xp
            let initialGems = store.stats.gems

            store.submitHealthAnswer(challenge: challenge, choice: correctChoice)

            XCTAssertEqual(store.stats.xp, initialXP + 25)
            XCTAssertEqual(store.stats.gems, initialGems + 2)
            let progress = store.stats.progress(for: .health)
            XCTAssertTrue(progress.completedChallengeIds.contains(challenge.id))
        }
    }

    func testHealthProgressPercent() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.selectedSubject = .health
            store.select(worldId: "energy-clinic", for: .health)

            let challenge = HealthData.challenges(for: "energy-clinic")[0]
            let correctChoice = challenge.choices.first { $0.isCorrect }!
            store.submitHealthAnswer(challenge: challenge, choice: correctChoice)

            let percent = store.healthProgressPercent
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

    func testSelectingBusinessStartsFirstWorld() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true

            store.select(subject: .business)

            XCTAssertEqual(store.stats.selectedSubject, .business)
            XCTAssertEqual(store.currentWorld?.id, "founder-guild")
            XCTAssertNotNil(store.nextBusinessChallenge)
        }
    }

    func testSelectingHealthStartsFirstWorld() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true

            store.select(subject: .health)

            XCTAssertEqual(store.stats.selectedSubject, .health)
            XCTAssertEqual(store.currentWorld?.id, "energy-clinic")
            XCTAssertNotNil(store.nextHealthChallenge)
        }
    }

    func testRandomStudyStartsUnlockedPlayableWorld() async {
        await MainActor.run {
            let store = AppStore()
            store.stats.hasSeenTitle = true
            store.stats.hasSkippedAuth = true
            store.stats.hasSeenPetPicker = true
            store.stats.hasSeenSubjectPicker = true
            store.stats.xp = 0

            let worldOption = store.stats.questRoulette.options.first { $0.subject != .languages && $0.world != nil }
            XCTAssertNotNil(worldOption)

            store.startRandomStudy(option: worldOption)

            XCTAssertNotEqual(store.stats.selectedSubject, .languages)
            XCTAssertNotNil(store.currentWorld)
            XCTAssertTrue(store.currentWorld?.isUnlocked(withXP: store.stats.xp) ?? false)
            XCTAssertTrue(store.feedbackMessage.contains("Roulette picked"))
        }
    }
    
    func testSubjectDefaultIsLanguages() {
        let stats = UserStats()
        XCTAssertEqual(stats.selectedSubject, .languages)
    }
}
