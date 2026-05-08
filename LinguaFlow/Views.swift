import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if !store.stats.hasSeenTitle { TitleScreenView() }
            else if store.stats.selectedLevel == nil { LevelPickerView() }
            else { DashboardView() }
        }
        .preferredColorScheme(.dark)
        .accessibilityIdentifier("rootView")
        .sheet(isPresented: $store.showingSettings) { SettingsView() }
    }
}

struct AppLogoView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(.white.opacity(0.25), lineWidth: 1.2))
            Text("💧").font(.system(size: 44))
        }
        .frame(width: 92, height: 92)
        .shadow(color: .white.opacity(0.08), radius: 20, y: 8)
        .accessibilityIdentifier("appLogo")
    }
}

struct GlassCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content.padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(.white.opacity(0.18), lineWidth: 1))
            .shadow(color: .black.opacity(0.35), radius: 20, x: 0, y: 10)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.headline.bold()).foregroundStyle(.black).frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon).font(.subheadline.bold()).foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(.white.opacity(0.18), lineWidth: 1))
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
                Text("LinguaFlow").font(.system(size: 48, weight: .black, design: .rounded)).foregroundStyle(.white)
                Text("Master German ↔ Spanish").font(.title3).foregroundStyle(.white.opacity(0.7))
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
            Image(systemName: icon).font(.title3).foregroundStyle(.white.opacity(0.8)).frame(width: 28)
            Text(text).font(.subheadline).foregroundStyle(.white.opacity(0.85))
            Spacer()
        }
    }
}

struct LevelPickerView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Choose your level").font(.largeTitle.bold()).foregroundStyle(.white).accessibilityIdentifier("chooseNiveauTitle")
                ForEach(CEFRLevel.allCases) { level in
                    let isUnlocked = store.stats.unlockedLevels.contains(level)
                    Button { if isUnlocked { store.select(level: level) } } label: {
                        GlassCard {
                            HStack(spacing: 16) {
                                Text(level.rawValue).font(.system(size: 32, weight: .black, design: .rounded)).foregroundStyle(isUnlocked ? .white : .white.opacity(0.35)).frame(width: 64)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(level.subtitle).font(.headline).foregroundStyle(isUnlocked ? .white : .white.opacity(0.35))
                                    Text(isUnlocked ? "Speaking-first vocabulary" : "Complete previous level to unlock").font(.caption).foregroundStyle(.white.opacity(isUnlocked ? 0.6 : 0.3))
                                }
                                Spacer()
                                Image(systemName: isUnlocked ? "chevron.right" : "lock.fill").font(.title3.bold()).foregroundStyle(.white.opacity(isUnlocked ? 0.5 : 0.25))
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
                Text("Today's Flow").font(.largeTitle.bold()).foregroundStyle(.white)
                Text("\(store.stats.selectedLevel?.rawValue ?? "") · \(store.dueCount) due · \(store.activeDirection.title) · \(store.challengeMode == .sentence ? "sentence" : "word")")
                    .font(.subheadline).foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
            Button { store.toggleDirection() } label: {
                Image(systemName: "shuffle.circle.fill").font(.system(size: 32)).foregroundStyle(.white.opacity(0.9))
            }.accessibilityIdentifier("directionToggle")
            Button { store.showingSettings = true } label: {
                Image(systemName: "gearshape.fill").font(.system(size: 28)).foregroundStyle(.white.opacity(0.9))
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
                Text("🎉 Level Unlocked").font(.headline).foregroundStyle(.white)
                Text("You mastered \(level.rawValue)!").font(.subheadline).foregroundStyle(.white.opacity(0.9))
                Button("Continue") { dismiss() }
                    .buttonStyle(.borderedProminent).tint(.green.opacity(0.7))
            }
        }
    }
}

struct FeedbackBanner: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.14), lineWidth: 1))
            .accessibilityIdentifier("answerFeedback")
    }
}

struct FluencyDropView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack { Text("Fluency").font(.headline).foregroundStyle(.white); Spacer(); Text("\(Int(store.realFluency * 100))%").bold().foregroundStyle(.white) }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.12))
                        Capsule().fill(.white.opacity(0.85)).frame(width: geo.size.width * store.realFluency)
                    }
                }.frame(height: 10)
                Text("\(store.masteredCount) of \(store.availableCards.count) words mastered · \(store.stats.streak > 1 ? "🔥 \(store.stats.streak)-day streak" : "Start a streak today.")")
                    .font(.caption).foregroundStyle(.white.opacity(0.6))
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
                Text("Date: \(store.stats.goalDate.formatted(date: .abbreviated, time: .omitted)) · Need: \(max(store.stats.dailyGoal, store.goalDailyNeed))/day · \(store.availableCards.count - store.masteredCount) words left")
                    .font(.caption).foregroundStyle(.white.opacity(0.55))
                TextField("Goal name", text: $goalName).textFieldStyle(.roundedBorder)
                DatePicker("Date", selection: $goalDate, displayedComponents: .date).foregroundStyle(.white)
                Stepper("Daily minimum: \(dailyGoal)", value: $dailyGoal, in: 5...80).foregroundStyle(.white)
                Button("Save goal") { store.updateGoal(name: goalName, date: goalDate, dailyGoal: dailyGoal) }
                    .buttonStyle(.borderedProminent).tint(.white.opacity(0.2)).accessibilityIdentifier("saveGoalButton")
            }.foregroundStyle(.white)
        }.onAppear { goalName = store.stats.goalName; goalDate = store.stats.goalDate; dailyGoal = store.stats.dailyGoal }
    }
}

