import Foundation
import SwiftUI

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case german = "de-DE"
    case spanish = "es-ES"
    var id: String { rawValue }
    var flag: String { self == .german ? "🇩🇪" : "🇪🇸" }
    var name: String { self == .german ? "German" : "Spanish" }
}

enum ReviewDirection: String, Codable, CaseIterable, Identifiable {
    case germanToSpanish
    case spanishToGerman
    var id: String { rawValue }
    var title: String { self == .germanToSpanish ? "German → Spanish" : "Spanish → German" }
    var source: AppLanguage { self == .germanToSpanish ? .german : .spanish }
    var target: AppLanguage { self == .germanToSpanish ? .spanish : .german }
    var reversed: ReviewDirection { self == .germanToSpanish ? .spanishToGerman : .germanToSpanish }
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
    let german: String
    let spanish: String
    let level: CEFRLevel
    let category: String
    let exampleGerman: String
    let exampleSpanish: String
    let hint: String

    func prompt(for direction: ReviewDirection, mode: ChallengeMode = .word) -> String {
        if mode == .sentence { return direction == .germanToSpanish ? exampleGerman : exampleSpanish }
        return direction == .germanToSpanish ? german : spanish
    }
    func answer(for direction: ReviewDirection, mode: ChallengeMode = .word) -> String {
        if mode == .sentence { return direction == .germanToSpanish ? exampleSpanish : exampleGerman }
        return direction == .germanToSpanish ? spanish : german
    }
    func example(for language: AppLanguage) -> String { language == .german ? exampleGerman : exampleSpanish }
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

// MARK: - User Stats
struct UserStats: Codable, Equatable {
    var hasSeenTitle: Bool = false
    var selectedLevel: CEFRLevel? = nil
    var direction: ReviewDirection = .germanToSpanish
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
