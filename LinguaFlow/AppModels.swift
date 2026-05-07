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
    func prompt(for direction: ReviewDirection) -> String { direction == .germanToSpanish ? german : spanish }
    func answer(for direction: ReviewDirection) -> String { direction == .germanToSpanish ? spanish : german }
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

struct UserStats: Codable, Equatable {
    var selectedLevel: CEFRLevel? = nil
    var direction: ReviewDirection = .germanToSpanish
    var xp: Int = 0
    var streak: Int = 0
    var bestStreak: Int = 0
    var gems: Int = 0
    var reviewedToday: Int = 0
    var correctToday: Int = 0
    var lastPracticeDay: Date? = nil
    var totalReviews: Int = 0
    var fluentDrops: Double = 0
    var fluency: Double { min(1, fluentDrops / 900) }
    var accuracyToday: Double { reviewedToday == 0 ? 0 : Double(correctToday) / Double(reviewedToday) }
}
