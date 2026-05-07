import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        ZStack {
            LiquidBackground(dark: store.stats.darkMode)
            if !store.stats.hasSeenTitle { TitleScreenView() }
            else if store.stats.selectedLevel == nil { LevelPickerView() }
            else { DashboardView() }
        }
        .preferredColorScheme(store.stats.darkMode ? .dark : .light)
        .accessibilityIdentifier("rootView")
    }
}

struct AppLogoView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(LinearGradient(colors: [.cyan, .indigo, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle().fill(.white.opacity(0.25)).blur(radius: 6).offset(x: -20, y: -18)
            Text("LF").font(.system(size: 38, weight: .black, design: .rounded)).foregroundStyle(.white)
            Text("💧").font(.title).offset(x: 28, y: 28)
        }
        .frame(width: 96, height: 96)
        .shadow(color: .cyan.opacity(0.35), radius: 24, y: 12)
        .accessibilityIdentifier("appLogo")
    }
}

struct LiquidBackground: View {
    let dark: Bool
    var body: some View {
        LinearGradient(colors: dark ? [.black, .indigo.opacity(0.75), .cyan.opacity(0.35)] : [Color.indigo.opacity(0.95), Color.cyan.opacity(0.58), Color.orange.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay(Circle().fill(.white.opacity(dark ? 0.10 : 0.18)).blur(radius: 45).offset(x: -120, y: -260))
            .overlay(Circle().fill(.mint.opacity(0.24)).blur(radius: 55).offset(x: 150, y: 280))
            .overlay(.thinMaterial.opacity(dark ? 0.28 : 0.12))
    }
}

struct GlassCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content.padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(.white.opacity(0.32), lineWidth: 1))
            .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 14)
    }
}

struct TitleScreenView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            AppLogoView()
            Text("LinguaFlow").font(.system(size: 50, weight: .black, design: .rounded)).foregroundStyle(.white)
            Text("Speak German ↔ Spanish with typed answers, speech checks, sentence challenges, streaks, Pomodoro focus, and Anki-style memory.")
                .font(.headline).multilineTextAlignment(.center).foregroundStyle(.white.opacity(0.86)).padding(.horizontal)
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Write or speak every answer", systemImage: "keyboard")
                    Label("Auto-mixed directions and sentences", systemImage: "arrow.triangle.2.circlepath")
                    Label("Daily fluency goal tracking", systemImage: "target")
                }.foregroundStyle(.white).font(.subheadline.bold())
            }.padding(.horizontal)
            Button("Start learning") { store.finishTitle() }
                .font(.headline).buttonStyle(.borderedProminent).tint(.white.opacity(0.28)).accessibilityIdentifier("startLearningButton")
            Spacer()
        }.padding(20).accessibilityIdentifier("titleScreen")
    }
}

struct LevelPickerView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack { AppLogoView().scaleEffect(0.58).frame(width: 58, height: 58); Text("Choose your Niveau").font(.largeTitle.bold()).foregroundStyle(.white).accessibilityIdentifier("chooseNiveauTitle") }
                ForEach(CEFRLevel.allCases) { level in
                    Button { store.select(level: level) } label: {
                        GlassCard {
                            HStack(spacing: 16) {
                                Text(level.rawValue).font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(.white).frame(width: 70)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(level.subtitle).font(.headline).foregroundStyle(.white)
                                    Text("Unlocks all earlier levels · speaking-first vocabulary")
                                        .font(.caption).foregroundStyle(.white.opacity(0.76))
                                }
                                Spacer(); Image(systemName: "chevron.right.circle.fill").font(.title2).foregroundStyle(.white)
                            }
                        }
                    }.buttonStyle(.plain).accessibilityIdentifier("level_\(level.rawValue)")
                }
            }.padding(20).padding(.top, 30)
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Text("dashboardReady").font(.caption2).opacity(0.01).accessibilityIdentifier("dashboardReady")
                header
                if !store.feedbackMessage.isEmpty { FeedbackBanner(text: store.feedbackMessage) }
                FluencyDropView(progress: store.stats.fluency, streak: store.stats.streak)
                GoalView()
                ReviewCardView()
                PomodoroView()
                statsGrid
            }.padding(18)
        }.accessibilityIdentifier("dashboardView")
    }
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today’s Flow").font(.largeTitle.bold()).foregroundStyle(.white)
                Text("\(store.stats.selectedLevel?.rawValue ?? "") · \(store.dueCount) due · \(store.activeDirection.title) · \(store.challengeMode == .sentence ? "sentence" : "word")")
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Button { store.stats.darkMode.toggle() } label: { Image(systemName: store.stats.darkMode ? "moon.fill" : "sun.max.fill").font(.title2).foregroundStyle(.white) }.accessibilityIdentifier("darkModeToggle")
            Button { store.toggleDirection() } label: { Image(systemName: "shuffle.circle.fill").font(.system(size: 36)).foregroundStyle(.white) }.accessibilityIdentifier("directionToggle")
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

