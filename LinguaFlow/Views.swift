import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var authService: AuthService
    @Environment(\.colorScheme) private var colorScheme
    @State private var showLevelPicker = false
    @State private var showSubjectPicker = false
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            if !store.stats.hasSeenTitle { OnboardingView() }
            else if !authService.isAuthenticated && !store.stats.hasSkippedAuth { AuthView() }
            else if !store.stats.hasSeenPetPicker { PetPickerView { store.stats.hasSeenPetPicker = true; store.save() } }
            else if !store.stats.hasSeenSubjectPicker { SubjectPickerView { store.stats.hasSeenSubjectPicker = true; store.save() } }
            else if store.stats.selectedSubject == .languages && (store.stats.selectedLevel == nil || showLevelPicker) { LevelPickerView(onBack: { showLevelPicker = false }) }
            else { DashboardView(showLevelPicker: $showLevelPicker, showSubjectPicker: $showSubjectPicker) }
        }
        .preferredColorScheme(store.stats.darkMode ? .dark : nil)
    }
}

struct AppLogoView: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.primary.opacity(0.15), lineWidth: 1.2))
            Text("💧").font(.system(size: 44))
        }
        .frame(width: 92, height: 92)
        .shadow(color: Color.primary.opacity(0.06), radius: 20, y: 8)
        .accessibilityIdentifier("appLogo")
    }
}

struct GlassCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content.padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.primary.opacity(0.12), lineWidth: 1))
            .shadow(color: Color.primary.opacity(colorScheme == .dark ? 0.35 : 0.1), radius: 20, x: 0, y: 10)
    }
}

struct PrimaryButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.headline.bold()).foregroundStyle(colorScheme == .dark ? .black : .white).frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(colorScheme == .dark ? Color.white : Color.black, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

struct SecondaryButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let icon: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon).font(.subheadline.bold()).foregroundStyle(.primary).frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.primary.opacity(0.12), lineWidth: 1))
        }
    }
}

struct TitleScreenView: View {
    @EnvironmentObject var store: AppStore
    @State private var showGameOnboarding = false
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            AppLogoView()
            VStack(spacing: 10) {
                Text("QuestFlow").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.primary)
                Text("Learn through playable worlds").font(.title3).foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 14) {
                FeatureRow(icon: "keyboard", text: "Type or speak every answer")
                FeatureRow(icon: "arrow.triangle.2.circlepath", text: "Auto-mixed directions & sentences")
                FeatureRow(icon: "target", text: "Daily fluency goal tracking")
                FeatureRow(icon: "timer", text: "Built-in Pomodoro focus mode")
            }.padding(.horizontal, 32).padding(.vertical, 8)
            PrimaryButton(title: "Get Started") {
                store.finishTitle()
                showGameOnboarding = true
            }
            .padding(.horizontal, 32)
            .accessibilityIdentifier("startLearningButton")
            Spacer()
        }
        .accessibilityIdentifier("titleScreen")
        .fullScreenCover(isPresented: $showGameOnboarding) {
            PetPickerView { showGameOnboarding = false }
        }
    }
}

struct FeatureRow: View {
    let icon: String; let text: String
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.title3).foregroundStyle(.secondary).frame(width: 28)
            Text(text).font(.subheadline).foregroundStyle(.primary)
            Spacer()
        }
    }
}

struct LevelPickerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    var onBack: (() -> Void)? = nil
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Choose your level").font(.largeTitle.bold()).foregroundStyle(.primary).accessibilityIdentifier("chooseNiveauTitle")
                    Spacer()
                    if onBack != nil {
                        Button { onBack?() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                ForEach(CEFRLevel.allCases) { level in
                    let isUnlocked = true  // All levels unlocked for testing
                    Button { store.select(level: level) } label: {
                        GlassCard {
                            HStack(spacing: 16) {
                                Text(level.rawValue).font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(isUnlocked ? .primary : .secondary).frame(width: 64)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(level.subtitle).font(.headline).foregroundStyle(isUnlocked ? .primary : .secondary)
                                    Text(isUnlocked ? "Speaking-first vocabulary" : "Complete previous level to unlock").font(.caption).foregroundStyle(.secondary.opacity(isUnlocked ? 0.8 : 0.5))
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.title3.bold()).foregroundStyle(.secondary.opacity(0.5))
                            }
                        }
                    }.buttonStyle(.plain).accessibilityIdentifier("level_\(level.rawValue)")
                }
            }.padding(20).padding(.top, 20)
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var store: AppStore
    @Binding var showLevelPicker: Bool
    @Binding var showSubjectPicker: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var showingSettings = false
    init(showLevelPicker: Binding<Bool> = .constant(false), showSubjectPicker: Binding<Bool> = .constant(false)) {
        _showLevelPicker = showLevelPicker
        _showSubjectPicker = showSubjectPicker
    }
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    Color.clear.frame(height: 0).accessibilityIdentifier("dashboardReady")
                    header
                    subjectHeader
                    RandomStudyView()
                    ChallengeUITestControls()
                    DailyQuestView()
                    LevelTrackView()
                    RewardVaultView()
                    PetView()
                    if let unlocked = store.newlyUnlockedLevel {
                        UnlockBanner(level: unlocked) { store.newlyUnlockedLevel = nil }
                    }
                    if store.stats.selectedSubject == .languages {
                        FluencyDropView()
                        GoalView()
                        ReviewCardView()
                    } else if store.stats.selectedSubject == .history {
                        HistoryWorldView()
                        HistoryChallengeView()
                    } else if store.stats.selectedSubject == .science {
                        ScienceWorldView()
                        ScienceChallengeView()
                    } else if store.stats.selectedSubject == .geography {
                        GeographyWorldView()
                        GeographyChallengeView()
                    } else if store.stats.selectedSubject == .math {
                        MathWorldView()
                        MathChallengeView()
                    } else if store.stats.selectedSubject == .culture {
                        CultureWorldView()
                        CultureChallengeView()
                    } else if store.stats.selectedSubject == .business {
                        BusinessWorldView()
                        BusinessChallengeView()
                    } else if store.stats.selectedSubject == .health {
                        HealthWorldView()
                        HealthChallengeView()
                    } else {
                        ComingSoonSubjectView()
                    }
                    PomodoroView()
                    statsGrid
                    Spacer().frame(height: keyboardHeight + 40)
                }.padding(18)
            }
            .sheet(isPresented: $showingSettings) { SettingsView(isPresented: $showingSettings) }
            .sheet(isPresented: $showSubjectPicker) { SubjectPickerView { showSubjectPicker = false } }
            .scrollDismissesKeyboard(.interactively)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notif in
                if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation(.easeOut(duration: 0.25)) { keyboardHeight = frame.height }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.easeOut(duration: 0.25)) { keyboardHeight = 0 }
            }
            .accessibilityIdentifier("dashboardView")
        }
    }
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Quest").font(.largeTitle.bold()).foregroundStyle(.primary)
                Text("\(store.stats.selectedSubject.displayName) · \(store.stats.streak > 1 ? "🔥 \(store.stats.streak)-day streak" : "Start a streak today.")")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Button { showSubjectPicker = true } label: {
                Image(systemName: "book.circle.fill").font(.system(size: 28)).foregroundStyle(.primary.opacity(0.9))
            }.accessibilityIdentifier("subjectSwitchButton")
            if store.stats.selectedSubject == .languages {
                Button { showLevelPicker = true } label: {
                    Image(systemName: "arrow.up.arrow.down.circle.fill").font(.system(size: 28)).foregroundStyle(.primary.opacity(0.9))
                }.accessibilityIdentifier("levelSwitchButton")
                Button { store.toggleDirection() } label: {
                    Image(systemName: "shuffle.circle.fill").font(.system(size: 32)).foregroundStyle(.primary.opacity(0.9))
                }.accessibilityIdentifier("directionToggle")
            }
            Button { showingSettings = true } label: {
                Image(systemName: "gearshape.fill").font(.system(size: 28)).foregroundStyle(.primary.opacity(0.9))
            }
            .accessibilityLabel("Settings")
            .accessibilityIdentifier("settingsButton")
        }
    }

    var subjectHeader: some View {
        HStack {
            Image(systemName: store.stats.selectedSubject.icon)
                .font(.title2)
                .foregroundStyle(store.stats.selectedSubject.accentColor)
            Text(store.stats.selectedSubject.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 4)
    }
    var statsGrid: some View {
        HStack(spacing: 10) {
            StatPill(title: "XP", value: "\(store.stats.xp)", icon: "sparkles")
            StatPill(title: "Streak", value: "\(store.stats.streak)", icon: "flame.fill")
            StatPill(title: "Gems", value: "\(store.stats.gems)", icon: "diamond.fill")
        }
    }
}

struct RandomStudyView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.35)) {
                store.startRandomStudy()
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: [.purple.opacity(0.24), .cyan.opacity(0.18), .yellow.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                    Image(systemName: "shuffle.circle.fill")
                        .font(.title2.bold())
                        .foregroundStyle(.purple)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quest Roulette")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(store.feedbackMessage.contains("Roulette picked") ? store.feedbackMessage : "Jump into a random unlocked world.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "play.fill")
                    .font(.caption.bold())
                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                    .frame(width: 28, height: 28)
                    .background(Color.primary, in: Circle())
            }
            .padding(14)
            .background(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.045), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.primary.opacity(0.1), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("randomStudyButton")
        .accessibilityElement(children: .combine)
        .accessibilityLabel(store.feedbackMessage.contains("Roulette picked") ? "Quest Roulette. \(store.feedbackMessage)" : "Quest Roulette. Jump into a random unlocked world.")
    }
}

struct DailyQuestView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let quest = store.dailyQuest
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(store.stats.selectedSubject.accentColor.opacity(colorScheme == .dark ? 0.25 : 0.16))
                            .frame(width: 46, height: 46)
                        Image(systemName: "flag.checkered")
                            .font(.title3.bold())
                            .foregroundStyle(store.stats.selectedSubject.accentColor)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Daily Quest")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Text(quest.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .accessibilityIdentifier("dailyQuestTitle")
                    }
                    Spacer()
                    Text(quest.reward)
                        .font(.caption.bold())
                        .foregroundStyle(store.stats.selectedSubject.accentColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.1))
                        Capsule()
                            .fill(LinearGradient(colors: [store.stats.selectedSubject.accentColor, .green], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * quest.progress)
                    }
                }
                .frame(height: 10)

                Text(quest.progressText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("dailyQuestProgress")
            }
        }
        .accessibilityIdentifier("dailyQuestPanel")
    }
}

