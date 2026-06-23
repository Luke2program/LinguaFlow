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
        .accessibilityIdentifier("rootView")
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
                    ChallengeUITestControls()
                    DailyQuestView()
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

private struct ChallengeUITestControls: View {
    @EnvironmentObject var store: AppStore
    @State private var answeredHistory = false
    @State private var answeredScience = false
    @State private var answeredGeography = false
    @State private var answeredMath = false
    @State private var answeredCulture = false

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
                Text("What do you want to learn?")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text("Choose a subject. You can switch anytime.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
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
                    .accessibilityIdentifier("\(subject.rawValue)MapPreview")
            }
            .font(.caption.bold())
            .foregroundStyle(subject.accentColor)

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
        .accessibilityIdentifier("\(subject.rawValue)MapPreview")
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
                    Text("\(worlds.filter { $0.unlockRequirement.xpRequired.map { xp >= $0 } ?? true }.count)/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SubjectMapPreview(subject: .history, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                    store.select(worldId: world.id, for: .history)
                }
                
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
                    Text("\(worlds.filter { $0.unlockRequirement.xpRequired.map { xp >= $0 } ?? true }.count)/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SubjectMapPreview(subject: .science, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                    store.select(worldId: world.id, for: .science)
                }
                
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
                    Text("\(worlds.filter { $0.unlockRequirement.xpRequired.map { xp >= $0 } ?? true }.count)/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SubjectMapPreview(subject: .geography, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                    store.select(worldId: world.id, for: .geography)
                }

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
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "map.fill")
                                .font(.title2)
                                .foregroundStyle(.cyan)
                                .frame(width: 32)
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
                        .padding(12)
                        .background(Color.cyan.opacity(0.08))
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
                    Text("\(worlds.filter { $0.unlockRequirement.xpRequired.map { xp >= $0 } ?? true }.count)/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SubjectMapPreview(subject: .math, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                    store.select(worldId: world.id, for: .math)
                }

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
                    Text("\(worlds.filter { $0.unlockRequirement.xpRequired.map { xp >= $0 } ?? true }.count)/\(worlds.count) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                SubjectMapPreview(subject: .culture, worlds: worlds, selectedWorldId: store.currentWorld?.id, xp: xp) { world in
                    store.select(worldId: world.id, for: .culture)
                }

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

// MARK: - UnlockRequirement helper
extension UnlockRequirement {
    var xpRequired: Int? {
        switch self {
        case .none: return nil
        case .xpRequired(let x): return x
        }
    }
}

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @State private var step = 0
    @State private var selectedPair: LanguagePair = LanguagePair.popularPairs[0]
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var selectedPet: PetType = .cat
    @State private var petName = "Mochi"
    @State private var animateEmoji = false
    
    private let totalSteps = 5
    
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
                    LanguagePairStep(selectedPair: $selectedPair).tag(2)
                    LevelStep(selectedLevel: $selectedLevel).tag(3)
                    PetStep(selectedPet: $selectedPet, petName: $petName).tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: step)
                
                // Bottom buttons
                VStack(spacing: 12) {
                    PrimaryButton(title: step < totalSteps - 1 ? "Continue" : "Start Learning") {
                        if step < totalSteps - 1 {
                            withAnimation { step += 1 }
                        } else {
                            finishOnboarding()
                        }
                    }
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
    }
    
    private func finishOnboarding() {
        store.stats.hasSeenTitle = true
        store.stats.hasSeenPetPicker = true
        store.stats.hasSeenSubjectPicker = false
        store.stats.selectedLevel = selectedLevel
        store.stats.selectedLanguagePair = selectedPair
        store.stats.pet.type = selectedPet
        store.stats.pet.name = petName.isEmpty ? "Mochi" : petName
        store.select(languagePair: selectedPair)
        store.select(level: selectedLevel)
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
                Text("Ever struggled to learn a new language?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 20)
                
                Text("Flashcards that bore you.\nApps that feel like homework.\nWords you forget the next day.")
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

// MARK: - Step 3: Language Pair
struct LanguagePairStep: View {
    @Binding var selectedPair: LanguagePair
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("What do you want to learn?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
            
            Text("Choose your language pair")
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

// MARK: - Step 4: CEFR Level
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
    @FocusState private var isNameFocused: Bool
    
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
                    .focused($isNameFocused)
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