struct FeedbackBanner: View { let text: String; var body: some View { Text(text).font(.subheadline.bold()).foregroundStyle(.white).frame(maxWidth: .infinity, alignment: .leading).padding(14).background(.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 18)).accessibilityIdentifier("answerFeedback") } }

struct FluencyDropView: View {
    let progress: Double; let streak: Int
    var body: some View {
        GlassCard { VStack(alignment: .leading, spacing: 10) {
            HStack { Text("Fluency Drop").font(.headline).foregroundStyle(.white); Spacer(); Text("\(Int(progress * 100))%").bold().foregroundStyle(.white) }
            GeometryReader { geo in ZStack(alignment: .leading) { Capsule().fill(.white.opacity(0.18)); Capsule().fill(LinearGradient(colors: [.cyan, .mint, .white], startPoint: .leading, endPoint: .trailing)).frame(width: geo.size.width * progress) } }.frame(height: 16)
            Text(streak > 1 ? "🔥 \(streak)-day streak — keep the drop alive." : "Start a streak today. Five reviews is enough.").font(.caption).foregroundStyle(.white.opacity(0.82))
        }}.accessibilityIdentifier("fluencyDrop")
    }
}

struct GoalView: View {
    @EnvironmentObject var store: AppStore
    @State private var goalName = ""
    @State private var goalDate = Date()
    @State private var dailyGoal = 12
    var body: some View {
        GlassCard { VStack(alignment: .leading, spacing: 10) {
            HStack { Label("Fluency Goal", systemImage: "target").font(.headline); Spacer(); Text(store.learnedEnoughToday ? "On track ✅" : "\(max(store.stats.dailyGoal, store.goalDailyNeed) - store.stats.reviewedToday) left today") }
            Text(store.stats.goalName).font(.subheadline.bold())
            Text("Goal date: \(store.stats.goalDate.formatted(date: .abbreviated, time: .omitted)) · Daily need: \(max(store.stats.dailyGoal, store.goalDailyNeed)) reviews")
                .font(.caption).foregroundStyle(.white.opacity(0.78))
            TextField("Goal name", text: $goalName).textFieldStyle(.roundedBorder)
            DatePicker("Date", selection: $goalDate, displayedComponents: .date).foregroundStyle(.white)
            Stepper("Daily minimum: \(dailyGoal)", value: $dailyGoal, in: 5...80).foregroundStyle(.white)
            Button("Save goal") { store.updateGoal(name: goalName, date: goalDate, dailyGoal: dailyGoal) }.buttonStyle(.borderedProminent).tint(.white.opacity(0.25)).accessibilityIdentifier("saveGoalButton")
        }.foregroundStyle(.white) }.onAppear { goalName = store.stats.goalName; goalDate = store.stats.goalDate; dailyGoal = store.stats.dailyGoal }
    }
}