struct LevelTrackView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let stats = store.stats
        let nextUnlock = stats.nextWorldUnlockBadge
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .fill(LinearGradient(colors: [.indigo.opacity(0.22), .cyan.opacity(0.16), .green.opacity(0.14)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 48, height: 48)
                        Text("\(stats.learningLevel)")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Level \(stats.learningLevel) · \(stats.levelTitle)")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .accessibilityIdentifier("levelTrackTitle")
                        Text(stats.streakBoostText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("levelTrackStreak")
                    }
                    Spacer()
                    Text("\(stats.xpNeededForNextLevel) XP")
                        .font(.caption.bold())
                        .foregroundStyle(.indigo)
                        .accessibilityIdentifier("levelTrackNextXP")
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.1))
                        Capsule()
                            .fill(LinearGradient(colors: [.indigo, .cyan, .green], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * stats.levelProgress)
                    }
                }
                .frame(height: 10)
                .accessibilityIdentifier("levelTrackProgress")

                HStack(spacing: 8) {
                    Image(systemName: nextUnlock == nil ? "sparkles" : "lock.open")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(nextUnlock.map { "Next unlock: \($0.world.name) · \($0.xpRemaining) XP left" } ?? "All current worlds unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .accessibilityIdentifier("levelTrackNextUnlock")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("levelTrackPanel")
    }
}

