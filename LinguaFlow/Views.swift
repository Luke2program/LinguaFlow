import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        ZStack {
            LiquidBackground()
            if store.stats.selectedLevel == nil { LevelPickerView() } else { DashboardView() }
        }
        .accessibilityIdentifier("rootView")
    }
}

struct LiquidBackground: View {
    var body: some View {
        LinearGradient(colors: [Color.indigo.opacity(0.95), Color.cyan.opacity(0.55), Color.orange.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay(Circle().fill(.white.opacity(0.18)).blur(radius: 45).offset(x: -120, y: -260))
            .overlay(Circle().fill(.mint.opacity(0.24)).blur(radius: 55).offset(x: 150, y: 280))
    }
}

struct GlassCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content.padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(.white.opacity(0.28), lineWidth: 1))
            .shadow(color: .black.opacity(0.16), radius: 22, x: 0, y: 12)
    }
}

struct LevelPickerView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("LinguaFlow").font(.system(size: 44, weight: .black, design: .rounded)).foregroundStyle(.white)
                    Text("German ↔ Spanish that feels like a game and remembers exactly when you should review.")
                        .font(.headline).foregroundStyle(.white.opacity(0.86))
                }.padding(.top, 46)
                Text("Choose your Niveau").font(.title2.bold()).foregroundStyle(.white).accessibilityIdentifier("chooseNiveauTitle")
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
                                Spacer()
                                Image(systemName: "chevron.right.circle.fill").font(.title2).foregroundStyle(.white)
                            }
                        }
                    }.buttonStyle(.plain).accessibilityIdentifier("level_\(level.rawValue)")
                }
            }.padding(20)
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        VStack(spacing: 14) {
            Text("dashboardReady")
                .font(.caption2)
                .opacity(0.01)
                .accessibilityIdentifier("dashboardReady")
            header
            FluencyDropView(progress: store.stats.fluency, streak: store.stats.streak)
            ReviewCardView()
            statsGrid
            Spacer(minLength: 0)
        }
        .padding(18)
        .accessibilityIdentifier("dashboardView")
    }
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today’s Flow").font(.largeTitle.bold()).foregroundStyle(.white)
                Text("\(store.stats.selectedLevel?.rawValue ?? "") · \(store.dueCount) due · \(store.stats.direction.title)").foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Button { store.toggleDirection() } label: { Image(systemName: "arrow.left.arrow.right.circle.fill").font(.system(size: 36)).foregroundStyle(.white) }
                .accessibilityIdentifier("directionToggle")
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

struct FluencyDropView: View {
    let progress: Double
    let streak: Int
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack { Text("Fluency Drop").font(.headline).foregroundStyle(.white); Spacer(); Text("\(Int(progress * 100))%").bold().foregroundStyle(.white) }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(.white.opacity(0.18))
                        Capsule().fill(LinearGradient(colors: [.cyan, .mint, .white], startPoint: .leading, endPoint: .trailing)).frame(width: geo.size.width * progress)
                    }
                }.frame(height: 16)
                Text(streak > 1 ? "🔥 \(streak)-day streak — keep the drop alive." : "Start a streak today. Five reviews is enough.")
                    .font(.caption).foregroundStyle(.white.opacity(0.82))
            }
        }.accessibilityIdentifier("fluencyDrop")
    }
}

struct ReviewCardView: View {
    @EnvironmentObject var store: AppStore
    @State private var typedAnswer = ""
    @State private var feedback = ""

    var body: some View {
        GlassCard {
            if let card = store.currentCard {
                VStack(spacing: 16) {
                    HStack {
                        Text(card.category.uppercased()).font(.caption.bold()).foregroundStyle(.white.opacity(0.72))
                        Spacer(); Text(store.stats.direction.source.flag).font(.title)
                    }
                    Text(card.prompt(for: store.stats.direction))
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.55)
                        .accessibilityIdentifier("promptText")
                    Button { store.speakPrompt() } label: { Label("Hear prompt", systemImage: "speaker.wave.2.fill") }
                        .buttonStyle(.borderedProminent).tint(.white.opacity(0.25)).accessibilityIdentifier("audioPromptButton")

                    TextField("Type the answer in \(store.stats.direction.target.name)…", text: $typedAnswer)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .foregroundStyle(.white)
                        .accessibilityIdentifier("answerInput")

                    HStack(spacing: 10) {
                        Button { checkTypedAnswer() } label: { Label("Check", systemImage: "checkmark.circle.fill") }
                            .buttonStyle(.borderedProminent).tint(.green.opacity(0.75)).accessibilityIdentifier("checkAnswerButton")
                        Button { toggleSpeech(card: card) } label: { Label(store.isListening ? "Stop" : "Speak", systemImage: store.isListening ? "mic.fill" : "mic.circle.fill") }
                            .buttonStyle(.borderedProminent).tint(.blue.opacity(0.7)).accessibilityIdentifier("speakAnswerButton")
                    }
                    if !store.spokenTranscript.isEmpty {
                        Text("Heard: \(store.spokenTranscript)").font(.caption).foregroundStyle(.white.opacity(0.82)).accessibilityIdentifier("speechTranscript")
                    }
                    if !feedback.isEmpty { Text(feedback).bold().foregroundStyle(.white).accessibilityIdentifier("answerFeedback") }
                    Button("Show solution") { store.reveal(); feedback = "Solution: \(card.answer(for: store.stats.direction))" }
                        .font(.caption.bold()).foregroundStyle(.white.opacity(0.78)).accessibilityIdentifier("showSolutionButton")
                    if store.combo > 2 { Text("Combo x\(store.combo) ⚡️").bold().foregroundStyle(.yellow) }
                }
                .onChange(of: store.currentCard?.id) { _, _ in typedAnswer = ""; feedback = ""; store.spokenTranscript = "" }
            } else { Text("Choose a level to start.").foregroundStyle(.white) }
        }
    }

    private func checkTypedAnswer() {
        let result = store.submit(answer: typedAnswer)
        switch result {
        case .correct: feedback = "Perfect — fluency drop grew 💧"
        case .almost: feedback = "Almost. Counted as hard, review comes back sooner."
        case .wrong: feedback = "Not yet — it comes back in 10 minutes."
        }
        typedAnswer = ""
    }

    private func toggleSpeech(card: VocabularyCard) {
        if store.isListening {
            store.stopSpeechInput()
            typedAnswer = store.spokenTranscript
            checkTypedAnswer()
        } else { store.startSpeechInput() }
    }
}

struct StatPill: View {
    let title: String; let value: String; let icon: String
    var body: some View { GlassCard { VStack(spacing: 5) { Image(systemName: icon).foregroundStyle(.white); Text(value).font(.title3.bold()).foregroundStyle(.white); Text(title).font(.caption).foregroundStyle(.white.opacity(0.72)) } .frame(maxWidth: .infinity) } }
}

#Preview { RootView().environmentObject(AppStore()) }
