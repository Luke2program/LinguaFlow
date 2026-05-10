import Foundation
import SwiftUI

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case german = "de-DE"
    case spanish = "es-ES"
    case french = "fr-FR"
    case italian = "it-IT"
    case portuguese = "pt-PT"
    case dutch = "nl-NL"
    case polish = "pl-PL"
    case russian = "ru-RU"
    case english = "en-US"

    var id: String { rawValue }
    var flag: String {
        switch self {
        case .german: return "🇩🇪"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .italian: return "🇮🇹"
        case .portuguese: return "🇵🇹"
        case .dutch: return "🇳🇱"
        case .polish: return "🇵🇱"
        case .russian: return "🇷🇺"
        case .english: return "🇬🇧"
        }
    }
    var name: String {
        switch self {
        case .german: return "German"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .dutch: return "Dutch"
        case .polish: return "Polish"
        case .russian: return "Russian"
        case .english: return "English"
        }
    }
    var localeIdentifier: String { rawValue }
}

struct LanguagePair: Codable, Equatable, Hashable, Identifiable {
    let source: AppLanguage
    let target: AppLanguage
    var id: String { source.rawValue + "-" + target.rawValue }
    var displayName: String { source.flag + " " + source.name + " ↔ " + target.name + " " + target.flag }
    static var popularPairs: [LanguagePair] {
        [
            LanguagePair(source: .german, target: .spanish),
            LanguagePair(source: .german, target: .french),
            LanguagePair(source: .spanish, target: .french),
            LanguagePair(source: .german, target: .english),
            LanguagePair(source: .french, target: .english),
            LanguagePair(source: .italian, target: .english),
            LanguagePair(source: .portuguese, target: .spanish),
            LanguagePair(source: .dutch, target: .german),
            LanguagePair(source: .polish, target: .english),
            LanguagePair(source: .russian, target: .english),
            LanguagePair(source: .french, target: .german),
        ]
    }
}

enum ReviewDirection: String, Codable, CaseIterable, Identifiable {
    case sourceToTarget
    case targetToSource
    var id: String { rawValue }
    var title: String { self == .sourceToTarget ? "Forward" : "Reverse" }
    var reversed: ReviewDirection { self == .sourceToTarget ? .targetToSource : .sourceToTarget }
}

enum ChallengeMode: String, Codable {
    case word
    case sentence
}

enum CEFRLevel: String, Codable, CaseIterable, Identifiable, Comparable {
    case a1 = "A1", a2 = "A2", b1 = "B1", b2 = "B2", c1 = "C1"
    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .a1: return "Survival words & daily basics"
        case .a2: return "Travel, routines, useful verbs"
        case .b1: return "Real conversations & opinions"
        case .b2: return "Work, culture, fluent connectors"
        case .c1: return "Nuance, idioms, precise expression"
        }
    }
    var order: Int { CEFRLevel.allCases.firstIndex(of: self) ?? 0 }
    static func < (lhs: CEFRLevel, rhs: CEFRLevel) -> Bool { lhs.order < rhs.order }
}

struct VocabularyCard: Identifiable, Codable, Hashable {
    let id: String
    let sourceText: String
    let targetText: String
    let sourceLanguage: AppLanguage
    let targetLanguage: AppLanguage
    let level: CEFRLevel
    let category: String
    let exampleSource: String
    let exampleTarget: String
    let hint: String

    func prompt(for direction: ReviewDirection, mode: ChallengeMode = .word) -> String {
        if mode == .sentence { return direction == .sourceToTarget ? exampleSource : exampleTarget }
        return direction == .sourceToTarget ? sourceText : targetText
    }
    func answer(for direction: ReviewDirection, mode: ChallengeMode = .word) -> String {
        if mode == .sentence { return direction == .sourceToTarget ? exampleTarget : exampleSource }
        return direction == .sourceToTarget ? targetText : sourceText
    }
    func example(for language: AppLanguage) -> String { language == sourceLanguage ? exampleSource : exampleTarget }

    // Legacy init for backward-compatible German-Spanish cards
    init(id: String, german: String, spanish: String, level: CEFRLevel, category: String,
         exampleGerman: String, exampleSpanish: String, hint: String) {
        self.id = id
        self.sourceText = german
        self.targetText = spanish
        self.level = level
        self.category = category
        self.exampleSource = exampleGerman
        self.exampleTarget = exampleSpanish
        self.hint = hint
        self.sourceLanguage = .german
        self.targetLanguage = .spanish
    }

    // Full init for any language pair
    init(id: String, sourceText: String, targetText: String, sourceLanguage: AppLanguage, targetLanguage: AppLanguage,
         level: CEFRLevel, category: String, exampleSource: String, exampleTarget: String, hint: String) {
        self.id = id
        self.sourceText = sourceText
        self.targetText = targetText
        self.level = level
        self.category = category
        self.exampleSource = exampleSource
        self.exampleTarget = exampleTarget
        self.hint = hint
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
    }
}

