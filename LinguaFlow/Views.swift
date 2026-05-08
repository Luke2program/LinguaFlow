import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            if !store.stats.hasSeenTitle { TitleScreenView() }
            else if store.stats.selectedLevel == nil { LevelPickerView() }
            else { DashboardView() }
        }
        .preferredColorScheme(store.stats.darkMode ? .dark : nil)
        .accessibilityIdentifier("rootView")
        .sheet(isPresented: $store.showingSettings) { SettingsView() }
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
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            AppLogoView()
            VStack(spacing: 10) {
                Text("LinguaFlow").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.primary)
                Text("Master German ↔ Spanish").font(.title3).foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 14) {
                FeatureRow(icon: "keyboard", text: "Type or speak every answer")
                FeatureRow(icon: "arrow.triangle.2.circlepath", text: "Auto-mixed directions & sentences")
                FeatureRow(icon: "target", text: "Daily fluency goal tracking")
                FeatureRow(icon: "timer", text: "Built-in Pomodoro focus mode")
            }.padding(.horizontal, 32).padding(.vertical, 8)
            PrimaryButton(title: "Get Started") { store.finishTitle() }
                .padding(.horizontal, 32)
                .accessibilityIdentifier("startLearningButton")
            Spacer()
        }.accessibilityIdentifier("titleScreen")
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
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Choose your level").font(.largeTitle.bold()).foregroundStyle(.primary).accessibilityIdentifier("chooseNiveauTitle")
                ForEach(CEFRLevel.allCases) { level in
                    let isUnlocked = store.stats.unlockedLevels.contains(level)
                    Button { if isUnlocked { store.select(level: level) } } label: {
                        GlassCard {
                            HStack(spacing: 16) {
                                Text(level.rawValue).font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(isUnlocked ? .primary : .secondary).frame(width: 64)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(level.subtitle).font(.headline).foregroundStyle(isUnlocked ? .primary : .secondary)
                                    Text(isUnlocked ? "Speaking-first vocabulary" : "Complete previous level to unlock").font(.caption).foregroundStyle(.secondary.opacity(isUnlocked ? 0.8 : 0.5))
                                }
                                Spacer()
                                Image(systemName: isUnlocked ? "chevron.right" : "lock.fill").font(.title3.bold()).foregroundStyle(.secondary.opacity(isUnlocked ? 0.5 : 0.25))
                            }
                        }
                    }.buttonStyle(.plain).disabled(!isUnlocked).accessibilityIdentifier("level_\(level.rawValue)")
                }
            }.padding(20).padding(.top, 20)
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var store: AppStore
    @State private var keyboardHeight: CGFloat = 0
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    Text("dashboardReady").font(.caption2).opacity(0.01).accessibilityIdentifier("dashboardReady")
                    header
                    if let unlocked = store.newlyUnlockedLevel {
                        UnlockBanner(level: unlocked) { store.newlyUnlockedLevel = nil }
                    }
                    if !store.feedbackMessage.isEmpty {
                        FeedbackBanner(text: store.feedbackMessage)
                            .id("feedbackBanner")
                    }
                    FluencyDropView()
                    GoalView()
                    ReviewCardView()
                    PomodoroView()
                    statsGrid
                    Spacer().frame(height: keyboardHeight + 40)
                }.padding(18)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: store.feedbackMessage) { _, new in
                if !new.isEmpty {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("feedbackBanner", anchor: .top)
                    }
                }
            }
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
                Text("Today's Flow").font(.largeTitle.bold()).foregroundStyle(.primary)
                Text("\(store.stats.selectedLevel?.rawValue ?? "") · \(store.dueCount) due · \(store.activeDirection.title) · \(store.challengeMode == .sentence ? "sentence" : "word")")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Button { store.toggleDirection() } label: {
                Image(systemName: "shuffle.circle.fill").font(.system(size: 32)).foregroundStyle(.primary.opacity(0.9))
            }.accessibilityIdentifier("directionToggle")
            Button { store.showingSettings = true } label: {
                Image(systemName: "gearshape.fill").font(.system(size: 28)).foregroundStyle(.primary.opacity(0.9))
            }.accessibilityIdentifier("settingsButton")
        }
    }
    var statsGrid: some View {
        HStack(spacing: 10) {
            StatPill(title: "XP", value: "\(store.stats.xp)", icon: "sparkles")
            StatPill(title: "Streak", value: "\(store.stats.streak)", icon: "flame.fill")
            StatPill(title: "Gems", value: "\(store.stats.gems)", icon: "diamond.fill")
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
                        Capsule().fill(Color.accentColor.opacity(0.85)).frame(width: geo.size.width * store.realFluency)
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
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Prompt:").font(.caption).foregroundStyle(.secondary)
                        Text(store.currentPrompt).font(.title2.bold())
                        Button("Speak prompt") { store.speakPrompt() }.font(.caption)
                    }
                    TextField("Type your answer…", text: $typedAnswer)
                        .textFieldStyle(.roundedBorder)
                        .focused($isInputFocused)
                        .accessibilityIdentifier("answerTextField")
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
                    HStack(spacing: 10) {
                        ForEach(ReviewGrade.allCases) { grade in
                            Button(grade.title) { store.grade(grade, expected: store.currentAnswer) }
                                .buttonStyle(.bordered)
                                .tint(grade.color)
                        }
                    }
                    if store.combo > 2 { Text("Combo x\(store.combo) ⚡️").bold().foregroundStyle(.yellow) }
                }
                .onChange(of: store.currentCard?.id) { _, _ in typedAnswer = ""; store.spokenTranscript = "" }
            } else { Text("Choose a level to start.").foregroundStyle(.secondary) }
        }
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

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("Language Level") {
                    if !store.stats.unlockedLevels.isEmpty {
                        Picker("Current Level", selection: $store.stats.selectedLevel) {
                            ForEach(store.stats.unlockedLevels.sorted(by: { ($0.rawValue) < ($1.rawValue) })) { level in
                                Text(level.rawValue + " — " + level.subtitle)
                                    .tag(Optional(level))
                            }
                        }
                        .pickerStyle(.navigationLink)
                        .onChange(of: store.stats.selectedLevel) { _, newLevel in
                            if let level = newLevel {
                                for card in VocabularyData.cards where card.level <= level && store.schedules[card.id] == nil {
                                    store.schedules[card.id] = CardSchedule()
                                }
                                store.save()
                                store.pickNextCard()
                            }
                        }
                    } else {
                        Text("No levels unlocked yet")
                            .foregroundStyle(.secondary)
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
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
                Section("About") {
                    HStack { Text("Version"); Spacer(); Text("1.0").foregroundStyle(.secondary) }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { store.save(); dismiss() } } }
        }
    }
}

#Preview { RootView().environmentObject(AppStore()) }
