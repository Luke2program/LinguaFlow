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