enum ReviewGrade: Int, Codable, CaseIterable, Identifiable {
    case again = 1, hard = 2, good = 3, easy = 4
    var id: Int { rawValue }
    var title: String {
        switch self { case .again: return "Again"; case .hard: return "Hard"; case .good: return "Good"; case .easy: return "Easy" }
    }
    var xp: Int { rawValue * 4 }
    var fluencyDrops: Double { self == .again ? 0 : Double(rawValue * rawValue) }
    var color: Color {
        switch self { case .again: return .red; case .hard: return .orange; case .good: return .green; case .easy: return .blue }
    }
}

struct CardSchedule: Codable, Equatable {
    var repetitions: Int = 0
    var intervalDays: Int = 0
    var easeFactor: Double = 2.5
    var dueDate: Date = .distantPast
    var lapses: Int = 0
    var lastReviewed: Date?
}

// MARK: - Pet System
struct Pet: Codable, Equatable {
    var type: PetType = .cat
    var name: String = "Mochi"
    var happiness: Double = 0.5
    var hunger: Double = 0.3
    var energy: Double = 0.7
    var level: Int = 1
    var xp: Int = 0
    var totalFed: Int = 0
    var lastInteraction: Date? = nil
    
    var mood: PetMood {
        if happiness > 0.7 && hunger < 0.4 { return .happy }
        if hunger > 0.7 { return .hungry }
        if happiness < 0.3 { return .sad }
        if energy < 0.2 { return .tired }
        return .neutral
    }
    
    var emoji: String {
        switch mood {
        case .happy: return type == .cat ? "😸" : type == .dog ? "🐕" : type == .owl ? "🦉" : type == .fox ? "🦊" : "🐧"
        case .hungry: return type == .cat ? "🙀" : type == .dog ? "🐕‍🦺" : type == .owl ? "🦉" : type == .fox ? "🦊" : "🐧"
        case .sad: return type == .cat ? "😿" : type == .dog ? "🐕" : type == .owl ? "🦉" : type == .fox ? "🦊" : "🐧"
        case .tired: return "😴"
        case .neutral: return type.emoji
        }
    }
    
    var description: String {
        switch mood {
        case .happy: return "\(name) is ecstatic! Keep learning!"
        case .hungry: return "\(name) is hungry! Answer correctly to feed them."
        case .sad: return "\(name) misses you. Come practice!"
        case .tired: return "\(name) needs rest."
        case .neutral: return "\(name) is doing okay."
        }
    }
    
    mutating func feed(correctAnswers: Int) {
        let food = Double(correctAnswers) * 0.15
        hunger = max(0, hunger - food)
        happiness = min(1, happiness + food * 0.5)
        energy = min(1, energy + food * 0.3)
        xp += correctAnswers * 10
        totalFed += correctAnswers
        let newLevel = (xp / 100) + 1
        if newLevel > level {
            level = newLevel
            happiness = min(1, happiness + 0.2)
        }
        lastInteraction = Date()
    }
    
    mutating func decay() {
        hunger = min(1, hunger + 0.02)
        happiness = max(0, happiness - 0.01)
        energy = max(0, energy - 0.005)
    }
}

enum PetType: String, Codable, CaseIterable, Identifiable {
    case cat = "cat", dog = "dog", owl = "owl", fox = "fox", penguin = "penguin"
    var id: String { rawValue }
    var emoji: String {
        switch self { case .cat: return "🐱"; case .dog: return "🐶"; case .owl: return "🦉"; case .fox: return "🦊"; case .penguin: return "🐧" }
    }
    var displayName: String {
        switch self { case .cat: return "Cat"; case .dog: return "Dog"; case .owl: return "Owl"; case .fox: return "Fox"; case .penguin: return "Penguin" }
    }
}

enum PetMood: String, Codable { case happy, hungry, sad, tired, neutral }

// MARK: - Pet Evolution
enum PetStage: String, Codable {
    case baby, teen, adult, legendary
    var title: String {
        switch self { case .baby: return "Baby"; case .teen: return "Teen"; case .adult: return "Adult"; case .legendary: return "Legendary" }
    }
}

struct PetAbility: Codable, Equatable {
    let name: String
    let description: String
    let icon: String
    let isActive: Bool
}

extension Pet {
    var stage: PetStage {
        switch level {
        case 1...5: return .baby
        case 6...15: return .teen
        case 16...30: return .adult
        default: return .legendary
        }
    }
    
    var stageEmoji: String {
        switch (type, stage) {
        case (.cat, .baby): return "🐱"
        case (.cat, .teen): return "😺"
        case (.cat, .adult): return "😸"
        case (.cat, .legendary): return "🦁"
        case (.dog, .baby): return "🐶"
        case (.dog, .teen): return "🐕"
        case (.dog, .adult): return "🐕‍🦺"
        case (.dog, .legendary): return "🐺"
        case (.owl, .baby): return "🐣"
        case (.owl, .teen): return "🦉"
        case (.owl, .adult): return "🦅"
        case (.owl, .legendary): return "🐉"
        case (.fox, .baby): return "🦊"
        case (.fox, .teen): return "🐺"
        case (.fox, .adult): return "🦁"
        case (.fox, .legendary): return "🦄"
        case (.penguin, .baby): return "🐧"
        case (.penguin, .teen): return "🐦"
        case (.penguin, .adult): return "🦅"
        case (.penguin, .legendary): return "🐉"
        }
    }
    