struct RewardVaultView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let badges = store.stats.featuredWorldRewardBadges
        let progress = store.stats.worldRewardProgress
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.yellow.opacity(colorScheme == .dark ? 0.22 : 0.18))
                            .frame(width: 44, height: 44)
                        Image(systemName: "trophy.fill")
                            .font(.title3.bold())
                            .foregroundStyle(.yellow)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Reward Vault")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .accessibilityIdentifier("rewardVaultTitle")
                        Text("\(store.stats.earnedWorldRewardCount)/\(store.stats.totalWorldRewardCount) world badges collected")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("rewardVaultProgressText")
                    }
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(.yellow)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.1))
                        Capsule()
                            .fill(LinearGradient(colors: [.yellow, .orange, .green], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 9)

                HStack(spacing: 8) {
                    ForEach(badges) { badge in
                        RewardBadgeChip(badge: badge)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("rewardVaultPanel")
    }
}

struct RewardBadgeChip: View {
    let badge: WorldRewardBadge

    var body: some View {
        VStack(spacing: 5) {
            ZStack(alignment: .bottomTrailing) {
                Text(badge.world.emoji)
                    .font(.system(size: 28))
                    .frame(width: 46, height: 46)
                    .background(badge.subject.accentColor.opacity(badge.isEarned ? 0.18 : 0.07), in: Circle())
                    .saturation(badge.isEarned ? 1 : 0.15)
                    .opacity(badge.isEarned ? 1 : 0.62)
                Image(systemName: badge.systemImage)
                    .font(.caption2.bold())
                    .foregroundStyle(badge.isEarned ? .green : .secondary)
                    .padding(4)
                    .background(.thinMaterial, in: Circle())
            }
            Text(badge.world.name)
                .font(.caption2.bold())
                .foregroundStyle(badge.isEarned ? .primary : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(badge.isEarned ? "Collected" : "\(badge.xpRemaining) XP")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 86)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(Color.primary.opacity(badge.isEarned ? 0.055 : 0.035), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(badge.subject.accentColor.opacity(badge.isEarned ? 0.22 : 0.08), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(badge.title), \(badge.subtitle)")
        .accessibilityIdentifier("rewardBadge_\(badge.id)")
    }
}

private struct ChallengeUITestControls: View {
    @EnvironmentObject var store: AppStore
    @State private var answeredHistory = false
    @State private var answeredScience = false
    @State private var answeredGeography = false
    @State private var answeredMath = false
    @State private var answeredCulture = false
    @State private var answeredBusiness = false
    @State private var answeredHealth = false

    private var isHistoryUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("--ui-testing-history-world")
    }

    private var isScienceUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("--ui-testing-science-world")
    }

    private var isGeographyUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("--ui-testing-geography-world")
    }

    private var isMathUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("--ui-testing-math-world")
    }

    private var isCultureUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("--ui-testing-culture-world")
    }

    private var isBusinessUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("--ui-testing-business-world")
    }

    private var isHealthUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("--ui-testing-health-world")
    }

    var body: some View {
        if isHistoryUITest {
            VStack(alignment: .leading, spacing: 8) {
                if answeredHistory {
                    Button("Next Challenge") {
                        answeredHistory = false
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("nextHistoryChallenge")
                } else {
                    Button("Answer first history choice") {
                        if let challenge = store.nextHistoryChallenge,
                           let firstChoice = challenge.choices.first {
                            store.submitHistoryAnswer(challenge: challenge, choice: firstChoice)
                            answeredHistory = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("historyChoiceTestAction")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if isScienceUITest {
            VStack(alignment: .leading, spacing: 8) {
                if answeredScience {
                    Button("Next Mission") {
                        answeredScience = false
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("nextScienceChallenge")
                } else {
                    Button("Answer first science choice") {
                        if let challenge = store.nextScienceChallenge,
                           let firstChoice = challenge.choices.first {
                            store.submitScienceAnswer(challenge: challenge, choice: firstChoice)
                            answeredScience = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("scienceChoiceTestAction")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if isGeographyUITest {
            VStack(alignment: .leading, spacing: 8) {
                if answeredGeography {
                    Button("Next Route") {
                        answeredGeography = false
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("nextGeographyChallenge")
                } else {
                    Button("Answer first geography choice") {
                        if let challenge = store.nextGeographyChallenge,
                           let firstChoice = challenge.choices.first {
                            store.submitGeographyAnswer(challenge: challenge, choice: firstChoice)
                            answeredGeography = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("geographyChoiceTestAction")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if isMathUITest {
            VStack(alignment: .leading, spacing: 8) {
                if answeredMath {
                    Button("Next Puzzle") {
                        answeredMath = false
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("nextMathChallenge")
                } else {
                    Button("Answer first math choice") {
                        if let challenge = store.nextMathChallenge,
                           let firstChoice = challenge.choices.first {
                            store.submitMathAnswer(challenge: challenge, choice: firstChoice)
                            answeredMath = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("mathChoiceTestAction")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if isCultureUITest {
            VStack(alignment: .leading, spacing: 8) {
                if answeredCulture {
                    Button("Next Story") {
                        answeredCulture = false
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("nextCultureChallenge")
                } else {
                    Button("Answer first culture choice") {
                        if let challenge = store.nextCultureChallenge,
                           let firstChoice = challenge.choices.first {
                            store.submitCultureAnswer(challenge: challenge, choice: firstChoice)
                            answeredCulture = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("cultureChoiceTestAction")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if isBusinessUITest {
            VStack(alignment: .leading, spacing: 8) {
                if answeredBusiness {
                    Button("Next Deal") {
                        answeredBusiness = false
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("nextBusinessChallenge")
                } else {
                    Button("Answer first business choice") {
                        if let challenge = store.nextBusinessChallenge,
                           let firstChoice = challenge.choices.first {
                            store.submitBusinessAnswer(challenge: challenge, choice: firstChoice)
                            answeredBusiness = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("businessChoiceTestAction")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else if isHealthUITest {
            VStack(alignment: .leading, spacing: 8) {
                if answeredHealth {
                    Button("Next Habit") {
                        answeredHealth = false
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("nextHealthChallenge")
                } else {
                    Button("Answer first health choice") {
                        if let challenge = store.nextHealthChallenge,
                           let firstChoice = challenge.choices.first {
                            store.submitHealthAnswer(challenge: challenge, choice: firstChoice)
                            answeredHealth = true
                        }
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("healthChoiceTestAction")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct UnlockBanner: View {
    let level: CEFRLevel
    let dismiss: () -> Void
    var body: some View {
        GlassCard {
            VStack(spacing: 8) {
                Text("🎉 Level Unlocked").font(.headline).foregroundStyle(.primary)
                Text("You mastered \(level.rawValue)!").font(.subheadline).foregroundStyle(.primary.opacity(0.9))
                Button("Continue") { dismiss() }
                    .buttonStyle(.borderedProminent).tint(.green.opacity(0.7))
            }
        }
    }
}

struct FeedbackBanner: View {
    @Environment(\.colorScheme) private var colorScheme
    let text: String
    var body: some View {
        Text(text)
            .font(.subheadline.bold())
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.05), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(0.1), lineWidth: 1))
            .accessibilityIdentifier("answerFeedback")
    }
}

struct FluencyDropView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack { Text("Fluency").font(.headline).foregroundStyle(.primary); Spacer(); Text("\(Int(store.realFluency * 100))%").bold().foregroundStyle(.primary) }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.15))
                        Capsule().fill(Color.blue.opacity(0.85)).frame(width: geo.size.width * store.realFluency)
                    }
                }.frame(height: 10)
                Text("\(store.masteredCount) of \(store.availableCards.count) words mastered · \(store.stats.streak > 1 ? "🔥 \(store.stats.streak)-day streak" : "Start a streak today.")")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }.accessibilityIdentifier("fluencyDrop")
    }
}

struct GoalView: View {
    @EnvironmentObject var store: AppStore
    @State private var goalName = ""
    @State private var goalDate = Date()
    @State private var dailyGoal = 12
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Goal", systemImage: "target").font(.headline)
                    Spacer()
                    Text(store.learnedEnoughToday ? "On track ✅" : "\(max(store.stats.dailyGoal, store.goalDailyNeed) - store.stats.reviewedToday) left")
                        .font(.caption.bold())
                }
                Text(store.stats.goalName).font(.subheadline.bold())
                Text("Daily target: \(max(store.stats.dailyGoal, store.goalDailyNeed)) cards · Goal date: \(store.stats.goalDate, style: .date)").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct ReviewCardView: View {
    @EnvironmentObject var store: AppStore
    @State private var typedAnswer = ""
    @FocusState private var isInputFocused: Bool
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack { Text("Review").font(.headline); Spacer(); Text(store.challengeMode == .sentence ? "Sentence" : "Word").font(.caption).foregroundStyle(.secondary) }
                if let card = store.currentCard {
                    Group {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Prompt:").font(.caption).foregroundStyle(.secondary)
                            Text(store.currentPrompt).font(.title2.bold())
                                .accessibilityIdentifier("promptText")
                            Button("Speak prompt") { store.speakPrompt() }.font(.caption)
                        }
                        TextField("Type your answer…", text: $typedAnswer)
                            .textFieldStyle(.roundedBorder)
                            .focused($isInputFocused)
                            .accessibilityIdentifier("answerInput")
                        HStack(spacing: 8) {
                            Button("Speak answer") { store.startSpeechInput() }.font(.caption)
                            if !store.spokenTranscript.isEmpty {
                                Button("Use speech") { typedAnswer = store.spokenTranscript }.font(.caption).buttonStyle(.borderedProminent).tint(.blue)
                            }
                        }
                        Button("Check") { check(typedAnswer) }
                            .buttonStyle(.borderedProminent)
                            .disabled(typedAnswer.isEmpty)
                            .accessibilityIdentifier("checkAnswerButton")
                        if !store.feedbackMessage.isEmpty {
                            Text(store.feedbackMessage)
                                .font(.subheadline.bold())
                                .foregroundStyle(store.feedbackMessage.contains("✅") ? .green : (store.feedbackMessage.contains("🟡") ? .orange : .red))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .accessibilityIdentifier("answerFeedback")
                        }
                        HStack(spacing: 10) {
                            ForEach(ReviewGrade.allCases) { grade in
                                Button(grade.title) { store.grade(grade, expected: store.currentAnswer) }
                                    .buttonStyle(.bordered)
                                    .tint(grade.color)
                            }
                        }
                        if store.combo > 2 { Text("Combo x\(store.combo) ⚡️").bold().foregroundStyle(.yellow) }
                    }
                }
            }
        }
        .onChange(of: store.currentCard?.id) { _, _ in typedAnswer = ""; store.spokenTranscript = "" }
    }
    private func check(_ answer: String) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        _ = store.submit(answer: answer)
        typedAnswer = ""
    }
}

struct PomodoroView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var work = 25
    @State private var pause = 5
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack { Label("Focus", systemImage: "timer").font(.headline); Spacer(); Text(store.pomodoroIsBreak ? "Break" : "Focus").bold() }
                Text(String(format: "%02d:%02d", store.pomodoroRemaining / 60, store.pomodoroRemaining % 60))
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                Stepper("Focus: \(work)m", value: $work, in: 5...60, step: 5)
                Stepper("Pause: \(pause)m", value: $pause, in: 1...20)
                HStack {
                    Button(store.pomodoroRunning ? "Pause" : "Start") { store.setPomodoro(work: work, pause: pause); store.togglePomodoro() }
                        .buttonStyle(.borderedProminent).tint(.primary.opacity(0.2))
                    Button("Reset") { store.setPomodoro(work: work, pause: pause) }.buttonStyle(.bordered)
                }
            }.foregroundStyle(.primary)
        }.onAppear { work = store.stats.workMinutes; pause = store.stats.breakMinutes }
    }
}

struct StatPill: View {
    let title: String; let value: String; let icon: String
    var body: some View {
        GlassCard {
            VStack(spacing: 5) {
                Image(systemName: icon).foregroundStyle(.secondary)
                Text(value).font(.title3.bold()).foregroundStyle(.primary)
                Text(title).font(.caption).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity)
        }
    }
}

struct NextWorldUnlockView: View {
    let subject: Subject
    let xp: Int

    var body: some View {
        let accent = subject.accentColor
        if let world = subject.nextLockedWorld(withXP: xp), let requiredXP = world.unlockRequirement.xpRequired {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "lock.open.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(accent)
                        .frame(width: 24, height: 24)
                        .background(accent.opacity(0.16), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Next world unlock")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("nextWorldUnlock_\(subject.rawValue)")
                        Text("\(world.emoji) \(world.name)")
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    Text("\(world.xpRemaining(withXP: xp)) XP left")
                        .font(.caption.bold())
                        .foregroundStyle(accent)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.primary.opacity(0.1))
                        Capsule()
                            .fill(LinearGradient(colors: [accent, .green], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * world.unlockProgress(withXP: xp))
                    }
                }
                .frame(height: 8)

                Text("Reward: \(world.rewardName) · \(xp)/\(requiredXP) XP")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("nextWorldUnlockReward_\(subject.rawValue)")
            }
            .padding(12)
            .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(accent.opacity(0.18), lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Next world unlock \(world.name). Reward: \(world.rewardName). \(world.xpRemaining(withXP: xp)) XP left.")
            .accessibilityIdentifier("nextWorldUnlock_\(subject.rawValue)")
        } else if !subject.worlds.isEmpty {
            HStack(spacing: 10) {
                Image(systemName: "crown.fill")
                    .foregroundStyle(accent)
                Text("All worlds unlocked")
                    .font(.subheadline.bold())
                    .accessibilityIdentifier("nextWorldUnlock_\(subject.rawValue)")
                Spacer()
                Text("Rewards claimed")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("All worlds unlocked. Rewards claimed.")
            .accessibilityIdentifier("nextWorldUnlock_\(subject.rawValue)")
        }
    }
}

struct PetView: View {
    @EnvironmentObject var store: AppStore
    @State private var showingPetDetail = false
    var body: some View {
        GlassCard {
            HStack(spacing: 14) {
                Text(store.stats.pet.currentEmoji)
                    .font(.system(size: 44))
                    .accessibilityIdentifier("petEmoji")
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.stats.pet.name)
                        .font(.headline.bold())
                    HStack(spacing: 4) {
                        Text("Lv. \(store.stats.pet.level)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("• \(store.stats.pet.stage.title)")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                    Text(store.stats.pet.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                            .font(.caption)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.pink.opacity(0.2))
                                Capsule().fill(Color.pink).frame(width: geo.size.width * store.stats.pet.happiness)
                            }
                        }.frame(width: 40, height: 6)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(.orange)
                            .font(.caption)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.orange.opacity(0.2))
                                Capsule().fill(Color.orange).frame(width: geo.size.width * (1 - store.stats.pet.hunger))
                            }
                        }.frame(width: 40, height: 6)
                    }
                }
            }
        }
        .onTapGesture { showingPetDetail = true }
        .sheet(isPresented: $showingPetDetail) {
            PetDetailView()
        }
        .accessibilityIdentifier("petView")
    }
}

struct PetDetailView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var newName = ""
    @State private var showEvolutionAlert = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Pet Emoji + Stage Badge
                    ZStack(alignment: .bottomTrailing) {
                        Text(store.stats.pet.currentEmoji)
                            .font(.system(size: 100))
                        Text(store.stats.pet.stage.title)
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.8))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }

                    Text(store.stats.pet.name)
                        .font(.largeTitle.bold())

                    // Level + XP Progress
                    VStack(spacing: 8) {
                        Text("Level \(store.stats.pet.level) • \(store.stats.pet.xp) / \(store.stats.pet.xpToNextLevel) XP")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.blue.opacity(0.2))
                                Capsule().fill(Color.blue)
                                    .frame(width: geo.size.width * store.stats.pet.progressToNextLevel)
                            }
                        }.frame(height: 8)
                    }
                    .padding(.horizontal)

                    // Stats Bars
                    VStack(spacing: 12) {
                        StatBar(label: "Happiness", value: store.stats.pet.happiness, color: .pink, icon: "heart.fill")
                        StatBar(label: "Fullness", value: 1 - store.stats.pet.hunger, color: .orange, icon: "fork.knife")
                        StatBar(label: "Energy", value: store.stats.pet.energy, color: .green, icon: "bolt.fill")
                    }
                    .padding(.horizontal)

                    // Interactions
                    HStack(spacing: 12) {
                        PetActionButton(icon: "hand.tap.fill", label: "Stroke", color: .pink) {
                            var updatedStats = store.stats
                            updatedStats.pet.stroke()
                            store.stats = updatedStats
                            store.save()
                        }
                        PetActionButton(icon: "play.fill", label: "Play", color: .green) {
                            var updatedStats = store.stats
                            updatedStats.pet.play()
                            store.stats = updatedStats
                            store.save()
                        }
                        PetActionButton(icon: "moon.fill", label: "Sleep", color: .purple) {
                            var updatedStats = store.stats
                            updatedStats.pet.sleep()
                            store.stats = updatedStats
                            store.save()
                        }
                    }
                    .padding(.horizontal)

                    // Abilities
                    if !store.stats.pet.abilities.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Abilities")
                                .font(.headline)
                                .padding(.horizontal)
                            ForEach(store.stats.pet.abilities, id: \.name) { ability in
                                HStack(spacing: 12) {
                                    Image(systemName: ability.icon)
                                        .foregroundStyle(.blue)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(ability.name)
                                            .font(.subheadline.bold())
                                        Text(ability.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color.primary.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal)
                    }

                    Text(store.stats.pet.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Total words fed: \(store.stats.pet.totalFed)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // Rename
                    HStack {
                        TextField("New name...", text: $newName)
                            .textFieldStyle(.roundedBorder)
                        Button("Rename") {
                            if !newName.isEmpty {
                                store.stats.pet.name = newName
                                store.save()
                                newName = ""
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newName.isEmpty)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Your Pet")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}

struct PetActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct StatBar: View {
    let label: String
    let value: Double
    let color: Color
    let icon: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(color).frame(width: 20)
            Text(label).font(.subheadline)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.15))
                    Capsule().fill(color).frame(width: geo.size.width * value)
                }
            }.frame(height: 10)
            Text("\(Int(value * 100))%").font(.caption).foregroundStyle(.secondary).frame(width: 35, alignment: .trailing)
        }
    }
}

struct PetPickerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var colorScheme
    let onComplete: () -> Void
    @State private var selectedPet: PetType = .cat
    @State private var petName = ""
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)
                Text("Choose Your Learning Buddy")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("Your pet grows as you learn. Keep it happy by answering correctly!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                HStack(spacing: 16) {
                    ForEach(PetType.allCases) { type in
                        let isSelected = selectedPet == type
                        Button {
                            selectedPet = type
                            store.stats.pet.type = type
                        } label: {
                            VStack(spacing: 8) {
                                Text(type.emoji)
                                    .font(.system(size: 52))
                                Text(type.displayName)
                                    .font(.caption.bold())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(isSelected ? Color.blue.opacity(0.15) : Color.primary.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isSelected ? Color.blue : Color.primary.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                TextField("Name your pet...", text: $petName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 32)
                    .font(.headline)

                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack { Image(systemName: "heart.fill").foregroundStyle(.pink); Text("Happiness").font(.subheadline); Spacer(); Text("🟢 0.5").font(.caption) }
                        HStack { Image(systemName: "fork.knife").foregroundStyle(.orange); Text("Hunger").font(.subheadline); Spacer(); Text("🟡 0.3").font(.caption) }
                        HStack { Image(systemName: "bolt.fill").foregroundStyle(.green); Text("Energy").font(.subheadline); Spacer(); Text("🟢 0.7").font(.caption) }
                        Text("Answer correctly to feed your pet and level it up!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.horizontal)

                PrimaryButton(title: "Start Learning") {
                    store.stats.pet.type = selectedPet
                    if !petName.isEmpty { store.stats.pet.name = petName }
                    store.save()
                    onComplete()
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    @State private var showAccountSettings = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Spacer()
                        Button("Done") { store.save(); isPresented = false }
                            .font(.headline)
                            .accessibilityIdentifier("settingsDoneButton")
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)

                Section("Subject") {
                    Picker("Subject", selection: Binding(
                        get: { store.stats.selectedSubject },
                        set: { subject in
                            store.select(subject: subject)
                        }
                    )) {
                        ForEach(Subject.allCases) { subject in
                            Text(subject.displayName).tag(subject)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("subjectSettingsPicker")

                    Text(store.stats.selectedSubject.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Learning Language") {
                    Picker("I speak", selection: Binding(
                        get: { store.stats.selectedLanguagePair.source },
                        set: { source in
                            let currentTarget = store.stats.selectedLanguagePair.target
                            let target = currentTarget == source ? AppLanguage.allCases.first(where: { $0 != source }) ?? .english : currentTarget
                            store.select(languagePair: LanguagePair(source: source, target: target))
                        }
                    )) {
                        ForEach(AppLanguage.allCases) { language in
                            Text("\(language.flag) \(language.name)").tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("nativeLanguagePicker")

                    Picker("I want to learn", selection: Binding(
                        get: { store.stats.selectedLanguagePair.target },
                        set: { target in
                            let currentSource = store.stats.selectedLanguagePair.source
                            let source = currentSource == target ? AppLanguage.allCases.first(where: { $0 != target }) ?? .english : currentSource
                            store.select(languagePair: LanguagePair(source: source, target: target))
                        }
                    )) {
                        ForEach(AppLanguage.allCases) { language in
                            Text("\(language.flag) \(language.name)").tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("learningLanguagePicker")

                    Text("Currently: \(store.stats.selectedLanguagePair.learningName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Language Level") {
                    Picker("Level", selection: $store.stats.selectedLevel) {
                        ForEach(CEFRLevel.allCases) { level in
                            Text(level.rawValue + " — " + level.subtitle)
                                .tag(Optional(level))
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: store.stats.selectedLevel) { _, newLevel in
                        if let level = newLevel {
                            store.select(level: level)
                        }
                    }
                }
                Section("Account") {
                    if authService.isAuthenticated {
                        HStack {
                            Text("Signed in as")
                            Spacer()
                            Text(authService.email.isEmpty ? authService.displayName : authService.email)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Button("Manage account") { showAccountSettings = true }
                        Button("Switch login") {
                            authService.signOut()
                            var updatedStats = store.stats
                            updatedStats.hasSkippedAuth = false
                            store.stats = updatedStats
                            store.save()
                            isPresented = false
                        }
                    } else {
                        Text(store.stats.hasSkippedAuth ? "Using without an account" : "Not signed in")
                            .foregroundStyle(.secondary)
                        Button("Sign in or create account") {
                            var updatedStats = store.stats
                            updatedStats.hasSkippedAuth = false
                            store.stats = updatedStats
                            store.save()
                            isPresented = false
                            dismiss()
                        }
                    }
                }

                Section("Appearance") {
                    Toggle("Dark mode", isOn: $store.stats.darkMode)
                }
                Section("Audio & Feedback") {
                    Toggle("Sound", isOn: $store.stats.soundEnabled)
                    Toggle("Haptics", isOn: $store.stats.hapticsEnabled)
                    Toggle("Notifications", isOn: $store.stats.notificationsEnabled)
                }
                Section("Pomodoro defaults") {
                    Stepper("Focus minutes: \(store.stats.workMinutes)", value: $store.stats.workMinutes, in: 5...60, step: 5)
                    Stepper("Break minutes: \(store.stats.breakMinutes)", value: $store.stats.breakMinutes, in: 1...20)
                }
                Section("Data") {
                    Button("Reset all progress") {
                        store.stats = UserStats()
                        store.schedules = [:]
                        store.save()
                        isPresented = false
                    }
                    .foregroundStyle(.red)
                }
                Section("About") {
                    HStack { Text("Version"); Spacer(); Text("1.0").foregroundStyle(.secondary) }
                    Link("Privacy Policy", destination: URL(string: "https://lukaskoprolin.com/linguaflow/privacy-policy.html")!)
                    Link("End User License Agreement", destination: URL(string: "https://luke2program.github.io/LinguaFlow/eula.html")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAccountSettings) { AccountSettingsView() }
        }
    }
}

#Preview { RootView().environmentObject(AppStore()) }
import SwiftUI

// MARK: - Subject Picker
struct SubjectPickerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let onComplete: () -> Void
    @State private var selectedSubject: Subject = .languages
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)
                Text("What do you want to study first?")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Text("Pick your first world. You can switch anytime.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(spacing: 12) {
                    Button {
                        store.startRandomStudy()
                        onComplete()
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.purple.opacity(0.22), .cyan.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 52, height: 52)
                                Image(systemName: "shuffle.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.purple)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Surprise me")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("Start a random unlocked quest world.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "sparkles")
                                .foregroundStyle(.purple)
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.purple.opacity(0.07)))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.28), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("subject_randomStudy")

                    ForEach(Subject.allCases) { subject in
                        let isSelected = selectedSubject == subject
                        Button {
                            withAnimation(.spring(duration: 0.3)) {
                                selectedSubject = subject
                            }
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(subject.accentColor.opacity(0.15))
                                        .frame(width: 52, height: 52)
                                    Image(systemName: subject.icon)
                                        .font(.title2)
                                        .foregroundStyle(subject.accentColor)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(subject.displayName)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(subject.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(subject.accentColor)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isSelected ? subject.accentColor.opacity(0.08) : Color.primary.opacity(0.03))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isSelected ? subject.accentColor.opacity(0.4) : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("subject_\(subject.rawValue)")
                    }
                }
                .padding(.horizontal)

                PrimaryButton(title: "Start Learning") {
                    store.select(subject: selectedSubject)
                    onComplete()
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
        .accessibilityIdentifier("subjectPickerView")
    }
}

// MARK: - Generated Subject Map
struct SubjectMapPreview: View {
    let subject: Subject
    let worlds: [PlayableWorld]
    let selectedWorldId: String?
    let xp: Int
    let onSelect: (PlayableWorld) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: subject.mapSystemImage)
                Text(subject.mapTitle)
            }
            .font(.caption.bold())
            .foregroundStyle(subject.accentColor)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(subject.mapTitle)
            .accessibilityIdentifier("\(subject.rawValue)MapPreview")

            GeometryReader { proxy in
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    subject.accentColor.opacity(0.16),
                                    Color.primary.opacity(0.04),
                                    subject.accentColor.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(subject.accentColor.opacity(0.22), lineWidth: 1)
                        )

                    Path { path in
                        let points = mapPoints(in: proxy.size)
                        guard let first = points.first else { return }
                        path.move(to: first)
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    .stroke(subject.accentColor.opacity(0.42), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [7, 5]))

                    ForEach(Array(worlds.enumerated()), id: \.element.id) { index, world in
                        let point = mapPoint(index: index, count: worlds.count, size: proxy.size)
                        let locked = world.unlockRequirement.xpRequired.map { xp < $0 } ?? false
                        let selected = selectedWorldId == world.id

                        Button {
                            if !locked {
                                onSelect(world)
                            }
                        } label: {
                            VStack(spacing: 3) {
                                ZStack {
                                    Circle()
                                        .fill(selected ? subject.accentColor : Color(.systemBackground))
                                        .frame(width: selected ? 38 : 32, height: selected ? 38 : 32)
                                        .overlay(Circle().stroke(subject.accentColor.opacity(locked ? 0.25 : 0.75), lineWidth: 2))
                                    Text(locked ? "🔒" : world.emoji)
                                        .font(.system(size: selected ? 19 : 16))
                                }
                                Text(world.name)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(locked ? .secondary : .primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 76)
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(locked)
                        .position(point)
                        .accessibilityIdentifier("\(subject.rawValue)MapPin_\(world.id)")
                    }
                }
            }
            .frame(height: 148)
        }
    }

    private func mapPoints(in size: CGSize) -> [CGPoint] {
        worlds.indices.map { mapPoint(index: $0, count: worlds.count, size: size) }
    }

    private func mapPoint(index: Int, count: Int, size: CGSize) -> CGPoint {
        guard count > 1 else {
            return CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        }

        let fraction = CGFloat(index) / CGFloat(count - 1)
        let x = size.width * (0.16 + fraction * 0.68)
        let wave = CGFloat(sin(Double(fraction) * Double.pi * 1.35))
        let y = size.height * (0.64 - wave * 0.34)
        return CGPoint(x: x, y: min(max(y, size.height * 0.23), size.height * 0.74))
    }
}

struct RubiconCampaignMapView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedLocation = "Rubicon"
    @State private var routeProgress = 0.72
    @State private var decision = "Cross"

    private let locations: [HistoricalMapLocation] = [
        HistoricalMapLocation(id: "ravenna", title: "Ravenna", subtitle: "Caesar's winter quarters", x: 0.50, y: 0.26, color: .red, icon: "shield.lefthalf.filled"),
        HistoricalMapLocation(id: "rubicon", title: "Rubicon", subtitle: "Legal border of Caesar's command", x: 0.47, y: 0.38, color: .orange, icon: "flag.checkered"),
        HistoricalMapLocation(id: "ariminum", title: "Ariminum", subtitle: "First target after the crossing", x: 0.56, y: 0.42, color: .red, icon: "mappin.circle.fill"),
        HistoricalMapLocation(id: "rome", title: "Rome", subtitle: "Senate power center", x: 0.46, y: 0.75, color: .yellow, icon: "building.columns.fill")
    ]

    private var selectedInfo: HistoricalMapLocation {
        locations.first { $0.title == selectedLocation } ?? locations[1]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "map.fill")
                Text("Roman Republic, 49 BCE")
                Spacer()
                Text(decision == "Cross" ? "Point of no return" : "Political survival")
                    .font(.caption2.bold())
                    .foregroundStyle(decision == "Cross" ? .red : .blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((decision == "Cross" ? Color.red : Color.blue).opacity(0.14), in: Capsule())
            }
            .font(.caption.bold())
            .foregroundStyle(.orange)

            GeometryReader { proxy in
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.18, green: 0.41, blue: 0.48).opacity(colorScheme == .dark ? 0.55 : 0.34),
                                    Color(red: 0.96, green: 0.78, blue: 0.48).opacity(colorScheme == .dark ? 0.42 : 0.72)
                                ],
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            )
                        )
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.orange.opacity(0.25), lineWidth: 1))

                    senateTerritory(in: proxy.size)
                        .fill(Color.orange.opacity(colorScheme == .dark ? 0.18 : 0.24))
                    caesarTerritory(in: proxy.size)
                        .fill(Color.red.opacity(colorScheme == .dark ? 0.18 : 0.20))
                    italyShape(in: proxy.size)
                        .fill(Color(red: 0.86, green: 0.65, blue: 0.34).opacity(colorScheme == .dark ? 0.72 : 0.88))
                        .overlay(italyShape(in: proxy.size).stroke(Color.primary.opacity(0.16), lineWidth: 1))
                    adriaticShape(in: proxy.size)
                        .fill(Color.cyan.opacity(colorScheme == .dark ? 0.18 : 0.24))

                    rubiconRiver(in: proxy.size)
                        .stroke(Color.cyan.opacity(0.9), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5, 4]))
                    caesarRoute(in: proxy.size, progress: routeProgress)
                        .stroke(Color.red.opacity(0.92), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    caesarRoute(in: proxy.size, progress: routeProgress)
                        .stroke(Color.white.opacity(0.7), style: StrokeStyle(lineWidth: 1.3, lineCap: .round, lineJoin: .round, dash: [7, 7]))

                    territoryLabel("Caesar's command", x: 0.20, y: 0.21, color: .red, size: proxy.size)
                    territoryLabel("Senate-controlled Italy", x: 0.25, y: 0.72, color: .orange, size: proxy.size)
                    territoryLabel("Adriatic Sea", x: 0.78, y: 0.45, color: .cyan, size: proxy.size)

                    ForEach(locations) { location in
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                selectedLocation = location.title
                                if location.id == "rome" {
                                    routeProgress = 1
                                } else if location.id == "rubicon" {
                                    routeProgress = 0.5
                                } else if location.id == "ravenna" {
                                    routeProgress = 0.18
                                } else {
                                    routeProgress = 0.72
                                }
                            }
                        } label: {
                            VStack(spacing: 3) {
                                ZStack {
                                    Circle()
                                        .fill(location.title == selectedLocation ? location.color : Color(.systemBackground))
                                        .frame(width: location.title == selectedLocation ? 34 : 28, height: location.title == selectedLocation ? 34 : 28)
                                        .overlay(Circle().stroke(location.color.opacity(0.85), lineWidth: 2))
                                    Image(systemName: location.icon)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(location.title == selectedLocation ? .white : location.color)
                                }
                                Text(location.title)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(.thinMaterial, in: Capsule())
                            }
                        }
                        .buttonStyle(.plain)
                        .position(x: proxy.size.width * location.x, y: proxy.size.height * location.y)
                        .accessibilityLabel("\(location.title): \(location.subtitle)")
                        .accessibilityIdentifier("rubiconVisualPin_\(location.id)")
                    }
                }
            }
            .frame(height: 224)
            .accessibilityIdentifier("rubiconCampaignMap")

            HStack(spacing: 7) {
                ForEach(locations) { location in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                            select(location)
                        }
                    } label: {
                        Text(location.title)
                            .font(.caption2.bold())
                            .foregroundStyle(selectedLocation == location.title ? .white : location.color)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(selectedLocation == location.title ? location.color : location.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("rubiconMapPin_\(location.id)")
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: selectedInfo.icon)
                        .foregroundStyle(selectedInfo.color)
                        .frame(width: 20)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedInfo.title)
                            .font(.subheadline.bold())
                        Text(selectedInfo.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                HStack(spacing: 8) {
                    decisionButton("Cross", icon: "arrow.up.right.circle.fill", color: .red)
                    decisionButton("Turn back", icon: "arrow.uturn.backward.circle.fill", color: .blue)
                }

                Text(decision == "Cross" ? "Caesar marches with the 13th Legion. Rome sees this as civil war." : "Caesar obeys the Senate, but risks prosecution and the loss of his command.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("rubiconDecisionOutcome")
            }
            .padding(12)
            .background(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.05), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("rubiconCampaignMap")
    }

    private func decisionButton(_ title: String, icon: String, color: Color) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.24)) {
                decision = title
                routeProgress = title == "Cross" ? 1 : 0.42
                selectedLocation = title == "Cross" ? "Rome" : "Rubicon"
            }
        } label: {
            Label(title, systemImage: icon)
                .font(.caption.bold())
                .foregroundStyle(decision == title ? .white : color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(decision == title ? color : color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("rubiconDecision_\(title.replacingOccurrences(of: " ", with: ""))")
    }

    private func select(_ location: HistoricalMapLocation) {
        selectedLocation = location.title
        if location.id == "rome" {
            routeProgress = 1
        } else if location.id == "rubicon" {
            routeProgress = 0.5
        } else if location.id == "ravenna" {
            routeProgress = 0.18
        } else {
            routeProgress = 0.72
        }
    }

    private func territoryLabel(_ text: String, x: CGFloat, y: CGFloat, color: Color, size: CGSize) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.thinMaterial, in: Capsule())
            .position(x: size.width * x, y: size.height * y)
    }

    private func italyShape(in size: CGSize) -> Path {
        Path { path in
            path.move(to: CGPoint(x: size.width * 0.40, y: size.height * 0.14))
            path.addCurve(to: CGPoint(x: size.width * 0.58, y: size.height * 0.25), control1: CGPoint(x: size.width * 0.50, y: size.height * 0.09), control2: CGPoint(x: size.width * 0.58, y: size.height * 0.15))
            path.addCurve(to: CGPoint(x: size.width * 0.55, y: size.height * 0.47), control1: CGPoint(x: size.width * 0.61, y: size.height * 0.35), control2: CGPoint(x: size.width * 0.55, y: size.height * 0.39))
            path.addCurve(to: CGPoint(x: size.width * 0.64, y: size.height * 0.70), control1: CGPoint(x: size.width * 0.57, y: size.height * 0.57), control2: CGPoint(x: size.width * 0.64, y: size.height * 0.61))
            path.addCurve(to: CGPoint(x: size.width * 0.52, y: size.height * 0.86), control1: CGPoint(x: size.width * 0.65, y: size.height * 0.81), control2: CGPoint(x: size.width * 0.57, y: size.height * 0.88))
            path.addCurve(to: CGPoint(x: size.width * 0.43, y: size.height * 0.64), control1: CGPoint(x: size.width * 0.50, y: size.height * 0.75), control2: CGPoint(x: size.width * 0.43, y: size.height * 0.72))
            path.addCurve(to: CGPoint(x: size.width * 0.37, y: size.height * 0.39), control1: CGPoint(x: size.width * 0.42, y: size.height * 0.53), control2: CGPoint(x: size.width * 0.35, y: size.height * 0.48))
            path.addCurve(to: CGPoint(x: size.width * 0.40, y: size.height * 0.14), control1: CGPoint(x: size.width * 0.39, y: size.height * 0.29), control2: CGPoint(x: size.width * 0.34, y: size.height * 0.20))
            path.closeSubpath()
        }
    }

    private func adriaticShape(in size: CGSize) -> Path {
        Path { path in
            path.move(to: CGPoint(x: size.width * 0.62, y: size.height * 0.18))
            path.addCurve(to: CGPoint(x: size.width * 0.76, y: size.height * 0.68), control1: CGPoint(x: size.width * 0.74, y: size.height * 0.30), control2: CGPoint(x: size.width * 0.78, y: size.height * 0.50))
            path.addCurve(to: CGPoint(x: size.width * 0.65, y: size.height * 0.79), control1: CGPoint(x: size.width * 0.72, y: size.height * 0.75), control2: CGPoint(x: size.width * 0.68, y: size.height * 0.78))
            path.addCurve(to: CGPoint(x: size.width * 0.60, y: size.height * 0.32), control1: CGPoint(x: size.width * 0.68, y: size.height * 0.59), control2: CGPoint(x: size.width * 0.63, y: size.height * 0.42))
            path.closeSubpath()
        }
    }

    private func senateTerritory(in size: CGSize) -> Path {
        Path(ellipseIn: CGRect(x: size.width * 0.20, y: size.height * 0.48, width: size.width * 0.50, height: size.height * 0.40))
    }

    private func caesarTerritory(in size: CGSize) -> Path {
        Path(roundedRect: CGRect(x: size.width * 0.12, y: size.height * 0.08, width: size.width * 0.56, height: size.height * 0.27), cornerRadius: 28)
    }

    private func rubiconRiver(in size: CGSize) -> Path {
        Path { path in
            path.move(to: CGPoint(x: size.width * 0.34, y: size.height * 0.37))
            path.addCurve(to: CGPoint(x: size.width * 0.58, y: size.height * 0.40), control1: CGPoint(x: size.width * 0.42, y: size.height * 0.32), control2: CGPoint(x: size.width * 0.50, y: size.height * 0.43))
        }
    }

    private func caesarRoute(in size: CGSize, progress: Double) -> Path {
        let route = [
            CGPoint(x: size.width * 0.50, y: size.height * 0.26),
            CGPoint(x: size.width * 0.47, y: size.height * 0.38),
            CGPoint(x: size.width * 0.56, y: size.height * 0.42),
            CGPoint(x: size.width * 0.50, y: size.height * 0.58),
            CGPoint(x: size.width * 0.46, y: size.height * 0.75)
        ]
        let clampedProgress = min(max(progress, 0), 1)
        let targetIndex = max(1, Int(ceil(Double(route.count - 1) * clampedProgress)))
        return Path { path in
            path.move(to: route[0])
            for point in route[1...targetIndex] {
                path.addLine(to: point)
            }
        }
    }
}

private struct HistoricalMapLocation: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let icon: String
}

// MARK: - History World Selection
struct HistoryWorldView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        let worlds = store.stats.selectedSubject.worlds
        let xp = store.stats.xp
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Worlds", systemImage: "globe")
                        .font(.headline)
                    Spacer()
                    Text("\(store.stats.selectedSubject.unlockedWorldCount(withXP: xp))/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if store.currentWorld?.id == "ancient-rome" {
                    RubiconCampaignMapView()
                } else {
                    SubjectMapPreview(subject: .history, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                        store.select(worldId: world.id, for: .history)
                    }
                }

                NextWorldUnlockView(subject: .history, xp: xp)

                ForEach(worlds) { world in
                    let locked = world.unlockRequirement.xpRequired.map { store.stats.xp < $0 } ?? false
                    let selected = store.currentWorld?.id == world.id
                    Button {
                        if !locked {
                            store.select(worldId: world.id, for: .history)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(world.emoji)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(world.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(locked ? .secondary : .primary)
                                Text(world.era)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if locked {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(world.unlockRequirement.xpRequired ?? 0) XP")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else if selected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(locked)
                    .accessibilityIdentifier("world_\(world.id)")
                }

                if let world = store.currentWorld {
                    Text(world.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .accessibilityIdentifier("historyWorldView")
    }
}

// MARK: - History Challenge View
struct HistoryChallengeView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedChoiceId: String? = nil
    @State private var showResult = false
    @State private var currentChallenge: HistoryChallenge? = nil

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Challenge", systemImage: "building.columns")
                        .font(.headline)
                    Spacer()
                    if let challenge = currentChallenge {
                        Text("\(challenge.year > 0 ? "CE" : "BCE") \(abs(challenge.year))")
                            .font(.caption.bold())
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                if let challenge = currentChallenge {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(challenge.question)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)

                        Text(challenge.context)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)

                        if showResult, let choice = challenge.choices.first(where: { $0.id == selectedChoiceId }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: choice.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                    Text(choice.isCorrect ? "Correct!" : "Not quite")
                                        .font(.headline)
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                }
                                Text(choice.consequence)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Text(choice.historicalOutcome)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .italic()
                                Text(challenge.historicalFact)
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                    .padding(.top, 4)
                                Text("Source: \(challenge.sourceCitation)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 2)
                            }
                            .padding(12)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if !showResult {
                            ForEach(challenge.choices, id: \.id) { choice in
                                Button {
                                    withAnimation {
                                        selectedChoiceId = choice.id
                                        showResult = true
                                        store.submitHistoryAnswer(challenge: challenge, choice: choice)
                                    }
                                } label: {
                                    HStack {
                                        Text(choice.text)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.primary.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("historyChoice_\(choice.id)")
                            }
                        } else {
                            Button("Next Challenge") {
                                withAnimation {
                                    selectedChoiceId = nil
                                    showResult = false
                                    loadNextChallenge()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            .accessibilityIdentifier("nextHistoryChallenge")
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("🎉 World Complete!")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("You've explored all available challenges in this world. More coming soon!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                }
            }
        }
        .onAppear { loadNextChallenge() }
        .onChange(of: store.stats.selectedSubject) { _, _ in loadNextChallenge() }
        .accessibilityIdentifier("historyChallengeView")
    }

    private func loadNextChallenge() {
        currentChallenge = store.nextHistoryChallenge
    }
}

// MARK: - Science World Selection
struct ScienceWorldView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        let worlds = store.stats.selectedSubject.worlds
        let xp = store.stats.xp
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Worlds", systemImage: "atom")
                        .font(.headline)
                    Spacer()
                    Text("\(store.stats.selectedSubject.unlockedWorldCount(withXP: xp))/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SubjectMapPreview(subject: .science, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                    store.select(worldId: world.id, for: .science)
                }

                NextWorldUnlockView(subject: .science, xp: xp)

                ForEach(worlds) { world in
                    let locked = world.unlockRequirement.xpRequired.map { store.stats.xp < $0 } ?? false
                    let selected = store.currentWorld?.id == world.id
                    Button {
                        if !locked {
                            store.select(worldId: world.id, for: .science)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(world.emoji)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(world.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(locked ? .secondary : .primary)
                                Text(world.era)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if locked {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(world.unlockRequirement.xpRequired ?? 0) XP")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else if selected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(locked)
                    .accessibilityIdentifier("scienceWorld_\(world.id)")
                }

                if let world = store.currentWorld {
                    Text(world.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .accessibilityIdentifier("scienceWorldView")
    }
}

// MARK: - Science Challenge View
struct ScienceChallengeView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedChoiceId: String? = nil
    @State private var showResult = false
    @State private var currentChallenge: ScienceChallenge? = nil
    @State private var animateSuccess = false

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Mission", systemImage: "atom")
                        .font(.headline)
                    Spacer()
                    if let challenge = currentChallenge {
                        Text(challenge.field)
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                if let challenge = currentChallenge {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(challenge.question)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)

                        Text(challenge.context)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)

                        if showResult, let choice = challenge.choices.first(where: { $0.id == selectedChoiceId }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: choice.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                    Text(choice.isCorrect ? "Correct!" : "Not quite")
                                        .font(.headline)
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                }
                                Text(choice.explanation)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Text(challenge.funFact)
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                    .padding(.top, 4)
                            }
                            .padding(12)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(choice.isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }

                        if !showResult {
                            ForEach(challenge.choices, id: \.id) { choice in
                                Button {
                                    withAnimation {
                                        selectedChoiceId = choice.id
                                        showResult = true
                                        store.submitScienceAnswer(challenge: challenge, choice: choice)
                                    }
                                } label: {
                                    HStack {
                                        Text(choice.text)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.primary.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("scienceChoice_\(choice.id)")
                            }
                        } else {
                            Button("Next Mission") {
                                withAnimation {
                                    selectedChoiceId = nil
                                    showResult = false
                                    loadNextChallenge()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .accessibilityIdentifier("nextScienceChallenge")
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("🚀 Mission Complete!")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("You've completed all available missions in this world. More science challenges coming soon!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                }
            }
        }
        .onAppear { loadNextChallenge() }
        .onChange(of: store.stats.selectedSubject) { _, _ in loadNextChallenge() }
        .accessibilityIdentifier("scienceChallengeView")
    }

    private func loadNextChallenge() {
        currentChallenge = store.nextScienceChallenge
    }
}

// MARK: - Geography World Selection
struct GeographyWorldView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        let worlds = store.stats.selectedSubject.worlds
        let xp = store.stats.xp
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Map Worlds", systemImage: "map")
                        .font(.headline)
                    Spacer()
                    Text("\(store.stats.selectedSubject.unlockedWorldCount(withXP: xp))/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SubjectMapPreview(subject: .geography, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                    store.select(worldId: world.id, for: .geography)
                }

                NextWorldUnlockView(subject: .geography, xp: xp)

                ForEach(worlds) { world in
                    let locked = world.unlockRequirement.xpRequired.map { store.stats.xp < $0 } ?? false
                    let selected = store.currentWorld?.id == world.id
                    Button {
                        if !locked {
                            store.select(worldId: world.id, for: .geography)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(world.emoji)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(world.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(locked ? .secondary : .primary)
                                Text(world.era)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if locked {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(world.unlockRequirement.xpRequired ?? 0) XP")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else if selected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.cyan)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(locked)
                    .accessibilityIdentifier("geographyWorld_\(world.id)")
                }

                if let world = store.currentWorld {
                    Text(world.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .accessibilityIdentifier("geographyWorldView")
    }
}

// MARK: - Geography Challenge View
struct GeographyChallengeView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedChoiceId: String? = nil
    @State private var showResult = false
    @State private var currentChallenge: GeographyChallenge? = nil

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Route", systemImage: "location.north.line")
                        .font(.headline)
                    Spacer()
                    if let challenge = currentChallenge {
                        Text(challenge.region)
                            .font(.caption.bold())
                            .foregroundStyle(.cyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.cyan.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                if let challenge = currentChallenge {
                    VStack(alignment: .leading, spacing: 10) {
                        GeographyMiniMapView(challenge: challenge)

                        Text(challenge.question)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)

                        Text(challenge.context)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)

                        if showResult, let choice = challenge.choices.first(where: { $0.id == selectedChoiceId }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: choice.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                    Text(choice.isCorrect ? "Route found!" : "Wrong turn")
                                        .font(.headline)
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                }
                                Text(choice.explanation)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Text(challenge.fieldNote)
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                    .padding(.top, 4)
                            }
                            .padding(12)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(choice.isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                            )
                            .accessibilityIdentifier("geographyResult")
                        }

                        if !showResult {
                            ForEach(challenge.choices, id: \.id) { choice in
                                Button {
                                    withAnimation {
                                        selectedChoiceId = choice.id
                                        showResult = true
                                        store.submitGeographyAnswer(challenge: challenge, choice: choice)
                                    }
                                } label: {
                                    HStack {
                                        Text(choice.text)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.primary.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("geographyChoice_\(choice.id)")
                            }
                        } else {
                            Button("Next Route") {
                                withAnimation {
                                    selectedChoiceId = nil
                                    showResult = false
                                    loadNextChallenge()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.cyan)
                            .accessibilityIdentifier("nextGeographyChallenge")
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("🗺️ Route Complete!")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("You've mapped every available stop in this world. More geography routes coming soon!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                }
            }
        }
        .onAppear { loadNextChallenge() }
        .onChange(of: store.stats.selectedSubject) { _, _ in loadNextChallenge() }
        .accessibilityIdentifier("geographyChallengeView")
    }

    private func loadNextChallenge() {
        currentChallenge = store.nextGeographyChallenge
    }
}

struct GeographyMiniMapView: View {
    let challenge: GeographyChallenge

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: [Color.cyan.opacity(0.22), Color.blue.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))

                GeometryReader { proxy in
                    let size = proxy.size
                    let start = CGPoint(x: size.width * challenge.mapStartX, y: size.height * challenge.mapStartY)
                    let target = CGPoint(x: size.width * challenge.mapTargetX, y: size.height * challenge.mapTargetY)

                    ZStack {
                        MiniMapLandmass(x: 0.48, y: 0.48, width: 0.38, height: 0.44, rotation: -8)
                        MiniMapLandmass(x: 0.25, y: 0.48, width: 0.18, height: 0.26, rotation: 14)
                        MiniMapLandmass(x: 0.68, y: 0.40, width: 0.25, height: 0.32, rotation: 10)
                        MiniMapLandmass(x: 0.66, y: 0.68, width: 0.17, height: 0.22, rotation: -12)

                        Path { path in
                            path.move(to: start)
                            path.addQuadCurve(
                                to: target,
                                control: CGPoint(x: (start.x + target.x) / 2, y: min(start.y, target.y) - 26)
                            )
                        }
                        .stroke(Color.white.opacity(0.95), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [7, 7]))

                        MapPin(point: start, color: .white, systemImage: "location.fill")
                        MapPin(point: target, color: .cyan, systemImage: "mappin.circle.fill")

                        VStack(spacing: 2) {
                            Text("Find")
                                .font(.caption2.bold())
                                .foregroundStyle(.secondary)
                            Text(challenge.mapTargetLabel)
                                .font(.caption.bold())
                                .foregroundStyle(.primary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .position(x: min(max(target.x + 44, 58), size.width - 58), y: max(target.y - 26, 24))
                    }
                }
                .padding(12)
            }
            .frame(height: 140)

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "map.fill")
                    .font(.title3)
                    .foregroundStyle(.cyan)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Map clue")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("geographyMapClue")
                    Text(challenge.mapClue)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(12)
        .background(Color.cyan.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.cyan.opacity(0.16), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Map mission: find \(challenge.mapTargetLabel)")
        .accessibilityIdentifier("geographyMiniMap")
    }
}

private struct MiniMapLandmass: View {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let rotation: Double

    var body: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(Color.green.opacity(0.26))
                .overlay(Capsule().stroke(Color.green.opacity(0.34), lineWidth: 1))
                .frame(width: proxy.size.width * width, height: proxy.size.height * height)
                .rotationEffect(.degrees(rotation))
                .position(x: proxy.size.width * x, y: proxy.size.height * y)
        }
    }
}

private struct MapPin: View {
    let point: CGPoint
    let color: Color
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 24, weight: .black))
            .foregroundStyle(color)
            .shadow(color: .black.opacity(0.14), radius: 4, y: 2)
            .position(point)
    }
}

// MARK: - Math World Selection
struct MathWorldView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        let worlds = store.stats.selectedSubject.worlds
        let xp = store.stats.xp
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Puzzle Worlds", systemImage: "function")
                        .font(.headline)
                    Spacer()
                    Text("\(store.stats.selectedSubject.unlockedWorldCount(withXP: xp))/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SubjectMapPreview(subject: .math, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                    store.select(worldId: world.id, for: .math)
                }

                NextWorldUnlockView(subject: .math, xp: xp)

                ForEach(worlds) { world in
                    let locked = world.unlockRequirement.xpRequired.map { store.stats.xp < $0 } ?? false
                    let selected = store.currentWorld?.id == world.id
                    Button {
                        if !locked {
                            store.select(worldId: world.id, for: .math)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(world.emoji)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(world.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(locked ? .secondary : .primary)
                                Text(world.era)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if locked {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(world.unlockRequirement.xpRequired ?? 0) XP")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else if selected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.purple)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(locked)
                    .accessibilityIdentifier("mathWorld_\(world.id)")
                }

                if let world = store.currentWorld {
                    Text(world.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .accessibilityIdentifier("mathWorldView")
    }
}

// MARK: - Math Challenge View
struct MathChallengeView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedChoiceId: String? = nil
    @State private var showResult = false
    @State private var currentChallenge: MathChallenge? = nil

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Puzzle", systemImage: "function")
                        .font(.headline)
                    Spacer()
                    if let challenge = currentChallenge {
                        Text(challenge.domain)
                            .font(.caption.bold())
                            .foregroundStyle(.purple)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                if let challenge = currentChallenge {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "sparkle.magnifyingglass")
                                .font(.title2)
                                .foregroundStyle(.purple)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Pattern clue")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                    .accessibilityIdentifier("mathPatternClue")
                                Text(challenge.patternClue)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(12)
                        .background(Color.purple.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text(challenge.question)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)

                        Text(challenge.context)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)

                        if showResult, let choice = challenge.choices.first(where: { $0.id == selectedChoiceId }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: choice.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                    Text(choice.isCorrect ? "Gate opened!" : "Gate resisted")
                                        .font(.headline)
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                }
                                Text(choice.explanation)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Text(challenge.ruleExplanation)
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                    .padding(.top, 4)
                            }
                            .padding(12)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(choice.isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                            )
                            .accessibilityIdentifier("mathResult")
                        }

                        if !showResult {
                            ForEach(challenge.choices, id: \.id) { choice in
                                Button {
                                    withAnimation {
                                        selectedChoiceId = choice.id
                                        showResult = true
                                        store.submitMathAnswer(challenge: challenge, choice: choice)
                                    }
                                } label: {
                                    HStack {
                                        Text(choice.text)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.primary.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("mathChoice_\(choice.id)")
                            }
                        } else {
                            Button("Next Puzzle") {
                                withAnimation {
                                    selectedChoiceId = nil
                                    showResult = false
                                    loadNextChallenge()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                            .accessibilityIdentifier("nextMathChallenge")
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("🔢 Vault Complete!")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("You've solved every available puzzle in this world. More math gates coming soon!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                }
            }
        }
        .onAppear { loadNextChallenge() }
        .onChange(of: store.stats.selectedSubject) { _, _ in loadNextChallenge() }
        .accessibilityIdentifier("mathChallengeView")
    }

    private func loadNextChallenge() {
        currentChallenge = store.nextMathChallenge
    }
}

// MARK: - Culture World Selection
struct CultureWorldView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        let worlds = store.stats.selectedSubject.worlds
        let xp = store.stats.xp
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Culture Worlds", systemImage: "theatermasks")
                        .font(.headline)
                    Spacer()
                    Text("\(store.stats.selectedSubject.unlockedWorldCount(withXP: xp))/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SubjectMapPreview(subject: .culture, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                    store.select(worldId: world.id, for: .culture)
                }

                NextWorldUnlockView(subject: .culture, xp: xp)

                ForEach(worlds) { world in
                    let locked = world.unlockRequirement.xpRequired.map { store.stats.xp < $0 } ?? false
                    let selected = store.currentWorld?.id == world.id
                    Button {
                        if !locked {
                            store.select(worldId: world.id, for: .culture)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(world.emoji)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(world.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(locked ? .secondary : .primary)
                                Text(world.era)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if locked {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(world.unlockRequirement.xpRequired ?? 0) XP")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else if selected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.pink)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(locked)
                    .accessibilityIdentifier("cultureWorld_\(world.id)")
                }

                if let world = store.currentWorld {
                    Text(world.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .accessibilityIdentifier("cultureWorldView")
    }
}

// MARK: - Culture Challenge View
struct CultureChallengeView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedChoiceId: String? = nil
    @State private var showResult = false
    @State private var currentChallenge: CultureChallenge? = nil

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Story", systemImage: "fork.knife.circle")
                        .font(.headline)
                    Spacer()
                    if let challenge = currentChallenge {
                        Text(challenge.region)
                            .font(.caption.bold())
                            .foregroundStyle(.pink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.pink.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                if let challenge = currentChallenge {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "quote.bubble.fill")
                                .font(.title2)
                                .foregroundStyle(.pink)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Tradition clue")
                                    .font(.caption.bold())
                                    .foregroundStyle(.primary.opacity(0.65))
                                    .accessibilityIdentifier("cultureTraditionClue")
                                Text(challenge.traditionClue)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(12)
                        .background(Color.pink.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text(challenge.question)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)

                        Text(challenge.context)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)

                        if showResult, let choice = challenge.choices.first(where: { $0.id == selectedChoiceId }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: choice.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                    Text(choice.isCorrect ? "Tradition unlocked!" : "Context missed")
                                        .font(.headline)
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                }
                                Text(choice.explanation)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Text(challenge.culturalNote)
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                    .padding(.top, 4)
                            }
                            .padding(12)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(choice.isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                            )
                            .accessibilityIdentifier("cultureResult")
                        }

                        if !showResult {
                            ForEach(challenge.choices, id: \.id) { choice in
                                Button {
                                    withAnimation {
                                        selectedChoiceId = choice.id
                                        showResult = true
                                        store.submitCultureAnswer(challenge: challenge, choice: choice)
                                    }
                                } label: {
                                    HStack {
                                        Text(choice.text)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.primary.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("cultureChoice_\(choice.id)")
                            }
                        } else {
                            Button("Next Story") {
                                withAnimation {
                                    selectedChoiceId = nil
                                    showResult = false
                                    loadNextChallenge()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.pink)
                            .accessibilityIdentifier("nextCultureChallenge")
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("🎭 Journey Complete!")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("You've explored every available tradition in this world. More culture stories coming soon!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                }
            }
        }
        .onAppear { loadNextChallenge() }
        .onChange(of: store.stats.selectedSubject) { _, _ in loadNextChallenge() }
        .accessibilityIdentifier("cultureChallengeView")
    }

    private func loadNextChallenge() {
        currentChallenge = store.nextCultureChallenge
    }
}

// MARK: - Business World Selection
struct BusinessWorldView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        let worlds = store.stats.selectedSubject.worlds
        let xp = store.stats.xp
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Market Worlds", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.headline)
                    Spacer()
                    Text("\(store.stats.selectedSubject.unlockedWorldCount(withXP: xp))/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SubjectMapPreview(subject: .business, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                    store.select(worldId: world.id, for: .business)
                }

                NextWorldUnlockView(subject: .business, xp: xp)

                ForEach(worlds) { world in
                    let locked = world.unlockRequirement.xpRequired.map { store.stats.xp < $0 } ?? false
                    let selected = store.currentWorld?.id == world.id
                    Button {
                        if !locked {
                            store.select(worldId: world.id, for: .business)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(world.emoji)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(world.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(locked ? .secondary : .primary)
                                Text(world.era)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if locked {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(world.unlockRequirement.xpRequired ?? 0) XP")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else if selected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.indigo)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(locked)
                    .accessibilityIdentifier("businessWorld_\(world.id)")
                }

                if let world = store.currentWorld {
                    Text(world.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .accessibilityIdentifier("businessWorldView")
    }
}

// MARK: - Business Challenge View
struct BusinessChallengeView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedChoiceId: String? = nil
    @State private var showResult = false
    @State private var currentChallenge: BusinessChallenge? = nil

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Decision", systemImage: "briefcase.fill")
                        .font(.headline)
                    Spacer()
                    if let challenge = currentChallenge {
                        Text(challenge.domain)
                            .font(.caption.bold())
                            .foregroundStyle(.indigo)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.indigo.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                if let challenge = currentChallenge {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "waveform.path.ecg.rectangle")
                                .font(.title2)
                                .foregroundStyle(.indigo)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Market signal")
                                    .font(.caption.bold())
                                    .foregroundStyle(.primary.opacity(0.65))
                                    .accessibilityIdentifier("businessMarketSignal")
                                Text(challenge.marketSignal)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(12)
                        .background(Color.indigo.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text(challenge.question)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)

                        Text(challenge.context)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)

                        if showResult, let choice = challenge.choices.first(where: { $0.id == selectedChoiceId }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: choice.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                    Text(choice.isCorrect ? "Smart move!" : "Costly move")
                                        .font(.headline)
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                }
                                Text(choice.explanation)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Text(challenge.lesson)
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                    .padding(.top, 4)
                            }
                            .padding(12)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(choice.isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                            )
                            .accessibilityIdentifier("businessResult")
                        }

                        if !showResult {
                            ForEach(challenge.choices, id: \.id) { choice in
                                Button {
                                    withAnimation {
                                        selectedChoiceId = choice.id
                                        showResult = true
                                        store.submitBusinessAnswer(challenge: challenge, choice: choice)
                                    }
                                } label: {
                                    HStack {
                                        Text(choice.text)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.primary.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("businessChoice_\(choice.id)")
                            }
                        } else {
                            Button("Next Deal") {
                                withAnimation {
                                    selectedChoiceId = nil
                                    showResult = false
                                    loadNextChallenge()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.indigo)
                            .accessibilityIdentifier("nextBusinessChallenge")
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("📈 Deal Board Complete!")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("You've handled every available decision in this world. More business scenarios coming soon!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                }
            }
        }
        .onAppear { loadNextChallenge() }
        .onChange(of: store.stats.selectedSubject) { _, _ in loadNextChallenge() }
        .accessibilityIdentifier("businessChallengeView")
    }

    private func loadNextChallenge() {
        currentChallenge = store.nextBusinessChallenge
    }
}

// MARK: - Health World Selection
struct HealthWorldView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        let worlds = store.stats.selectedSubject.worlds
        let xp = store.stats.xp
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Wellbeing Worlds", systemImage: "heart.text.square")
                        .font(.headline)
                    Spacer()
                    Text("\(store.stats.selectedSubject.unlockedWorldCount(withXP: xp))/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SubjectMapPreview(subject: .health, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                    store.select(worldId: world.id, for: .health)
                }

                NextWorldUnlockView(subject: .health, xp: xp)

                ForEach(worlds) { world in
                    let locked = world.unlockRequirement.xpRequired.map { store.stats.xp < $0 } ?? false
                    let selected = store.currentWorld?.id == world.id
                    Button {
                        if !locked {
                            store.select(worldId: world.id, for: .health)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Text(world.emoji)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(world.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(locked ? .secondary : .primary)
                                Text(world.era)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if locked {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(world.unlockRequirement.xpRequired ?? 0) XP")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else if selected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.mint)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(locked)
                    .accessibilityIdentifier("healthWorld_\(world.id)")
                }

                if let world = store.currentWorld {
                    Text(world.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .accessibilityIdentifier("healthWorldView")
    }
}

// MARK: - Health Challenge View
struct HealthChallengeView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedChoiceId: String? = nil
    @State private var showResult = false
    @State private var currentChallenge: HealthChallenge? = nil

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label("Habit Lab", systemImage: "heart.text.square.fill")
                        .font(.headline)
                    Spacer()
                    if let challenge = currentChallenge {
                        Text(challenge.domain)
                            .font(.caption.bold())
                            .foregroundStyle(.mint)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.mint.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                if let challenge = currentChallenge {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "waveform.path.ecg")
                                .font(.title2)
                                .foregroundStyle(.mint)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Body signal")
                                    .font(.caption.bold())
                                    .foregroundStyle(.primary.opacity(0.65))
                                    .accessibilityIdentifier("healthBodySignal")
                                Text(challenge.bodySignal)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(12)
                        .background(Color.mint.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Text(challenge.question)
                            .font(.title3.bold())
                            .foregroundStyle(.primary)

                        Text(challenge.context)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)

                        if showResult, let choice = challenge.choices.first(where: { $0.id == selectedChoiceId }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: choice.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                    Text(choice.isCorrect ? "Healthy move!" : "Needs a reset")
                                        .font(.headline)
                                        .foregroundStyle(choice.isCorrect ? .green : .red)
                                }
                                Text(choice.explanation)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Text(challenge.habitLesson)
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                    .padding(.top, 4)
                            }
                            .padding(12)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(choice.isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
                            )
                            .accessibilityIdentifier("healthResult")
                        }

                        if !showResult {
                            ForEach(challenge.choices, id: \.id) { choice in
                                Button {
                                    withAnimation {
                                        selectedChoiceId = choice.id
                                        showResult = true
                                        store.submitHealthAnswer(challenge: challenge, choice: choice)
                                    }
                                } label: {
                                    HStack {
                                        Text(choice.text)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.primary.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("healthChoice_\(choice.id)")
                            }
                        } else {
                            Button("Next Habit") {
                                withAnimation {
                                    selectedChoiceId = nil
                                    showResult = false
                                    loadNextChallenge()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.mint)
                            .accessibilityIdentifier("nextHealthChallenge")
                        }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("💚 Clinic Complete!")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                        Text("You've stabilized every habit system in this world. More wellbeing missions coming soon!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                }
            }
        }
        .onAppear { loadNextChallenge() }
        .onChange(of: store.stats.selectedSubject) { _, _ in loadNextChallenge() }
        .accessibilityIdentifier("healthChallengeView")
    }

    private func loadNextChallenge() {
        currentChallenge = store.nextHealthChallenge
    }
}

// MARK: - Coming Soon for other subjects
struct ComingSoonSubjectView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                Image(systemName: store.stats.selectedSubject.icon)
                    .font(.system(size: 56))
                    .foregroundStyle(store.stats.selectedSubject.accentColor)
                Text("\(store.stats.selectedSubject.displayName) Coming Soon")
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                Text("We're building amazing content for this subject. Switch to Languages, History, or Science to start learning now!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Switch Subject") {
                    store.stats.hasSeenSubjectPicker = false
                    store.save()
                }
                .buttonStyle(.borderedProminent)
                .tint(store.stats.selectedSubject.accentColor)
            }
            .padding(.vertical, 20)
        }
        .accessibilityIdentifier("comingSoonSubjectView")
    }
}

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @State private var step = ProcessInfo.processInfo.arguments.contains("--ui-testing-onboarding-pet-step") ? 5 : 0
    @State private var selectedSubject: Subject = .languages
    @State private var selectedPair: LanguagePair = LanguagePair.popularPairs[0]
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var selectedPet: PetType = .cat
    @State private var petName = "Mochi"
    @State private var animateEmoji = false
    @State private var didFinishOnboarding = false
    @FocusState private var isPetNameFocused: Bool

    private var totalSteps: Int { selectedSubject == .languages ? 6 : 4 }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                HStack(spacing: 4) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(i <= step ? Color.blue : Color.primary.opacity(0.1))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)

                // Step content
                TabView(selection: $step) {
                    WelcomeStep().tag(0)
                    FeaturesStep().tag(1)
                    SubjectStep(selectedSubject: $selectedSubject).tag(2)
                    if selectedSubject == .languages {
                        LanguagePairStep(selectedPair: $selectedPair).tag(3)
                        LevelStep(selectedLevel: $selectedLevel).tag(4)
                        PetStep(selectedPet: $selectedPet, petName: $petName, isNameFocused: $isPetNameFocused).tag(5)
                    } else {
                        PetStep(selectedPet: $selectedPet, petName: $petName, isNameFocused: $isPetNameFocused).tag(3)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: step)
                .animation(.easeInOut(duration: 0.3), value: selectedSubject)

                // Bottom buttons
                VStack(spacing: 12) {
                    PrimaryButton(title: step < totalSteps - 1 ? "Continue" : "Start Learning") {
                        handlePrimaryAction()
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        if step == totalSteps - 1 {
                            handlePrimaryAction()
                        }
                    })
                    .padding(.horizontal, 32)

                    if step > 0 {
                        Button("Back") {
                            withAnimation { step -= 1 }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .onChange(of: isPetNameFocused) { oldValue, newValue in
            if oldValue && !newValue && step == totalSteps - 1 {
                finishOnboarding()
            }
        }
        .onChange(of: selectedSubject) { _, _ in
            if step >= totalSteps {
                step = totalSteps - 1
            }
        }
    }

    private func handlePrimaryAction() {
        isPetNameFocused = false
        if step < totalSteps - 1 {
            withAnimation { step += 1 }
        } else {
            finishOnboarding()
        }
    }

    private func finishOnboarding() {
        guard !didFinishOnboarding else { return }
        didFinishOnboarding = true
        store.select(subject: selectedSubject)
        if selectedSubject == .languages {
            store.select(languagePair: selectedPair)
            store.select(level: selectedLevel)
        }

        var updatedStats = store.stats
        updatedStats.hasSeenTitle = true
        updatedStats.hasSkippedAuth = true
        updatedStats.hasSeenPetPicker = true
        updatedStats.hasSeenSubjectPicker = true
        updatedStats.selectedSubject = selectedSubject
        if selectedSubject == .languages {
            updatedStats.selectedLevel = selectedLevel
            updatedStats.selectedLanguagePair = selectedPair
        }
        updatedStats.pet.type = selectedPet
        updatedStats.pet.name = petName.isEmpty ? "Mochi" : petName
        store.stats = updatedStats
        store.save()
    }
}

// MARK: - Step 1: Welcome
struct WelcomeStep: View {
    @State private var showText = false
    @State private var showEmoji = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 180, height: 180)

                Text("🤯")
                    .font(.system(size: 80))
                    .scaleEffect(showEmoji ? 1 : 0.5)
                    .opacity(showEmoji ? 1 : 0)
            }

            VStack(spacing: 16) {
                Text("Ever struggled to learn something new?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 20)

                Text("Flashcards that bore you.\nApps that feel like homework.\nThings you forget the next day.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 20)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) { showEmoji = true }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) { showText = true }
        }
    }
}

// MARK: - Step 2: Features
struct FeaturesStep: View {
    @State private var showFeatures = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Not anymore.")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundStyle(.primary)

            Text("Meet QuestFlow")
                .font(.title2)
                .foregroundStyle(Color.blue)

            VStack(alignment: .leading, spacing: 20) {
                OnboardingFeatureRow(icon: "brain.head.profile", text: "Spaced repetition that actually works", detail: "Words come back right when you're about to forget them")
                OnboardingFeatureRow(icon: "mic.fill", text: "Speak your answers", detail: "Practice pronunciation with speech recognition")
                OnboardingFeatureRow(icon: "timer", text: "Pomodoro focus sessions", detail: "Stay in flow with built-in focus timer")
                OnboardingFeatureRow(icon: "heart.fill", text: "Your own learning pet", detail: "Keep them happy by practicing daily")
            }
            .padding(.horizontal, 32)
            .opacity(showFeatures ? 1 : 0)
            .offset(y: showFeatures ? 0 : 30)

            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) { showFeatures = true }
        }
    }
}

// MARK: - Step 3: Subject
struct SubjectStep: View {
    @Binding var selectedSubject: Subject

    var body: some View {
        VStack(spacing: 22) {
            Spacer().frame(height: 12)

            Text("What do you want to study first?")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .padding(.horizontal, 28)

            Text("Pick your first world. You can switch later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Subject.allCases) { subject in
                        let isSelected = selectedSubject == subject
                        Button {
                            withAnimation(.spring(duration: 0.3)) {
                                selectedSubject = subject
                            }
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(subject.accentColor.opacity(0.15))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: subject.icon)
                                        .font(.title3)
                                        .foregroundStyle(subject.accentColor)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(subject.displayName)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(subject.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(subject.accentColor)
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isSelected ? subject.accentColor.opacity(0.1) : Color.primary.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isSelected ? subject.accentColor.opacity(0.5) : Color.clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("onboardingSubject_\(subject.rawValue)")
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer().frame(height: 6)
        }
        .accessibilityIdentifier("onboardingSubjectStep")
    }
}

// MARK: - Step 4: Language Pair
struct LanguagePairStep: View {
    @Binding var selectedPair: LanguagePair

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Which languages?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text("Choose what you speak and what you want to learn.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(LanguagePair.allPairs) { pair in
                        LanguagePairCard(pair: pair, isSelected: selectedPair == pair) {
                            withAnimation(.spring(duration: 0.3)) {
                                selectedPair = pair
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()
        }
    }
}

struct LanguagePairCard: View {
    let pair: LanguagePair
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                HStack(spacing: -8) {
                    Text(pair.source.flag)
                        .font(.system(size: 36))
                    Text(pair.target.flag)
                        .font(.system(size: 36))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(pair.learningName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Tap to select")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.blue)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("languagePair_\(pair.id)")
    }
}

// MARK: - Step 5: CEFR Level
struct LevelStep: View {
    @Binding var selectedLevel: CEFRLevel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What's your level?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text("You can always change this later")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(CEFRLevel.allCases) { level in
                    LevelCard(level: level, isSelected: selectedLevel == level) {
                        withAnimation(.spring(duration: 0.3)) {
                            selectedLevel = level
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}

struct LevelCard: View {
    let level: CEFRLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(level.rawValue)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(isSelected ? Color.blue : Color.primary)
                    .frame(width: 56)

                VStack(alignment: .leading, spacing: 2) {
                    Text(level.subtitle)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(isSelected ? "Selected" : "Tap to select")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.blue)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 5: Pet Selection
struct PetStep: View {
    @Binding var selectedPet: PetType
    @Binding var petName: String
    var isNameFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Meet your learning companion")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .padding(.horizontal, 32)

            Text("Keep them happy by practicing daily!")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Pet selector
            HStack(spacing: 16) {
                ForEach(PetType.allCases) { pet in
                    PetButton(pet: pet, isSelected: selectedPet == pet) {
                        withAnimation(.spring(duration: 0.3)) {
                            selectedPet = pet
                        }
                    }
                }
            }

            // Selected pet preview
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 140, height: 140)

                Text(selectedPet.emoji)
                    .font(.system(size: 72))
            }
            .padding(.vertical, 8)

            // Pet name
            VStack(spacing: 8) {
                TextField("Name your pet...", text: $petName)
                    .textFieldStyle(.roundedBorder)
                    .focused(isNameFocused)
                    .padding(.horizontal, 48)

                Text("They'll evolve as you learn!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Pet stats preview
            HStack(spacing: 24) {
                PetStat(icon: "heart.fill", label: "Happiness", color: .red)
                PetStat(icon: "bolt.fill", label: "Energy", color: .yellow)
                PetStat(icon: "fork.knife", label: "Hunger", color: .orange)
            }
            .padding(.top, 8)

            Spacer()
        }
    }
}

struct PetButton: View {
    let pet: PetType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(pet.emoji)
                .font(.system(size: 36))
                .padding(12)
                .background(
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
}

struct PetStat: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Feature Row (shared)
struct OnboardingFeatureRow: View {
    let icon: String
    let text: String
    let detail: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.blue)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppStore())
}
import Foundation
import AuthenticationServices
import CryptoKit
