import Foundation

struct SpacedRepetitionScheduler {
    var calendar: Calendar = .current

    func nextSchedule(from current: CardSchedule, grade: ReviewGrade, now: Date = Date()) -> CardSchedule {
        var next = current
        next.lastReviewed = now
        switch grade {
        case .again:
            next.repetitions = 0
            next.intervalDays = 0
            next.easeFactor = max(1.3, current.easeFactor - 0.20)
            next.lapses += 1
            next.dueDate = now.addingTimeInterval(10 * 60)
        case .hard:
            next.repetitions = max(1, current.repetitions)
            let base = max(1, current.intervalDays)
            next.intervalDays = max(1, Int(Double(base) * 1.2))
            next.easeFactor = max(1.3, current.easeFactor - 0.15)
            next.dueDate = calendar.date(byAdding: .day, value: next.intervalDays, to: now) ?? now
        case .good:
            next.repetitions = current.repetitions + 1
            if next.repetitions == 1 { next.intervalDays = 1 }
            else if next.repetitions == 2 { next.intervalDays = 3 }
            else { next.intervalDays = max(4, Int(round(Double(max(1, current.intervalDays)) * current.easeFactor))) }
            next.dueDate = calendar.date(byAdding: .day, value: next.intervalDays, to: now) ?? now
        case .easy:
            next.repetitions = current.repetitions + 1
            next.easeFactor = min(3.2, current.easeFactor + 0.15)
            if next.repetitions == 1 { next.intervalDays = 3 }
            else { next.intervalDays = max(5, Int(round(Double(max(1, current.intervalDays)) * next.easeFactor * 1.3))) }
            next.dueDate = calendar.date(byAdding: .day, value: next.intervalDays, to: now) ?? now
        }
        return next
    }

    func dueCards(from cards: [VocabularyCard], schedules: [String: CardSchedule], now: Date = Date(), limit: Int = 20) -> [VocabularyCard] {
        Array(cards.filter { (schedules[$0.id]?.dueDate ?? .distantPast) <= now }
            .sorted { (schedules[$0.id]?.dueDate ?? .distantPast) < (schedules[$1.id]?.dueDate ?? .distantPast) }
            .prefix(limit))
    }
}