    var currentEmoji: String {
        if mood == .tired { return "😴" }
        if mood == .sad { return "😿" }
        if mood == .hungry { return "🙀" }
        return stageEmoji
    }
    
    var xpToNextLevel: Int {
        let base = 100
        let multiplier = Double(level) * 0.5
        return base + Int(Double(base) * multiplier)
    }
    
    var progressToNextLevel: Double {
        Double(xp) / Double(xpToNextLevel)
    }
    
    var abilities: [PetAbility] {
        var abilities: [PetAbility] = []
        if level >= 5 { abilities.append(PetAbility(name: "XP Boost", description: "+10% XP on correct answers", icon: "star.fill", isActive: true)) }
        if level >= 10 { abilities.append(PetAbility(name: "Streak Shield", description: "Protects streak once per day", icon: "shield.fill", isActive: true)) }
        if level >= 15 { abilities.append(PetAbility(name: "Gem Hunter", description: "+1 gem per perfect answer", icon: "diamond.fill", isActive: true)) }
        if level >= 25 { abilities.append(PetAbility(name: "Double XP", description: "2x XP on weekends", icon: "sparkles", isActive: true)) }
        return abilities
    }
    
    mutating func play() {
        happiness = min(1.0, happiness + 0.15)
        energy = max(0, energy - 0.1)
        lastInteraction = Date()
    }
    
    mutating func sleep() {
        energy = min(1.0, energy + 0.3)
        hunger = min(1.0, hunger + 0.05)
        lastInteraction = Date()
    }
    
    mutating func stroke() {
        happiness = min(1.0, happiness + 0.1)
        lastInteraction = Date()
    }
    
    mutating func addXP(_ amount: Int) {
        xp += amount
        let newLevel = (xp / 100) + 1
        if newLevel > level {
            level = newLevel
            happiness = min(1, happiness + 0.3)
        }
    }
    
    mutating func evolvedFeed(correctAnswers: Int) {
        let food = Double(correctAnswers) * 0.15
        hunger = max(0, hunger - food)
        happiness = min(1, happiness + food * 0.5)
        energy = min(1, energy + food * 0.3)
        xp += correctAnswers * 10
        totalFed += correctAnswers
        let newLevel = (xp / 100) + 1
        if newLevel > level {
            level = newLevel
            happiness = min(1, happiness + 0.3)
        }
        lastInteraction = Date()
    }
}

// MARK: - User Stats
struct UserStats: Codable, Equatable {
    var hasSeenTitle: Bool = false
    var selectedLevel: CEFRLevel? = nil
    var direction: ReviewDirection = .sourceToTarget
    var selectedLanguagePair: LanguagePair = LanguagePair(source: .german, target: .spanish)
    var autoMixDirections: Bool = true
    var xp: Int = 0
    var streak: Int = 0
    var bestStreak: Int = 0
    var gems: Int = 0
    var reviewedToday: Int = 0
    var correctToday: Int = 0
    var lastPracticeDay: Date? = nil
    var totalReviews: Int = 0
    var fluentDrops: Double = 0
    var goalName: String = "Speak fluently on vacation"
    var goalDate: Date = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    var dailyGoal: Int = 12
    var darkMode: Bool = false
    var workMinutes: Int = 25
    var breakMinutes: Int = 5
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var notificationsEnabled: Bool = true
    var unlockedLevels: [CEFRLevel] = [.a1]
    var pet: Pet = Pet()
    var hasSeenPetPicker: Bool = false
    var hasSkippedAuth: Bool = false
    var fluency: Double { 0 }
    var accuracyToday: Double { reviewedToday == 0 ? 0 : Double(correctToday) / Double(reviewedToday) }
}

// MARK: - Answer Evaluator
struct AnswerEvaluator {
    enum Result: Equatable { case correct, almost, wrong }

    static func evaluate(_ attempt: String, expected: String) -> Result {
        let typed = normalize(attempt)
        guard !typed.isEmpty else { return .wrong }
        let answers = expected.components(separatedBy: "/").map(normalize).filter { !$0.isEmpty }
        if answers.contains(typed) { return .correct }
        if answers.contains(where: { isClose(typed, $0) }) { return .almost }
        return .wrong
    }

    static func normalize(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "¿", with: "")
            .replacingOccurrences(of: "?", with: "")
            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func isClose(_ a: String, _ b: String) -> Bool {
        let distance = levenshtein(Array(a), Array(b))
        return distance <= max(1, min(3, b.count / 6))
    }

    private static func levenshtein(_ a: [Character], _ b: [Character]) -> Int {
        var dp = Array(0...b.count)
        for (i, ca) in a.enumerated() {
            var previous = dp[0]
            dp[0] = i + 1
            for (j, cb) in b.enumerated() {
                let temp = dp[j + 1]
                dp[j + 1] = ca == cb ? previous : min(previous, dp[j], dp[j + 1]) + 1
                previous = temp
            }
        }
        return dp[b.count]
    }
}