struct ReviewCardView: View {
    @EnvironmentObject var store: AppStore
    @State private var typedAnswer = ""
    var body: some View {
        GlassCard {
            if store.currentCard != nil {
                VStack(spacing: 14) {
                    HStack {
                        Text(store.challengeMode == .sentence ? "SENTENCE" : "WORD").font(.caption2.bold()).foregroundStyle(.white.opacity(0.5))
                        Spacer()
                        Text("\(store.activeDirection.source.flag) → \(store.activeDirection.target.flag)").font(.title3)
                    }
                    Text(store.currentPrompt)
                        .font(.system(size: store.challengeMode == .sentence ? 24 : 38, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .accessibilityIdentifier("promptText")
                    Button { store.speakPrompt() } label: { Label("Hear it", systemImage: "speaker.wave.2.fill") }
                        .buttonStyle(.borderedProminent).tint(.white.opacity(0.15)).accessibilityIdentifier("audioPromptButton")
                    TextField("Type answer in \(store.activeDirection.target.name)…", text: $typedAnswer)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .foregroundStyle(.white)
                        .accessibilityIdentifier("answerInput")
                    HStack(spacing: 10) {
                        Button { check(typedAnswer) } label: { Label("Check", systemImage: "checkmark.circle.fill") }
                            .buttonStyle(.borderedProminent).tint(.green.opacity(0.6)).accessibilityIdentifier("checkAnswerButton")
                        Button { store.isListening ? store.stopSpeechInput() : store.startSpeechInput() } label: { Label(store.isListening ? "Stop" : "Speak", systemImage: store.isListening ? "mic.fill" : "mic.circle.fill") }
                            .buttonStyle(.borderedProminent).tint(.blue.opacity(0.55)).accessibilityIdentifier("speakAnswerButton")
                    }
                    Text(store.speechMessage).font(.caption).foregroundStyle(.white.opacity(0.6)).accessibilityIdentifier("speechStatus")
                    if !store.feedbackMessage.isEmpty {
                        Text(store.feedbackMessage)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(12)
                            .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(.white.opacity(0.15), lineWidth: 1))
                            .accessibilityIdentifier("inlineAnswerFeedback")
                    }
                    if !store.spokenTranscript.isEmpty {
                        Button("Use speech: \(store.spokenTranscript)") { check(store.spokenTranscript) }
                            .buttonStyle(.bordered).tint(.white.opacity(0.2)).accessibilityIdentifier("useSpeechButton")
                    }
                    Button("Show solution") { store.feedbackMessage = "Solution: \(store.currentAnswer)"; store.speakAnswer() }
                        .font(.caption.bold()).foregroundStyle(.white.opacity(0.6)).accessibilityIdentifier("showSolutionButton")
                    if store.combo > 2 { Text("Combo x\(store.combo) ⚡️").bold().foregroundStyle(.yellow) }
                }
                .onChange(of: store.currentCard?.id) { _, _ in typedAnswer = ""; store.spokenTranscript = "" }
            } else { Text("Choose a level to start.").foregroundStyle(.white) }
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
    @State private var work = 25
    @State private var pause = 5
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack { Label("Focus", systemImage: "timer").font(.headline); Spacer(); Text(store.pomodoroIsBreak ? "Break" : "Focus").bold() }
                Text(String(format: "%02d:%02d", store.pomodoroRemaining / 60, store.pomodoroRemaining % 60))
                    .font(.system(size: 40, weight: .black, design: .rounded))
                Stepper("Focus: \(work)m", value: $work, in: 5...60, step: 5)
                Stepper("Pause: \(pause)m", value: $pause, in: 1...20)
                HStack {
                    Button(store.pomodoroRunning ? "Pause" : "Start") { store.setPomodoro(work: work, pause: pause); store.togglePomodoro() }
                        .buttonStyle(.borderedProminent).tint(.white.opacity(0.2))
                    Button("Reset") { store.setPomodoro(work: work, pause: pause) }.buttonStyle(.bordered)
                }
            }.foregroundStyle(.white)
        }.onAppear { work = store.stats.workMinutes; pause = store.stats.breakMinutes }
    }
}

struct StatPill: View {
    let title: String; let value: String; let icon: String
    var body: some View {
        GlassCard {
            VStack(spacing: 5) {
                Image(systemName: icon).foregroundStyle(.white.opacity(0.8))
                Text(value).font(.title3.bold()).foregroundStyle(.white)
                Text(title).font(.caption).foregroundStyle(.white.opacity(0.5))
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