struct ReviewCardView: View {
    @EnvironmentObject var store: AppStore
    @State private var typedAnswer = ""
    var body: some View {
        GlassCard {
            if store.currentCard != nil {
                VStack(spacing: 14) {
                    HStack { Text(store.challengeMode == .sentence ? "SENTENCE CHALLENGE" : "WORD CHALLENGE").font(.caption.bold()).foregroundStyle(.white.opacity(0.72)); Spacer(); Text("\(store.activeDirection.source.flag) → \(store.activeDirection.target.flag)").font(.title3) }
                    Text(store.currentPrompt).font(.system(size: store.challengeMode == .sentence ? 27 : 42, weight: .black, design: .rounded)).foregroundStyle(.white).multilineTextAlignment(.center).minimumScaleFactor(0.5).accessibilityIdentifier("promptText")
                    Button { store.speakPrompt() } label: { Label("Hear prompt", systemImage: "speaker.wave.2.fill") }.buttonStyle(.borderedProminent).tint(.white.opacity(0.25)).accessibilityIdentifier("audioPromptButton")
                    TextField("Type the answer in \(store.activeDirection.target.name)…", text: $typedAnswer).textInputAutocapitalization(.never).autocorrectionDisabled().padding(14).background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 18, style: .continuous)).foregroundStyle(.white).accessibilityIdentifier("answerInput")
                    HStack(spacing: 10) {
                        Button { check(typedAnswer) } label: { Label("Check", systemImage: "checkmark.circle.fill") }.buttonStyle(.borderedProminent).tint(.green.opacity(0.75)).accessibilityIdentifier("checkAnswerButton")
                        Button { store.isListening ? store.stopSpeechInput() : store.startSpeechInput() } label: { Label(store.isListening ? "Stop" : "Speak", systemImage: store.isListening ? "mic.fill" : "mic.circle.fill") }.buttonStyle(.borderedProminent).tint(.blue.opacity(0.7)).accessibilityIdentifier("speakAnswerButton")
                    }
                    Text(store.speechMessage).font(.caption).foregroundStyle(.white.opacity(0.8)).accessibilityIdentifier("speechStatus")
                    if !store.spokenTranscript.isEmpty { Button("Use speech: \(store.spokenTranscript)") { check(store.spokenTranscript) }.buttonStyle(.bordered).tint(.white).accessibilityIdentifier("useSpeechButton") }
                    Button("Show solution") { store.feedbackMessage = "Solution: \(store.currentAnswer)"; store.speakAnswer() }.font(.caption.bold()).foregroundStyle(.white.opacity(0.78)).accessibilityIdentifier("showSolutionButton")
                    if store.combo > 2 { Text("Combo x\(store.combo) ⚡️").bold().foregroundStyle(.yellow) }
                }
                .onChange(of: store.currentCard?.id) { _, _ in typedAnswer = ""; store.spokenTranscript = "" }
            } else { Text("Choose a level to start.").foregroundStyle(.white) }
        }
    }
    private func check(_ answer: String) { _ = store.submit(answer: answer); typedAnswer = "" }
}

struct PomodoroView: View {
    @EnvironmentObject var store: AppStore
    @State private var work = 25
    @State private var pause = 5
    var body: some View {
        GlassCard { VStack(alignment: .leading, spacing: 10) {
            HStack { Label("Focus Pomodoro", systemImage: "timer").font(.headline); Spacer(); Text(store.pomodoroIsBreak ? "Break" : "Focus").bold() }
            Text(String(format: "%02d:%02d", store.pomodoroRemaining / 60, store.pomodoroRemaining % 60)).font(.system(size: 42, weight: .black, design: .rounded))
            Stepper("Focus: \(work)m", value: $work, in: 5...60, step: 5)
            Stepper("Pause: \(pause)m", value: $pause, in: 1...20)
            HStack { Button(store.pomodoroRunning ? "Pause" : "Start") { store.setPomodoro(work: work, pause: pause); store.togglePomodoro() }.buttonStyle(.borderedProminent).tint(.white.opacity(0.25)); Button("Reset") { store.setPomodoro(work: work, pause: pause) }.buttonStyle(.bordered) }
        }.foregroundStyle(.white) }.onAppear { work = store.stats.workMinutes; pause = store.stats.breakMinutes }
    }
}

struct StatPill: View {
    let title: String; let value: String; let icon: String
    var body: some View { GlassCard { VStack(spacing: 5) { Image(systemName: icon).foregroundStyle(.white); Text(value).font(.title3.bold()).foregroundStyle(.white); Text(title).font(.caption).foregroundStyle(.white.opacity(0.72)) } .frame(maxWidth: .infinity) } }
}

#Preview { RootView().environmentObject(AppStore()) }
