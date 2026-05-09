import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showPetPicker = false
    @State private var showLevelPicker = false
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            if !store.stats.hasSeenTitle { OnboardingView() }
            else if showPetPicker { PetPickerView { showPetPicker = false } }
            else if store.stats.selectedLevel == nil || showLevelPicker { LevelPickerView(onBack: { showLevelPicker = false }) }
            else { DashboardView(showLevelPicker: $showLevelPicker) }
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
    @State private var showGameOnboarding = false
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
    @Binding var showLevelPicker: Bool
    @State private var keyboardHeight: CGFloat = 0
    init(showLevelPicker: Binding<Bool> = .constant(false)) {
        _showLevelPicker = showLevelPicker
    }
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    Text("dashboardReady").font(.caption2).opacity(0.01).accessibilityIdentifier("dashboardReady")
                    header
                    PetView()
                    if let unlocked = store.newlyUnlockedLevel {
                        UnlockBanner(level: unlocked) { store.newlyUnlockedLevel = nil }
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
            Button { showLevelPicker = true } label: {
                Image(systemName: "arrow.up.arrow.down.circle.fill").font(.system(size: 28)).foregroundStyle(.primary.opacity(0.9))
            }.accessibilityIdentifier("levelSwitchButton")
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
                    Group {
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
                Text(store.stats.pet.emoji)
                    .font(.system(size: 44))
                    .accessibilityIdentifier("petEmoji")
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.stats.pet.name)
                        .font(.headline.bold())
                    Text("Lv. \(store.stats.pet.level)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text(store.stats.pet.emoji)
                        .font(.system(size: 80))
                    Text(store.stats.pet.name)
                        .font(.largeTitle.bold())
                    Text("Level \(store.stats.pet.level)")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 12) {
                        StatBar(label: "Happiness", value: store.stats.pet.happiness, color: .pink, icon: "heart.fill")
                        StatBar(label: "Fullness", value: 1 - store.stats.pet.hunger, color: .orange, icon: "fork.knife")
                        StatBar(label: "Energy", value: store.stats.pet.energy, color: .green, icon: "bolt.fill")
                    }
                    .padding(.horizontal)
                    
                    Text(store.stats.pet.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Total words fed: \(store.stats.pet.totalFed)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField("Rename pet...", text: $newName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
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
                .padding()
            }
            .navigationTitle("Your Pet")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
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
                Text("Choose Your Companion")
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
                                    .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.primary.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.1), lineWidth: isSelected ? 2 : 1)
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
                            .fill(i <= step ? Color.accentColor : Color.primary.opacity(0.1))
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
        store.stats.selectedLevel = selectedLevel
        store.stats.pet.type = selectedPet
        store.stats.pet.name = petName.isEmpty ? "Mochi" : petName
        store.stats.direction = selectedPair.source == .german ? .germanToSpanish : .spanishToGerman
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
                    .fill(Color.accentColor.opacity(0.1))
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
            
            Text("Meet LinguaFlow")
                .font(.title2)
                .foregroundStyle(.accent)
            
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "brain.head.profile", text: "Spaced repetition that actually works", detail: "Words come back right when you're about to forget them")
                FeatureRow(icon: "mic.fill", text: "Speak your answers", detail: "Practice pronunciation with speech recognition")
                FeatureRow(icon: "timer", text: "Pomodoro focus sessions", detail: "Stay in flow with built-in focus timer")
                FeatureRow(icon: "heart.fill", text: "Your own learning pet", detail: "Keep them happy by practicing daily")
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
                    ForEach(LanguagePair.popularPairs) { pair in
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
                    Text(pair.displayName)
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
                        .foregroundStyle(.accent)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
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
                    .foregroundStyle(isSelected ? .accent : .primary)
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
                        .foregroundStyle(.accent)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 2)
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
                    .fill(Color.accentColor.opacity(0.1))
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
                        .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
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
                .foregroundStyle(.accent)
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
