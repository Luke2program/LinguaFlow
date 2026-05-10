import Foundation

// MARK: - Pet Evolution System
enum PetStage: String, Codable {
    case baby, teen, adult, legendary
    var title: String {
        switch self {
        case .baby: return "Baby"
        case .teen: return "Teen"
        case .adult: return "Adult"
        case .legendary: return "Legendary"
        }
    }
}

struct PetAbility: Codable, Equatable {
    let name: String
    let description: String
    let icon: String
    let isActive: Bool
}

// MARK: - Pet Extensions
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
        if level >= 5 {
            abilities.append(PetAbility(name: "XP Boost", description: "+10% XP on correct answers", icon: "star.fill", isActive: true))
        }
        if level >= 10 {
            abilities.append(PetAbility(name: "Streak Shield", description: "Protects streak once per day", icon: "shield.fill", isActive: true))
        }
        if level >= 15 {
            abilities.append(PetAbility(name: "Gem Hunter", description: "+1 gem per perfect answer", icon: "diamond.fill", isActive: true))
        }
        if level >= 25 {
            abilities.append(PetAbility(name: "Double XP", description: "2x XP on weekends", icon: "sparkles", isActive: true))
        }
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
        let newLevel = calculateLevel()
        if newLevel > level {
            level = newLevel
            happiness = min(1, happiness + 0.3)
        }
    }
    
    private func calculateLevel() -> Int {
        var currentXP = 0
        var lvl = 1
        while currentXP <= xp {
            let base = 100
            let multiplier = Double(lvl) * 0.5
            let needed = base + Int(Double(base) * multiplier)
            currentXP += needed
            if currentXP <= xp {
                lvl += 1
            }
        }
        return lvl
    }
    
    mutating func evolvedFeed(correctAnswers: Int) {
        let food = Double(correctAnswers) * 0.15
        hunger = max(0, hunger - food)
        happiness = min(1, happiness + food * 0.5)
        energy = min(1, energy + food * 0.3)
        xp += correctAnswers * 10
        totalFed += correctAnswers
        let newLevel = calculateLevel()
        if newLevel > level {
            level = newLevel
            happiness = min(1, happiness + 0.3)
        }
        lastInteraction = Date()
    }
}
