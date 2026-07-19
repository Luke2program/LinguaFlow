import Foundation
import SwiftUI

// MARK: - Subject System
enum Subject: String, Codable, CaseIterable, Identifiable {
    case languages = "languages"
    case history = "history"
    case science = "science"
    case geography = "geography"
    case math = "math"
    case culture = "culture"
    case business = "business"
    case health = "health"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .languages: return "🌍 Languages"
        case .history: return "🏛️ History"
        case .science: return "🔬 Science"
        case .geography: return "🗺️ Geography"
        case .math: return "🔢 Math"
        case .culture: return "🎭 Culture"
        case .business: return "📈 Business"
        case .health: return "💚 Health"
        }
    }
    
    var subtitle: String {
        switch self {
        case .languages: return "Master new languages with spaced repetition"
        case .history: return "Explore real worlds, make choices, change history"
        case .science: return "Discover how the universe works"
        case .geography: return "Explore maps, borders, routes, and hidden places"
        case .math: return "Build number skills with quick challenges"
        case .culture: return "Art, music, food, and traditions worldwide"
        case .business: return "Strategy, markets, money, and sharper decisions"
        case .health: return "Sleep, nutrition, movement, and practical wellbeing"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .languages: return .blue
        case .history: return .orange
        case .science: return .green
        case .geography: return .cyan
        case .math: return .purple
        case .culture: return .pink
        case .business: return .indigo
        case .health: return .mint
        }
    }
    
    var icon: String {
        switch self {
        case .languages: return "globe"
        case .history: return "building.columns"
        case .science: return "atom"
        case .geography: return "map"
        case .math: return "function"
        case .culture: return "theatermasks"
        case .business: return "chart.line.uptrend.xyaxis"
        case .health: return "heart.text.square"
        }
    }

    var mapTitle: String {
        switch self {
        case .languages: return "Language Route"
        case .history: return "History Map"
        case .science: return "Discovery Map"
        case .geography: return "Atlas Map"
        case .math: return "Puzzle Map"
        case .culture: return "Culture Map"
        case .business: return "Market Map"
        case .health: return "Wellbeing Map"
        }
    }

    var mapSystemImage: String {
        switch self {
        case .history: return "map.fill"
        case .science: return "sparkles"
        case .geography: return "map"
        case .math: return "point.3.connected.trianglepath.dotted"
        case .culture: return "figure.socialdance"
        default: return icon
        }
    }
    
    var worlds: [PlayableWorld] {
        switch self {
        case .history:
            return [
                PlayableWorld(id: "ancient-rome", name: "Ancient Rome", emoji: "🏛️", era: "753 BCE – 476 CE", description: "Walk the streets of Rome. Survive politics, lead legions, witness the fall.", unlockRequirement: .none),
                PlayableWorld(id: "medieval-europe", name: "Medieval Europe", emoji: "🏰", era: "500 – 1500 CE", description: "Navigate feudal courts, trade on the Silk Road, survive the Black Death.", unlockRequirement: .xpRequired(500)),
                PlayableWorld(id: "age-discovery", name: "Age of Discovery", emoji: "⚓", era: "1400 – 1600 CE", description: "Sail uncharted seas. Discover continents. Face storms and mutiny.", unlockRequirement: .xpRequired(1000)),
            ]
        case .science:
            return [
                PlayableWorld(id: "space-exploration", name: "Space Frontiers", emoji: "🚀", era: "1957 – Present", description: "From Sputnik to Mars. Learn orbital mechanics and mission control.", unlockRequirement: .none),
                PlayableWorld(id: "quantum-realm", name: "Quantum Realm", emoji: "⚛️", era: "1900 – Present", description: "Particles, waves, and spooky action at a distance.", unlockRequirement: .xpRequired(750)),
            ]
        case .geography:
            return [
                PlayableWorld(id: "european-capitals", name: "European Capitals", emoji: "🇪🇺", era: "Modern", description: "Navigate Europe by capital cities, rivers, mountains, and borders.", unlockRequirement: .none),
                PlayableWorld(id: "african-wonders", name: "African Wonders", emoji: "🌍", era: "Ancient – Modern", description: "From the Sahara to Kilimanjaro. Rivers, deserts, and ecosystems.", unlockRequirement: .xpRequired(300)),
            ]
        case .math:
            return [
                PlayableWorld(id: "logic-gates", name: "Logic Gates", emoji: "🔢", era: "Foundations", description: "Crack pattern locks, ratios, and number rules in a neon puzzle vault.", unlockRequirement: .none),
                PlayableWorld(id: "probability-casino", name: "Probability Casino", emoji: "🎲", era: "Chance", description: "Read odds, avoid traps, and make smarter bets with probability.", unlockRequirement: .xpRequired(400)),
            ]
        case .culture:
            return [
                PlayableWorld(id: "heritage-kitchens", name: "Heritage Kitchens", emoji: "🍜", era: "Living traditions", description: "Travel through food rituals, etiquette, markets, and everyday meanings behind iconic dishes.", unlockRequirement: .none),
                PlayableWorld(id: "festival-roads", name: "Festival Roads", emoji: "🎊", era: "Seasonal cycles", description: "Follow real festivals through music, symbols, calendars, and community traditions.", unlockRequirement: .xpRequired(450)),
            ]
        case .business:
            return [
                PlayableWorld(id: "founder-guild", name: "Founder Guild", emoji: "📈", era: "Startup basics", description: "Make practical startup, pricing, cash-flow, and customer decisions under pressure.", unlockRequirement: .none),
                PlayableWorld(id: "wall-street-desk", name: "Wall Street Desk", emoji: "💼", era: "Markets", description: "Read incentives, risk, diversification, and market signals without falling for hype.", unlockRequirement: .xpRequired(550)),
            ]
        case .health:
            return [
                PlayableWorld(id: "energy-clinic", name: "Energy Clinic", emoji: "💚", era: "Daily systems", description: "Stabilize sleep, food, movement, hydration, and stress with practical habit decisions.", unlockRequirement: .none),
                PlayableWorld(id: "resilience-gym", name: "Resilience Gym", emoji: "🧠", era: "Mind and recovery", description: "Train recovery, focus, emotional regulation, and long-term wellbeing without health fads.", unlockRequirement: .xpRequired(500)),
            ]
        case .languages:
            return []
        }
    }
}

struct PlayableWorld: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let era: String
    let description: String
    let unlockRequirement: UnlockRequirement
    
    var isUnlocked: Bool {
        // This is used in View logic; actual check uses xp parameter externally
        true
    }

    var rewardName: String {
        "\(name) Badge"
    }

    func isUnlocked(withXP xp: Int) -> Bool {
        switch unlockRequirement {
        case .none:
            return true
        case .xpRequired(let requiredXP):
            return xp >= requiredXP
        }
    }

    func xpRemaining(withXP xp: Int) -> Int {
        max(0, (unlockRequirement.xpRequired ?? 0) - xp)
    }

    func unlockProgress(withXP xp: Int) -> Double {
        guard let requiredXP = unlockRequirement.xpRequired, requiredXP > 0 else { return 1 }
        return min(1, max(0, Double(xp) / Double(requiredXP)))
    }
}

enum UnlockRequirement: Codable, Equatable {
    case none
    case xpRequired(Int)

    var xpRequired: Int? {
        switch self {
        case .none: return nil
        case .xpRequired(let x): return x
        }
    }
}

extension Subject {
    func unlockedWorldCount(withXP xp: Int) -> Int {
        worlds.filter { $0.isUnlocked(withXP: xp) }.count
    }

    func nextLockedWorld(withXP xp: Int) -> PlayableWorld? {
        worlds.first { !$0.isUnlocked(withXP: xp) }
    }
}

// MARK: - History Challenge (story-based multiple choice)
struct HistoryChallenge: Identifiable, Codable, Equatable {
    let id: String
    let worldId: String
    let era: String
    let year: Int
    let question: String
    let context: String
    let choices: [HistoryChoice]
    let historicalFact: String
    let sourceCitation: String
}

struct HistoryChoice: Codable, Equatable {
    let id: String
    let text: String
    let consequence: String
    let isCorrect: Bool
    let historicalOutcome: String
}

enum HistoryData {
    static let ancientRomeChallenges: [HistoryChallenge] = [
        HistoryChallenge(
            id: "rome-01",
            worldId: "ancient-rome",
            era: "Republic",
            year: -49,
            question: "Caesar stands at the Rubicon. Cross it and start civil war, or disband his legions and face prosecution?",
            context: "In 49 BCE, Julius Caesar was ordered by the Senate to disband his army and return to Rome. Crossing the Rubicon river with his troops would be an act of war against the Roman Republic.",
            choices: [
                HistoryChoice(id: "a", text: "Cross the Rubicon — the die is cast", consequence: "You march on Rome. Civil war begins. The Republic will never be the same.", isCorrect: true, historicalOutcome: "Caesar crossed on January 10, 49 BCE, uttering 'alea iacta est' (the die is cast). He defeated Pompey and became dictator for life, ending the Republic."),
                HistoryChoice(id: "b", text: "Disband the legions and face trial", consequence: "You lose your political career and military power. Pompey consolidates control.", isCorrect: false, historicalOutcome: "If Caesar had disbanded, he likely would have been prosecuted and exiled. The Republic might have survived longer, but political corruption would continue.")
            ],
            historicalFact: "The phrase 'crossing the Rubicon' still means passing a point of no return.",
            sourceCitation: "Plutarch, Life of Caesar; Appian, Civil Wars"
        ),
        HistoryChallenge(
            id: "rome-02",
            worldId: "ancient-rome",
            era: "Empire",
            year: 64,
            question: "A fire rages through Rome. Nero blames the Christians. As a Roman citizen, what do you do?",
            context: "The Great Fire of Rome in 64 CE burned for six days, destroying much of the city. Emperor Nero allegedly played the lyre while watching. He needed scapegoats.",
            choices: [
                HistoryChoice(id: "a", text: "Report suspected Christians to the Praetorian Guard", consequence: "You survive, but innocent people are tortured and burned alive. Nero uses them as human torches in his garden parties.", isCorrect: false, historicalOutcome: "Nero persecuted Christians brutally. According to Tacitus, they were covered in wild animal skins and torn apart by dogs, or crucified and set on fire as nightly illumination."),
                HistoryChoice(id: "b", text: "Hide your Christian neighbors and speak out against the scapegoating", consequence: "You risk arrest, torture, and execution. But you stand on the side of justice.", isCorrect: true, historicalOutcome: "Early Christians faced systematic persecution. The tradition of martyrdom shaped Christianity. Persecution ended with Constantine's Edict of Milan in 313 CE.")
            ],
            historicalFact: "Tacitus, a Roman historian, recorded that Nero's persecution was not for the public good but to satisfy his cruelty.",
            sourceCitation: "Tacitus, Annals XV.44"
        ),
        HistoryChallenge(
            id: "rome-03",
            worldId: "ancient-rome",
            era: "Crisis",
            year: 476,
            question: "The barbarian Odoacer deposes Romulus Augustulus. Is this the end of Rome, or just a transformation?",
            context: "In 476 CE, the Germanic general Odoacer deposed the last Western Roman Emperor, a 14-year-old boy named Romulus Augustulus. The Eastern Empire at Constantinople continued for nearly 1,000 more years.",
            choices: [
                HistoryChoice(id: "a", text: "It's the fall — Rome is finished forever", consequence: "You mourn the end of civilization. But you miss the bigger picture.", isCorrect: false, historicalOutcome: "The Western Empire collapsed politically, but Roman law, language, religion, and infrastructure shaped Europe for centuries. The idea of Rome never died."),
                HistoryChoice(id: "b", text: "It's a transformation — Rome lives on in law, language, and faith", consequence: "You see continuity. Roman roads still carry travelers. Latin still shapes languages. The Church still uses Roman structure.", isCorrect: true, historicalOutcome: "The Eastern Roman (Byzantine) Empire lasted until 1453. Roman law became the basis of modern European legal systems. The Catholic Church preserved Roman administrative structure.")
            ],
            historicalFact: "The date 476 CE was chosen by 16th-century historian Edward Gibbon as the 'fall' date, but historians now view it as a gradual transformation.",
            sourceCitation: "Gibbon, Decline and Fall of the Roman Empire; Heather, The Fall of the Roman Empire"
        ),
        HistoryChallenge(
            id: "rome-04",
            worldId: "ancient-rome",
            era: "Early Republic",
            year: -390,
            question: "Gauls sack Rome! The Senate debates: pay ransom and survive, or fight to the death?",
            context: "Around 390 BCE, Brennus and his Gallic army defeated the Romans at the Battle of Allia and sacked Rome itself. The city was desperate.",
            choices: [
                HistoryChoice(id: "a", text: "Pay the ransom of 1,000 pounds of gold", consequence: "Rome survives, but Brennus adds his heavy sword to the scales, saying 'Vae victis' — woe to the vanquished.", isCorrect: true, historicalOutcome: "According to Livy, Rome paid the ransom. Brennus threw his sword onto the scales to increase the weight, saying 'Vae victis.' The humiliation fueled Roman determination."),
                HistoryChoice(id: "b", text: "Refuse and fight to extinction", consequence: "The Gauls burn the city. Survivors flee to Veii. Rome becomes a cautionary tale, not an empire.", isCorrect: false, historicalOutcome: "If Rome had been destroyed, Western history would be unrecognizable. No Roman law, no Romance languages, no Catholic Church structure. The Gauls might have built an empire, but they had no state-building tradition.")
            ],
            historicalFact: "The sack of Rome by the Gauls was so traumatic that the Romans built the Servian Wall and developed a militaristic culture that eventually conquered Gaul itself under Caesar.",
            sourceCitation: "Livy, Ab Urbe Condita V; Polybius, Histories"
        ),
        HistoryChallenge(
            id: "rome-05",
            worldId: "ancient-rome",
            era: "Empire",
            year: 117,
            question: "Rome is at its greatest extent under Trajan. Keep expanding, or consolidate?",
            context: "In 117 CE, Emperor Trajan died, leaving the Empire at its maximum territorial extent — from Britain to Mesopotamia. His successor Hadrian faced a choice.",
            choices: [
                HistoryChoice(id: "a", text: "Continue Trajan's conquests into Persia and beyond", consequence: "The army is overextended. Revolts break out. The treasury empties. The Empire begins to crack.", isCorrect: false, historicalOutcome: "Overextension was a real danger. The Parthian campaigns were costly. Trajan himself had to withdraw from Mesopotamia due to revolts before his death."),
                HistoryChoice(id: "b", text: "Consolidate borders, build walls, strengthen from within", consequence: "You build Hadrian's Wall in Britain, fortify the Rhine and Danube. The Empire stabilizes for decades.", isCorrect: true, historicalOutcome: "Hadrian abandoned Trajan's eastern conquests, built Hadrian's Wall (122 CE), and toured the provinces to strengthen administration. The Empire enjoyed relative stability under the 'Five Good Emperors.'")
            ],
            historicalFact: "Hadrian's Wall ran 73 miles across northern Britain and marked the northwestern frontier of the Roman Empire for nearly 300 years.",
            sourceCitation: "Cassius Dio, Roman History; Birley, Hadrian: The Restless Emperor"
        )
    ]
    
    static func challenges(for worldId: String) -> [HistoryChallenge] {
        switch worldId {
        case "ancient-rome": return ancientRomeChallenges
        default: return []
        }
    }
    
    static func allChallenges(for subject: Subject) -> [HistoryChallenge] {
        switch subject {
        case .history: return ancientRomeChallenges
        default: return []
        }
    }
}

// MARK: - Science Challenge (quiz-based multiple choice)
struct ScienceChallenge: Identifiable, Codable, Equatable {
    let id: String
    let worldId: String
    let era: String
    let question: String
    let context: String
    let choices: [ScienceChoice]
    let funFact: String
    let field: String
}

struct ScienceChoice: Codable, Equatable {
    let id: String
    let text: String
    let isCorrect: Bool
    let explanation: String
}

enum ScienceData {
    static let spaceExplorationChallenges: [ScienceChallenge] = [
        ScienceChallenge(
            id: "space-01",
            worldId: "space-exploration",
            era: "1957",
            question: "What was the name of the first artificial satellite launched into space?",
            context: "On October 4, 1957, the Soviet Union launched a small metal sphere into orbit. It beeped for 21 days and changed the world forever.",
            choices: [
                ScienceChoice(id: "a", text: "Explorer 1", isCorrect: false, explanation: "Explorer 1 was the first US satellite, launched January 31, 1958 — four months later."),
                ScienceChoice(id: "b", text: "Sputnik 1", isCorrect: true, explanation: "Sputnik 1 was the first artificial satellite. Its radio signals were picked up by amateur radio operators worldwide. It orbited for 3 months before burning up."),
                ScienceChoice(id: "c", text: "Vostok 1", isCorrect: false, explanation: "Vostok 1 carried the first human, Yuri Gagarin, into space in 1961 — four years after Sputnik."),
                ScienceChoice(id: "d", text: "Apollo 11", isCorrect: false, explanation: "Apollo 11 was the 1969 mission that landed humans on the Moon — 12 years after Sputnik.")
            ],
            funFact: "Sputnik 1 was only 58 cm in diameter — about the size of a beach ball — but it triggered the Space Race between the US and USSR.",
            field: "Aerospace"
        ),
        ScienceChallenge(
            id: "space-02",
            worldId: "space-exploration",
            era: "1961",
            question: "Why did Yuri Gagarin eject from Vostok 1 before landing?",
            context: "The Vostok capsule was designed to land with the cosmonaut inside, but Soviet engineers worried about the impact forces on the pilot.",
            choices: [
                ScienceChoice(id: "a", text: "The capsule's parachute failed to deploy", isCorrect: false, explanation: "The parachute did deploy. But the landing was expected to be too violent for a human to survive."),
                ScienceChoice(id: "b", text: "Soviet rules required the pilot to land by parachute for safety", isCorrect: true, explanation: "Correct. Gagarin ejected at 7 km altitude and landed under his own parachute. The capsule landed separately. For decades the Soviets hid this because FAI rules required the pilot to land with the spacecraft for record certification."),
                ScienceChoice(id: "c", text: "The capsule was on fire", isCorrect: false, explanation: "There was no fire. The heat shield worked perfectly during re-entry."),
                ScienceChoice(id: "d", text: "He wanted to be the first person to spacewalk", isCorrect: false, explanation: "The first spacewalk was by Alexei Leonov in 1965, not Gagarin in 1961. Gagarin's ejection was mandatory, not a choice.")
            ],
            funFact: "Gagarin's flight lasted just 108 minutes — but it proved humans could survive launch, weightlessness, and re-entry. He became the most famous person on Earth.",
            field: "Human Spaceflight"
        ),
        ScienceChallenge(
            id: "space-03",
            worldId: "space-exploration",
            era: "1969",
            question: "What fuel powered the Saturn V rocket's first stage?",
            context: "The Saturn V remains the most powerful rocket ever successfully flown. Its first stage produced 7.6 million pounds of thrust.",
            choices: [
                ScienceChoice(id: "a", text: "Liquid hydrogen and liquid oxygen", isCorrect: false, explanation: "LH2/LOX powered the second and third stages. The first stage used different fuels."),
                ScienceChoice(id: "b", text: "Kerosene (RP-1) and liquid oxygen", isCorrect: true, explanation: "Correct. The F-1 engines burned RP-1 (a refined kerosene) with liquid oxygen. The exhaust was mostly water and carbon dioxide."),
                ScienceChoice(id: "c", text: "Solid rocket boosters", isCorrect: false, explanation: "Solid boosters were used on the Space Shuttle, not the Saturn V. The Saturn V was all-liquid-fueled."),
                ScienceChoice(id: "d", text: "Nuclear thermal propulsion", isCorrect: false, explanation: "Nuclear rockets were researched (NERVA program) but never flew on a manned mission. Saturn V was entirely chemical.")
            ],
            funFact: "The Saturn V first stage consumed 15 tons of fuel per second. At full power, it could drain an Olympic swimming pool in about 10 seconds.",
            field: "Rocket Engineering"
        ),
        ScienceChallenge(
            id: "space-04",
            worldId: "space-exploration",
            era: "1977",
            question: "Which planets did the Voyager spacecraft visit?",
            context: "Voyager 1 and 2 launched in 1977 on a 'Grand Tour' of the outer solar system, made possible by a rare planetary alignment that happens once every 176 years.",
            choices: [
                ScienceChoice(id: "a", text: "Jupiter and Saturn only", isCorrect: false, explanation: "Voyager 1 visited Jupiter and Saturn. But Voyager 2 went much farther."),
                ScienceChoice(id: "b", text: "All four gas giants: Jupiter, Saturn, Uranus, and Neptune", isCorrect: true, explanation: "Correct. Voyager 2 is the only spacecraft to visit Uranus (1986) and Neptune (1989). It discovered 10 new moons at Uranus and 6 at Neptune."),
                ScienceChoice(id: "c", text: "Mars, Jupiter, and Saturn", isCorrect: false, explanation: "Neither Voyager visited Mars. They were designed for the outer solar system beyond the asteroid belt."),
                ScienceChoice(id: "d", text: "Pluto and the Kuiper Belt", isCorrect: false, explanation: "New Horizons visited Pluto in 2015. Voyager 1 is now in interstellar space, 15+ billion miles from Earth.")
            ],
            funFact: "Both Voyagers carry golden records with sounds and images of Earth, intended for any intelligent extraterrestrial life that might find them. They'll outlast the Sun.",
            field: "Planetary Science"
        ),
        ScienceChallenge(
            id: "space-05",
            worldId: "space-exploration",
            era: "1990",
            question: "Why was the Hubble Space Telescope's first images blurry?",
            context: "Hubble was launched in 1990 with great fanfare. But its first images were disappointingly fuzzy — a public relations disaster for NASA.",
            choices: [
                ScienceChoice(id: "a", text: "The primary mirror was ground to the wrong shape", isCorrect: true, explanation: "Correct. The 2.4-meter mirror was polished perfectly — but to the wrong curvature. It was too flat by 2 micrometers (1/50th the width of a human hair). A corrective optics package was installed in 1993 by astronauts."),
                ScienceChoice(id: "b", text: "The lens cap was still on", isCorrect: false, explanation: "There is no lens cap on a reflecting telescope. The error was in the mirror's figure, not anything blocking the light."),
                ScienceChoice(id: "c", text: "Atmospheric turbulence distorted the images", isCorrect: false, explanation: "Hubble orbits above Earth's atmosphere specifically to avoid turbulence. That's its entire advantage over ground telescopes."),
                ScienceChoice(id: "d", text: "The camera sensor was defective", isCorrect: false, explanation: "The cameras were fine. The problem was optical — the mirror's shape meant light didn't converge to a single focus point.")
            ],
            funFact: "Despite the initial flaw, Hubble has made over 1.5 million observations, discovered moons of Pluto, measured the expansion of the universe, and produced some of the most iconic images in science history.",
            field: "Astronomy"
        ),
        ScienceChallenge(
            id: "space-06",
            worldId: "space-exploration",
            era: "2012",
            question: "How does the Curiosity rover generate power on Mars?",
            context: "Curiosity landed on Mars in August 2012 and is still operational. Unlike earlier rovers, it doesn't rely on sunlight.",
            choices: [
                ScienceChoice(id: "a", text: "Solar panels", isCorrect: false, explanation: "Spirit and Opportunity used solar panels, but Curiosity is much larger and needs more power than panels could provide."),
                ScienceChoice(id: "b", text: "A radioisotope thermoelectric generator (RTG)", isCorrect: true, explanation: "Correct. Curiosity uses an RTG powered by plutonium-238 decay. It generates about 110 watts continuously — enough to run a bright lightbulb — and works day, night, and during dust storms."),
                ScienceChoice(id: "c", text: "A small nuclear reactor", isCorrect: false, explanation: "RTGs are not reactors. They use passive radioactive decay heat, not controlled nuclear fission. No Mars rover has used a true reactor."),
                ScienceChoice(id: "d", text: "Methane fuel cells", isCorrect: false, explanation: "NASA has researched in-situ resource utilization (making fuel from Martian CO2), but Curiosity carries all its power with it from Earth.")
            ],
            funFact: "The plutonium-238 in Curiosity's RTG has a half-life of 87.7 years. The rover started with 4.8 kg of Pu-238 and will still produce useful power decades from now.",
            field: "Engineering"
        )
    ]
    
    static func challenges(for worldId: String) -> [ScienceChallenge] {
        switch worldId {
        case "space-exploration": return spaceExplorationChallenges
        default: return []
        }
    }
}

// MARK: - Geography Challenge (map-based multiple choice)
struct GeographyChallenge: Identifiable, Codable, Equatable {
    let id: String
    let worldId: String
    let region: String
    let question: String
    let context: String
    let choices: [GeographyChoice]
    let mapClue: String
    let mapTargetLabel: String
    let mapStartX: Double
    let mapStartY: Double
    let mapTargetX: Double
    let mapTargetY: Double
    let fieldNote: String
}

struct GeographyChoice: Codable, Equatable {
    let id: String
    let text: String
    let isCorrect: Bool
    let explanation: String
}

enum GeographyData {
    static let europeanCapitalsChallenges: [GeographyChallenge] = [
        GeographyChallenge(
            id: "geo-eu-01",
            worldId: "european-capitals",
            region: "Central Europe",
            question: "Which capital city sits on the Danube and is closest to the eastern edge of the Alps?",
            context: "Your route follows the Danube from Bavaria toward the Pannonian Basin. The city you need was the imperial seat of the Habsburgs.",
            choices: [
                GeographyChoice(id: "a", text: "Vienna", isCorrect: true, explanation: "Vienna is Austria's capital, lies on the Danube, and sits near the Vienna Woods at the eastern edge of the Alps."),
                GeographyChoice(id: "b", text: "Prague", isCorrect: false, explanation: "Prague is inland on the Vltava River, not the Danube."),
                GeographyChoice(id: "c", text: "Warsaw", isCorrect: false, explanation: "Warsaw is on the Vistula River in Poland and is far north of the Alps."),
                GeographyChoice(id: "d", text: "Zagreb", isCorrect: false, explanation: "Zagreb is Croatia's capital, but it is not on the Danube.")
            ],
            mapClue: "Follow the Danube east until the Alps fade into the Vienna Basin.",
            mapTargetLabel: "Austria",
            mapStartX: 0.45,
            mapStartY: 0.42,
            mapTargetX: 0.54,
            mapTargetY: 0.48,
            fieldNote: "Vienna's position helped it become a crossroads between western, central, and southeastern Europe."
        ),
        GeographyChallenge(
            id: "geo-eu-02",
            worldId: "european-capitals",
            region: "Iberian Peninsula",
            question: "Which European capital is farther west than Madrid and sits near the Atlantic Ocean?",
            context: "The route bends to the western edge of the continent. The city faces the Tagus estuary and opened sea routes during the Age of Discovery.",
            choices: [
                GeographyChoice(id: "a", text: "Lisbon", isCorrect: true, explanation: "Lisbon is Portugal's capital, sits on the Tagus near the Atlantic, and is west of Madrid."),
                GeographyChoice(id: "b", text: "Barcelona", isCorrect: false, explanation: "Barcelona is on the Mediterranean and is not Spain's capital."),
                GeographyChoice(id: "c", text: "Paris", isCorrect: false, explanation: "Paris is much farther north and east than Lisbon."),
                GeographyChoice(id: "d", text: "Rome", isCorrect: false, explanation: "Rome is in Italy and faces the Tyrrhenian Sea, not the Atlantic.")
            ],
            mapClue: "Look for the capital at the mouth of the Tagus, where river traffic meets the Atlantic.",
            mapTargetLabel: "Portugal",
            mapStartX: 0.42,
            mapStartY: 0.46,
            mapTargetX: 0.34,
            mapTargetY: 0.55,
            fieldNote: "Lisbon is one of mainland Europe's westernmost capitals."
        ),
        GeographyChallenge(
            id: "geo-eu-03",
            worldId: "european-capitals",
            region: "Nordic Europe",
            question: "Which capital is built across islands between Lake Mälaren and the Baltic Sea?",
            context: "Your map shows bridges, waterways, and a city spread across an archipelago. It controls the gateway between inland Sweden and the Baltic.",
            choices: [
                GeographyChoice(id: "a", text: "Stockholm", isCorrect: true, explanation: "Stockholm spans many islands where Lake Mälaren meets the Baltic Sea."),
                GeographyChoice(id: "b", text: "Oslo", isCorrect: false, explanation: "Oslo sits at the head of Oslofjord in Norway, not on the Baltic."),
                GeographyChoice(id: "c", text: "Copenhagen", isCorrect: false, explanation: "Copenhagen is on Zealand and Amager, near the Øresund strait."),
                GeographyChoice(id: "d", text: "Helsinki", isCorrect: false, explanation: "Helsinki is coastal and archipelagic, but it is not between Lake Mälaren and the Baltic.")
            ],
            mapClue: "Find the island capital guarding Sweden's freshwater-to-sea passage.",
            mapTargetLabel: "Sweden",
            mapStartX: 0.53,
            mapStartY: 0.30,
            mapTargetX: 0.59,
            mapTargetY: 0.24,
            fieldNote: "Stockholm's waterways shaped its trade, defense, and distinctive city plan."
        ),
        GeographyChallenge(
            id: "geo-eu-04",
            worldId: "european-capitals",
            region: "Balkan Peninsula",
            question: "Which capital lies at the meeting point of the Sava and Danube rivers?",
            context: "Two major rivers form a strategic junction. Empires fought over this city because it controlled routes between central Europe and the Balkans.",
            choices: [
                GeographyChoice(id: "a", text: "Belgrade", isCorrect: true, explanation: "Belgrade, Serbia's capital, sits at the confluence of the Sava and Danube."),
                GeographyChoice(id: "b", text: "Sofia", isCorrect: false, explanation: "Sofia is inland in western Bulgaria and is not on either river."),
                GeographyChoice(id: "c", text: "Sarajevo", isCorrect: false, explanation: "Sarajevo lies in a mountain valley on the Miljacka River."),
                GeographyChoice(id: "d", text: "Skopje", isCorrect: false, explanation: "Skopje is on the Vardar River, not at the Sava-Danube junction.")
            ],
            mapClue: "Trace the Sava east until it flows into the Danube.",
            mapTargetLabel: "Serbia",
            mapStartX: 0.48,
            mapStartY: 0.55,
            mapTargetX: 0.57,
            mapTargetY: 0.58,
            fieldNote: "Belgrade's river junction made it a key fortress city for Roman, Byzantine, Ottoman, and Habsburg power."
        )
    ]

    static func challenges(for worldId: String) -> [GeographyChallenge] {
        switch worldId {
        case "european-capitals": return europeanCapitalsChallenges
        default: return []
        }
    }
}

// MARK: - Math Challenge (pattern-based puzzle)
struct MathChallenge: Identifiable, Codable, Equatable {
    let id: String
    let worldId: String
    let domain: String
    let question: String
    let context: String
    let choices: [MathChoice]
    let patternClue: String
    let ruleExplanation: String
}

struct MathChoice: Codable, Equatable {
    let id: String
    let text: String
    let isCorrect: Bool
    let explanation: String
}

enum MathData {
    static let logicGateChallenges: [MathChallenge] = [
        MathChallenge(
            id: "math-logic-01",
            worldId: "logic-gates",
            domain: "Sequences",
            question: "The gate shows 3, 6, 12, 24, ?. Which number opens it?",
            context: "A vault door doubles its signal strength at every step. Pick the next output before the timer resets.",
            choices: [
                MathChoice(id: "a", text: "30", isCorrect: false, explanation: "Adding 6 only works once. The pattern multiplies each term by 2."),
                MathChoice(id: "b", text: "36", isCorrect: false, explanation: "That would add 12, but the earlier steps are not using a steady addition."),
                MathChoice(id: "c", text: "48", isCorrect: true, explanation: "Correct. Each number doubles: 3, 6, 12, 24, 48."),
                MathChoice(id: "d", text: "72", isCorrect: false, explanation: "72 triples 24. The gate has been doubling, not tripling.")
            ],
            patternClue: "Look at the multiplier between neighboring numbers.",
            ruleExplanation: "Geometric sequences grow by multiplying by the same factor each step. Here the common ratio is 2."
        ),
        MathChallenge(
            id: "math-logic-02",
            worldId: "logic-gates",
            domain: "Ratios",
            question: "A potion mix uses 2 blue drops for every 5 gold drops. How many blue drops are needed for 20 gold drops?",
            context: "The alchemy lock only accepts equivalent ratios. Scale the recipe without changing its balance.",
            choices: [
                MathChoice(id: "a", text: "4", isCorrect: false, explanation: "That scales gold from 5 to 10, not 20."),
                MathChoice(id: "b", text: "8", isCorrect: true, explanation: "Correct. Gold is multiplied by 4, so blue must also be multiplied by 4: 2 x 4 = 8."),
                MathChoice(id: "c", text: "10", isCorrect: false, explanation: "10 blue drops would make the ratio 10:20, which simplifies to 1:2 instead of 2:5."),
                MathChoice(id: "d", text: "15", isCorrect: false, explanation: "15 blue drops makes the mixture far too blue for the 2:5 ratio.")
            ],
            patternClue: "Find how 5 becomes 20, then apply the same scale to 2.",
            ruleExplanation: "Equivalent ratios keep the same relationship by multiplying both parts by the same factor."
        ),
        MathChallenge(
            id: "math-logic-03",
            worldId: "logic-gates",
            domain: "Algebra",
            question: "The console says 4x + 7 = 31. What is x?",
            context: "A power bridge will activate only when you isolate the hidden variable.",
            choices: [
                MathChoice(id: "a", text: "5", isCorrect: false, explanation: "4 x 5 + 7 = 27, which is too low."),
                MathChoice(id: "b", text: "6", isCorrect: true, explanation: "Correct. Subtract 7 to get 24, then divide by 4 to get 6."),
                MathChoice(id: "c", text: "7", isCorrect: false, explanation: "4 x 7 + 7 = 35, which is too high."),
                MathChoice(id: "d", text: "8", isCorrect: false, explanation: "4 x 8 + 7 = 39, farther from 31.")
            ],
            patternClue: "Undo the +7 first, then undo the x4.",
            ruleExplanation: "Solving an equation means applying inverse operations in reverse order while keeping both sides balanced."
        ),
        MathChallenge(
            id: "math-logic-04",
            worldId: "logic-gates",
            domain: "Percent",
            question: "A shield has 80 energy. It loses 25%. How much energy remains?",
            context: "The arena shield drains by a fraction of its current charge. Calculate what survives the hit.",
            choices: [
                MathChoice(id: "a", text: "20", isCorrect: false, explanation: "20 is the amount lost, not the amount remaining."),
                MathChoice(id: "b", text: "55", isCorrect: false, explanation: "25% of 80 is 20, so the remaining energy is not 55."),
                MathChoice(id: "c", text: "60", isCorrect: true, explanation: "Correct. 25% of 80 is 20, and 80 - 20 = 60."),
                MathChoice(id: "d", text: "75", isCorrect: false, explanation: "That subtracts 5 instead of 25% of the total.")
            ],
            patternClue: "25% is one quarter. First find one quarter of 80.",
            ruleExplanation: "A percentage is a part per hundred. Losing 25% means keeping 75%, so 0.75 x 80 = 60."
        )
    ]

    static func challenges(for worldId: String) -> [MathChallenge] {
        switch worldId {
        case "logic-gates": return logicGateChallenges
        default: return []
        }
    }
}

// MARK: - Culture Challenge (tradition-based scenario)
struct CultureChallenge: Identifiable, Codable, Equatable {
    let id: String
    let worldId: String
    let region: String
    let question: String
    let context: String
    let choices: [CultureChoice]
    let traditionClue: String
    let culturalNote: String
}

struct CultureChoice: Codable, Equatable {
    let id: String
    let text: String
    let isCorrect: Bool
    let explanation: String
}

enum CultureData {
    static let heritageKitchenChallenges: [CultureChallenge] = [
        CultureChallenge(
            id: "culture-kitchen-01",
            worldId: "heritage-kitchens",
            region: "Japan",
            question: "At a small ramen shop in Tokyo, what is the most culturally normal way to show you enjoyed the noodles?",
            context: "You are seated at a counter during a busy lunch rush. The cook serves ramen hot, and other customers are eating quickly before returning to work.",
            choices: [
                CultureChoice(id: "a", text: "Slurp the noodles while eating", isCorrect: true, explanation: "Correct. Slurping noodles is common in Japan. It cools the noodles and signals enjoyment, especially in casual ramen and soba settings."),
                CultureChoice(id: "b", text: "Cut every noodle with a spoon", isCorrect: false, explanation: "That is not the usual eating style. Noodles are lifted with chopsticks and eaten directly."),
                CultureChoice(id: "c", text: "Leave the bowl untouched for five minutes", isCorrect: false, explanation: "Ramen is meant to be eaten while hot. Waiting too long changes the texture."),
                CultureChoice(id: "d", text: "Ask for bread to dip in the broth", isCorrect: false, explanation: "Bread is not a typical ramen accompaniment in Japan.")
            ],
            traditionClue: "Listen to the counter. Sound can be a social signal, not only noise.",
            culturalNote: "Etiquette changes by setting: slurping noodles can be polite in a ramen shop, but loud chewing would still be rude in many contexts."
        ),
        CultureChallenge(
            id: "culture-kitchen-02",
            worldId: "heritage-kitchens",
            region: "Morocco",
            question: "A family serves couscous from one shared dish. Which choice best fits traditional hospitality?",
            context: "You are invited to Friday couscous. Everyone gathers around a large plate, and the host offers the best vegetables and meat first.",
            choices: [
                CultureChoice(id: "a", text: "Eat from the section of the dish closest to you", isCorrect: true, explanation: "Correct. In shared-dish meals, it is polite to eat from your own area rather than reaching across the platter."),
                CultureChoice(id: "b", text: "Reach across to take food from the opposite side", isCorrect: false, explanation: "Reaching across the shared dish can feel disrespectful because it crosses into another person's eating space."),
                CultureChoice(id: "c", text: "Refuse the host's first offer without explanation", isCorrect: false, explanation: "Refusing hospitality abruptly can feel cold. If needed, decline gently and thank the host."),
                CultureChoice(id: "d", text: "Start before elders or hosts begin", isCorrect: false, explanation: "Waiting for hosts or elders is a respectful habit in many Moroccan homes.")
            ],
            traditionClue: "Shared food often has invisible borders shaped by respect.",
            culturalNote: "Moroccan hospitality is strongly tied to generosity, family gathering, and making guests feel honored."
        ),
        CultureChallenge(
            id: "culture-kitchen-03",
            worldId: "heritage-kitchens",
            region: "Mexico",
            question: "You are eating tacos at a street stand. What does the tortilla mainly function as?",
            context: "The taquero hands you small corn tortillas filled with meat, onion, cilantro, and salsa. There are no forks on the counter.",
            choices: [
                CultureChoice(id: "a", text: "A practical edible wrapper for hot fillings", isCorrect: true, explanation: "Correct. The tortilla works as both staple food and utensil, holding fillings while adding flavor and texture."),
                CultureChoice(id: "b", text: "A decorative plate that should not be eaten", isCorrect: false, explanation: "The tortilla is central to the meal and is meant to be eaten."),
                CultureChoice(id: "c", text: "A dessert layer served after the filling", isCorrect: false, explanation: "Tortillas are usually savory staples in tacos, not dessert layers."),
                CultureChoice(id: "d", text: "A symbol that replaces all sauces", isCorrect: false, explanation: "Salsas, lime, onion, and cilantro are important companions and vary by region.")
            ],
            traditionClue: "A staple can also be a tool.",
            culturalNote: "Maize has deep Indigenous roots in Mexico, and tortillas remain a daily foundation across regional cuisines."
        ),
        CultureChallenge(
            id: "culture-kitchen-04",
            worldId: "heritage-kitchens",
            region: "Ethiopia",
            question: "In an Ethiopian meal, why is injera placed under stews and also torn by hand?",
            context: "Several stews are served on a wide layer of injera. Diners tear extra pieces and use them to scoop bites from the shared platter.",
            choices: [
                CultureChoice(id: "a", text: "It is both plate and utensil", isCorrect: true, explanation: "Correct. Injera holds the stews and is torn to scoop them, absorbing flavors as the meal continues."),
                CultureChoice(id: "b", text: "It is only decoration", isCorrect: false, explanation: "Injera is eaten throughout the meal and is central to the dining experience."),
                CultureChoice(id: "c", text: "It is used to cool tea", isCorrect: false, explanation: "Injera is paired with stews, not used for tea."),
                CultureChoice(id: "d", text: "It is left for the server", isCorrect: false, explanation: "The base injera is often the most flavorful part because it absorbs sauces.")
            ],
            traditionClue: "The tableware is edible.",
            culturalNote: "Sharing injera and stews supports a communal style of eating, with attention to generosity and togetherness."
        )
    ]

    static func challenges(for worldId: String) -> [CultureChallenge] {
        switch worldId {
        case "heritage-kitchens": return heritageKitchenChallenges
        default: return []
        }
    }
}

// MARK: - Business Challenge (decision-based scenario)
struct BusinessChallenge: Identifiable, Codable, Equatable {
    let id: String
    let worldId: String
    let domain: String
    let question: String
    let context: String
    let choices: [BusinessChoice]
    let marketSignal: String
    let lesson: String
}

struct BusinessChoice: Codable, Equatable {
    let id: String
    let text: String
    let isCorrect: Bool
    let explanation: String
}

enum BusinessData {
    static let founderGuildChallenges: [BusinessChallenge] = [
        BusinessChallenge(
            id: "business-founder-01",
            worldId: "founder-guild",
            domain: "Customer Discovery",
            question: "You have two weeks before building. What should the founder do first?",
            context: "A small team wants to launch a study-planning app. They have a feature list, but no paying users yet.",
            choices: [
                BusinessChoice(id: "a", text: "Interview target users about painful study moments", isCorrect: true, explanation: "Correct. Real customer discovery reduces the risk of building features no one needs."),
                BusinessChoice(id: "b", text: "Spend the full budget on a logo and launch video", isCorrect: false, explanation: "Branding can help later, but it does not prove the problem is worth solving."),
                BusinessChoice(id: "c", text: "Build every planned feature before showing anyone", isCorrect: false, explanation: "That delays feedback and increases waste if the assumptions are wrong."),
                BusinessChoice(id: "d", text: "Copy the largest competitor's pricing page", isCorrect: false, explanation: "Competitor research is useful, but copying does not reveal your own customers' needs.")
            ],
            marketSignal: "No revenue yet, unclear pain point, small runway.",
            lesson: "Good startups test demand before scaling product. Interviews, preorders, pilots, and usage data beat guesses."
        ),
        BusinessChallenge(
            id: "business-founder-02",
            worldId: "founder-guild",
            domain: "Pricing",
            question: "A beta customer says the product saves their team five hours a week. What pricing move is strongest?",
            context: "The app costs little to serve, but support takes time. Customers are small businesses, not consumers.",
            choices: [
                BusinessChoice(id: "a", text: "Anchor price to the value saved and test a paid pilot", isCorrect: true, explanation: "Correct. B2B pricing should connect to business value and validate willingness to pay."),
                BusinessChoice(id: "b", text: "Make it free forever to avoid awkward sales calls", isCorrect: false, explanation: "Free users can create activity without proving a sustainable business."),
                BusinessChoice(id: "c", text: "Set the lowest possible price because software is cheap to copy", isCorrect: false, explanation: "Low pricing can signal low value and may not cover support or acquisition costs."),
                BusinessChoice(id: "d", text: "Never discuss price until the product is perfect", isCorrect: false, explanation: "Price feedback is part of product learning, especially for business tools.")
            ],
            marketSignal: "Clear time savings, small support burden, business buyer.",
            lesson: "Price is a strategy signal. Sustainable pricing considers customer value, costs, market alternatives, and sales motion."
        ),
        BusinessChallenge(
            id: "business-founder-03",
            worldId: "founder-guild",
            domain: "Cash Flow",
            question: "Sales are growing, but the company is almost out of cash. Which metric needs attention immediately?",
            context: "Customers pay invoices after 60 days. Contractors and software bills are due every month.",
            choices: [
                BusinessChoice(id: "a", text: "Cash conversion and runway", isCorrect: true, explanation: "Correct. A business can grow on paper and still fail if cash arrives too late."),
                BusinessChoice(id: "b", text: "Office decoration budget", isCorrect: false, explanation: "Office feel may affect morale, but it is not the urgent survival metric."),
                BusinessChoice(id: "c", text: "Number of social followers", isCorrect: false, explanation: "Followers are not enough if they do not turn into timely cash."),
                BusinessChoice(id: "d", text: "How many features competitors launched", isCorrect: false, explanation: "Competitive awareness matters, but cash timing is the immediate risk.")
            ],
            marketSignal: "Revenue up, delayed payments, monthly expenses due now.",
            lesson: "Profit and cash are different. Runway, payment terms, burn rate, and collections can decide whether a business survives."
        ),
        BusinessChallenge(
            id: "business-founder-04",
            worldId: "founder-guild",
            domain: "Strategy",
            question: "A bigger competitor adds your headline feature. What is the smartest response?",
            context: "Your small product has loyal users in one niche. The competitor has a broader platform but weak onboarding for that niche.",
            choices: [
                BusinessChoice(id: "a", text: "Double down on the niche workflow and customer intimacy", isCorrect: true, explanation: "Correct. A focused company can win by serving a specific job better than a broad platform."),
                BusinessChoice(id: "b", text: "Panic and rebuild the entire product this week", isCorrect: false, explanation: "Reactive pivots can destroy what existing customers already value."),
                BusinessChoice(id: "c", text: "Lower the price to zero immediately", isCorrect: false, explanation: "Discounting alone rarely beats a stronger product or clearer positioning."),
                BusinessChoice(id: "d", text: "Stop talking to customers until the threat passes", isCorrect: false, explanation: "Customer contact is most valuable when the market changes.")
            ],
            marketSignal: "Broad competitor, loyal niche users, differentiated workflow.",
            lesson: "Strategy is choosing where to win. Focus, switching costs, trust, distribution, and speed can matter more than feature parity."
        )
    ]

    static func challenges(for worldId: String) -> [BusinessChallenge] {
        switch worldId {
        case "founder-guild": return founderGuildChallenges
        default: return []
        }
    }
}

// MARK: - Health Challenge (habit-based scenario)
struct HealthChallenge: Identifiable, Codable, Equatable {
    let id: String
    let worldId: String
    let domain: String
    let question: String
    let context: String
    let choices: [HealthChoice]
    let bodySignal: String
    let habitLesson: String
}

struct HealthChoice: Codable, Equatable {
    let id: String
    let text: String
    let isCorrect: Bool
    let explanation: String
}

enum HealthData {
    static let energyClinicChallenges: [HealthChallenge] = [
        HealthChallenge(
            id: "health-energy-01",
            worldId: "energy-clinic",
            domain: "Sleep",
            question: "You slept badly and feel wired at 10 PM. What is the strongest next move?",
            context: "Tomorrow matters, but your brain is chasing one more video. The goal is to make sleep easier without turning bedtime into a battle.",
            choices: [
                HealthChoice(id: "a", text: "Dim lights, put the phone away, and repeat a calm wind-down", isCorrect: true, explanation: "Correct. A consistent low-light routine helps cue sleep and removes the biggest source of stimulation."),
                HealthChoice(id: "b", text: "Drink strong coffee to push through tomorrow", isCorrect: false, explanation: "Caffeine late in the day can worsen the next night and deepen the cycle."),
                HealthChoice(id: "c", text: "Stay in bed scrolling until you feel sleepy", isCorrect: false, explanation: "Scrolling keeps attention and light exposure high, which can delay sleep."),
                HealthChoice(id: "d", text: "Do an intense workout right before bed", isCorrect: false, explanation: "Exercise is useful, but hard sessions too close to bedtime can be stimulating for some people.")
            ],
            bodySignal: "Wired but tired, bright screen, late-night stimulation.",
            habitLesson: "Sleep improves when the body gets repeated cues: dim light, lower stimulation, regular timing, and a bed associated with rest."
        ),
        HealthChallenge(
            id: "health-energy-02",
            worldId: "energy-clinic",
            domain: "Nutrition",
            question: "You skipped lunch and now want the fastest snack. Which option gives steadier energy?",
            context: "Your next study block is 90 minutes. You need something practical that reduces the crash risk.",
            choices: [
                HealthChoice(id: "a", text: "Greek yogurt with fruit and nuts", isCorrect: true, explanation: "Correct. Protein, fiber, and fat slow digestion and support steadier energy."),
                HealthChoice(id: "b", text: "A large candy bag only", isCorrect: false, explanation: "Quick sugar can help briefly, but alone it often creates a sharper energy swing."),
                HealthChoice(id: "c", text: "Skip food and rely on willpower", isCorrect: false, explanation: "Hunger makes focus harder. A small balanced snack is usually smarter than forcing it."),
                HealthChoice(id: "d", text: "Only a sugary drink", isCorrect: false, explanation: "Liquid sugar can be fast, but it is not a very stable fuel by itself.")
            ],
            bodySignal: "Hunger, low focus, upcoming long effort.",
            habitLesson: "For most people, pairing protein or fiber with carbohydrates gives more stable energy than isolated sugar."
        ),
        HealthChallenge(
            id: "health-energy-03",
            worldId: "energy-clinic",
            domain: "Movement",
            question: "You have been sitting for three hours. What is the best small reset before continuing?",
            context: "You do not have time for a full workout. The goal is to wake up the body and reduce stiffness.",
            choices: [
                HealthChoice(id: "a", text: "Take a brisk 5-minute walk and loosen shoulders and hips", isCorrect: true, explanation: "Correct. Short movement breaks can improve alertness and reduce sitting-related stiffness."),
                HealthChoice(id: "b", text: "Stay still until the whole project is finished", isCorrect: false, explanation: "Long uninterrupted sitting can make energy and posture worse."),
                HealthChoice(id: "c", text: "Do nothing because short breaks do not count", isCorrect: false, explanation: "Small breaks count. Consistency beats all-or-nothing thinking."),
                HealthChoice(id: "d", text: "Stretch aggressively through pain", isCorrect: false, explanation: "Movement should not force pain. Gentle range and walking are better resets.")
            ],
            bodySignal: "Stiff back, shallow breathing, fading attention.",
            habitLesson: "Tiny movement snacks are useful: walking, mobility, and posture changes can compound across the day."
        ),
        HealthChallenge(
            id: "health-energy-04",
            worldId: "energy-clinic",
            domain: "Stress",
            question: "A message spikes your stress before a study session. What helps most right now?",
            context: "Your heart rate jumps and your attention narrows. You need a fast reset that does not pretend the problem vanished.",
            choices: [
                HealthChoice(id: "a", text: "Do two minutes of slow breathing, then write the next concrete action", isCorrect: true, explanation: "Correct. Breathing can reduce arousal, and a concrete next action turns worry into a controllable step."),
                HealthChoice(id: "b", text: "Open five more apps to distract yourself", isCorrect: false, explanation: "Distraction can snowball into avoidance and more cognitive noise."),
                HealthChoice(id: "c", text: "Replay the message until you feel certain", isCorrect: false, explanation: "Rumination usually increases stress without improving the plan."),
                HealthChoice(id: "d", text: "Ignore every body signal for the rest of the day", isCorrect: false, explanation: "Signals are information. A short reset can help you respond instead of react.")
            ],
            bodySignal: "Fast pulse, tense jaw, racing thoughts.",
            habitLesson: "Stress skills work best when they pair body regulation with one clear behavior: breathe, name the issue, choose the next action."
        )
    ]

    static func challenges(for worldId: String) -> [HealthChallenge] {
        switch worldId {
        case "energy-clinic": return energyClinicChallenges
        default: return []
        }
    }
}

// MARK: - Subject Progress
struct SubjectProgress: Codable, Equatable {
    var currentWorldId: String? = nil
    var completedChallengeIds: [String] = []
    var worldScores: [String: Int] = [:]
    var totalHistoryXP: Int = 0
}

struct DailyQuest: Equatable {
    let subject: Subject
    let completed: Int
    let target: Int

    var title: String {
        switch subject {
        case .languages: return "Decode the next phrase"
        case .history: return "Recover a real timeline"
        case .science: return "Run a field experiment"
        case .geography: return "Map the hidden route"
        case .math: return "Solve the gate pattern"
        case .culture: return "Unlock a living tradition"
        case .business: return "Make a sharper decision"
        case .health: return "Train a better habit"
        }
    }

    var rewardName: String {
        switch subject {
        case .languages: return "Harbor Key"
        case .history: return "Archive Seal"
        case .science: return "Lab Spark"
        case .geography: return "Compass Shard"
        case .math: return "Logic Rune"
        case .culture: return "Festival Token"
        case .business: return "Guild Coin"
        case .health: return "Vitality Leaf"
        }
    }

    var reward: String { "+\(target * 3) XP · \(rewardName)" }
    var progressText: String { "\(min(completed, target))/\(target) encounters" }
    var progress: Double { min(1, Double(completed) / Double(max(1, target))) }
}

struct StreakChest: Equatable {
    let subject: Subject
    let streak: Int
    let progress: Double
    let rewardXP: Int
    let rewardGems: Int
    let isReady: Bool
    let isClaimedToday: Bool

    var title: String {
        if isClaimedToday { return "Chest Claimed" }
        return isReady ? "Streak Chest Ready" : "Streak Chest"
    }

    var subtitle: String {
        if isClaimedToday { return "Come back tomorrow for a stronger reward." }
        if isReady { return "Claim today's \(subject.displayName) prize." }
        return "Finish the Daily Quest to open it."
    }

    var rewardText: String {
        "+\(rewardXP) XP · +\(rewardGems) gems"
    }

    var accessibilityLabel: String {
        "\(title). \(subtitle). Reward \(rewardText)."
    }
}

struct DailyCombo: Equatable {
    let subject: Subject
    let correctToday: Int
    let target: Int

    var currentStep: Int {
        correctToday % target
    }

    var visibleStep: Int {
        currentStep == 0 && correctToday > 0 ? target : currentStep
    }

    var completedCombos: Int {
        correctToday / target
    }

    var progress: Double {
        Double(visibleStep) / Double(max(1, target))
    }

    var title: String {
        completedCombos == 0 ? "Build a Focus Combo" : "Focus Combo x\(completedCombos)"
    }

    var subtitle: String {
        if currentStep == 0, correctToday > 0 {
            return "Combo banked. Start the next chain for another bonus."
        }
        let remaining = max(1, target - currentStep)
        return "\(remaining) correct \(remaining == 1 ? "move" : "moves") to trigger the next reward."
    }

    var rewardText: String {
        "+5 XP · +1 gem"
    }

    var progressText: String {
        "\(visibleStep)/\(target) chain"
    }

    var accessibilityLabel: String {
        "\(title). \(subtitle). Progress \(progressText). Reward \(rewardText)."
    }
}

struct DailyBoss: Equatable {
    let subject: Subject
    let correctToday: Int
    let target: Int
    let isDefeatedToday: Bool

    var title: String {
        isDefeatedToday ? "Boss Defeated" : "\(subject.bossName) Appears"
    }

    var subtitle: String {
        if isDefeatedToday { return "Reward claimed. A new boss returns tomorrow." }
        if isReady { return "Your combo chain is charged. Finish the boss for a bigger prize." }
        let remaining = max(0, target - correctToday)
        return "\(remaining) correct \(remaining == 1 ? "move" : "moves") to charge the boss encounter."
    }

    var isReady: Bool {
        correctToday >= target
    }

    var progress: Double {
        min(1, Double(correctToday) / Double(max(1, target)))
    }

    var rewardXP: Int { 35 }
    var rewardGems: Int { 3 }
    var rewardText: String { "+\(rewardXP) XP · +\(rewardGems) gems" }
    var progressText: String { "\(min(correctToday, target))/\(target) charge" }

    var accessibilityLabel: String {
        "\(title). \(subtitle). Progress \(progressText). Reward \(rewardText)."
    }
}

struct MysteryRelic: Identifiable, Equatable {
    let id: String
    let subject: Subject
    let name: String
    let emoji: String
    let lore: String
    let rarity: String

    var title: String { "\(emoji) \(name)" }
    var rewardLine: String { "+18 XP · +2 gems · \(rarity)" }
}

struct DailyRelic: Equatable {
    let relic: MysteryRelic
    let correctToday: Int
    let target: Int
    let isClaimedToday: Bool
    let alreadyCollected: Bool

    var isReady: Bool {
        correctToday >= target
    }

    var progress: Double {
        min(1, Double(correctToday) / Double(max(1, target)))
    }

    var title: String {
        if isClaimedToday { return "Relic Secured" }
        return isReady ? "Mystery Relic Ready" : "Mystery Relic"
    }

    var subtitle: String {
        if isClaimedToday { return "\(relic.name) is stored in your Reward Vault." }
        if isReady { return "Open today's find from \(relic.subject.displayName)." }
        let remaining = max(0, target - correctToday)
        return "\(remaining) correct \(remaining == 1 ? "move" : "moves") to reveal today's relic."
    }

    var progressText: String {
        "\(min(correctToday, target))/\(target) reveal"
    }

    var rewardText: String {
        alreadyCollected ? "+18 XP · +2 gems" : relic.rewardLine
    }

    var accessibilityLabel: String {
        "\(title). \(subtitle). Progress \(progressText). Reward \(rewardText)."
    }
}

struct DailyAdventure: Equatable {
    let subject: Subject
    let world: PlayableWorld?
    let xp: Int
    let streak: Int

    var title: String {
        if let world {
            return "\(world.name) Run"
        }
        return "Language Harbor Run"
    }

    var objective: String {
        switch subject {
        case .languages:
            return "Clear 5 mixed prompts to fill your fluency drop meter."
        case .history:
            return "Explore a real turning point, choose carefully, then read what actually happened."
        case .science:
            return "Solve one field mission and collect the evidence note."
        case .geography:
            return "Follow the clue trail from map hint to correct place."
        case .math:
            return "Break the pattern lock before the next gate closes."
        case .culture:
            return "Read the scene, choose the respectful move, and keep the context."
        case .business:
            return "Make one founder-grade decision using the signal, not the noise."
        case .health:
            return "Practice one useful habit decision you can apply today."
        }
    }

    var rewardLine: String {
        let streakBonus = streak > 1 ? " · streak x\(min(5, streak))" : ""
        return "+30 XP · \(rewardName)\(streakBonus)"
    }

    var rewardName: String {
        switch subject {
        case .languages: return "Fluency Drop"
        case .history: return "Chronicle Page"
        case .science: return "Discovery Spark"
        case .geography: return "Trail Marker"
        case .math: return "Puzzle Core"
        case .culture: return "Culture Stamp"
        case .business: return "Decision Token"
        case .health: return "Habit Charge"
        }
    }

    var unlockHint: String {
        if let world, !world.isUnlocked(withXP: xp) {
            return "\(world.xpRemaining(withXP: xp)) XP until this world opens."
        }
        if let next = subject.nextLockedWorld(withXP: xp) {
            return "\(next.xpRemaining(withXP: xp)) XP to unlock \(next.name)."
        }
        return "Complete today's run to push your level track forward."
    }
}

struct WorldJournal: Equatable {
    let subject: Subject
    let world: PlayableWorld?
    let sceneTitle: String
    let sceneText: String
    let objective: String
    let choiceText: String
    let rewardText: String
    let progress: Double
    let progressText: String
    let nextUnlockText: String

    var title: String {
        world.map { "\($0.name) Journal" } ?? "Language Harbor Journal"
    }

    var eyebrow: String {
        subject == .languages ? "Playable Lesson" : "\(subject.mapTitle) Expedition"
    }

    var iconText: String {
        world?.emoji ?? "💧"
    }

    var accessibilityLabel: String {
        "\(title). \(sceneTitle). \(sceneText). Objective: \(objective). Choice: \(choiceText). \(progressText). Reward \(rewardText). \(nextUnlockText)."
    }
}

struct DailyWorldChapter: Identifiable, Equatable {
    let subject: Subject
    let world: PlayableWorld?
    let step: Int
    let isCurrent: Bool

    var id: String {
        "\(step)-\(subject.rawValue)-\(world?.id ?? "harbor")"
    }

    var title: String {
        if let world { return world.name }
        return "Language Harbor"
    }

    var subtitle: String {
        switch subject {
        case .languages: return "Speak and type a useful phrase"
        case .history: return "Enter a grounded turning point"
        case .science: return "Collect an evidence note"
        case .geography: return "Follow a real map clue"
        case .math: return "Crack a pattern gate"
        case .culture: return "Read context before acting"
        case .business: return "Choose from signal, not hype"
        case .health: return "Pick a practical habit move"
        }
    }
}

struct DailyWorldEvent: Equatable {
    let title: String
    let subtitle: String
    let chapters: [DailyWorldChapter]
    let completedSteps: Int

    var progress: Double {
        guard !chapters.isEmpty else { return 0 }
        return min(1, Double(completedSteps) / Double(chapters.count))
    }

    var progressText: String {
        "\(min(completedSteps, chapters.count))/\(chapters.count) worlds"
    }

    var rewardText: String {
        "+45 XP · +4 gems · Crown"
    }

    var currentChapter: DailyWorldChapter? {
        guard !chapters.isEmpty else { return nil }
        return chapters[min(completedSteps, chapters.count - 1)]
    }

    var accessibilityLabel: String {
        "\(title). \(subtitle). Progress \(progressText). Reward \(rewardText)."
    }
}

struct CampaignEncounterPreview: Equatable {
    let title: String
    let context: String
    let clue: String
}

struct CampaignSpotlight: Equatable {
    let subject: Subject
    let world: PlayableWorld?
    let title: String
    let subtitle: String
    let encounter: CampaignEncounterPreview
    let progress: Double
    let progressText: String
    let rewardText: String
    let ctaTitle: String
    let systemImage: String
    let isComplete: Bool

    var accessibilityLabel: String {
        "\(title). \(subtitle). Next encounter: \(encounter.title). \(progressText). Reward \(rewardText)."
    }
}

enum QuestBoardMissionKind: String, Equatable {
    case dailyAdventure
    case languageReview
    case activeWorld
    case nextUnlock
    case roulette
}

enum RecommendedRunAction: String, Equatable {
    case dailyAdventure
    case claimStreakChest
    case nextUnlock
    case roulette
}

enum TrainingPlanAction: String, Equatable {
    case recommendedRun
    case masteryCatchUp
    case worldTour
}

struct RecommendedRun: Equatable {
    let action: RecommendedRunAction
    let title: String
    let subtitle: String
    let reward: String
    let ctaTitle: String
    let systemImage: String
    let subject: Subject
    let worldId: String?
    let progress: Double

    var accessibilityLabel: String {
        "\(title). \(subtitle). Reward \(reward). \(ctaTitle)."
    }
}

struct TrainingPlanCard: Identifiable, Equatable {
    let id: String
    let action: TrainingPlanAction
    let eyebrow: String
    let title: String
    let subtitle: String
    let reward: String
    let systemImage: String
    let subject: Subject
    let progress: Double
    let isPrimary: Bool

    var progressText: String {
        "\(Int((min(1, max(0, progress)) * 100).rounded()))%"
    }

    var accessibilityLabel: String {
        "\(eyebrow). \(title). \(subtitle). Reward \(reward). Progress \(progressText)."
    }
}

struct DailyTrainingPlan: Equatable {
    let cards: [TrainingPlanCard]

    var title: String { "Daily Training Plan" }
    var subtitle: String {
        guard let primary = cards.first else { return "Pick a route to start learning." }
        return "Best next move: \(primary.title)"
    }
    var progressText: String {
        guard !cards.isEmpty else { return "0 routes" }
        return "\(cards.count) live routes"
    }
    var accessibilityLabel: String {
        "\(title). \(subtitle). \(progressText)."
    }
}

struct QuestRouletteOption: Identifiable, Equatable {
    let subject: Subject
    let world: PlayableWorld?
    let title: String
    let subtitle: String
    let reward: String
    let systemImage: String

    var id: String { "\(subject.rawValue)-\(world?.id ?? "harbor")" }
    var worldId: String? { world?.id }
    var accessibilityLabel: String {
        "\(title). \(subtitle). Reward \(reward)."
    }
}

struct QuestRoulette: Equatable {
    let options: [QuestRouletteOption]
    let featuredOptions: [QuestRouletteOption]
    let spinSeed: Int

    var title: String { "Quest Roulette" }
    var subtitle: String {
        "Spin across languages, history, science, maps, math, culture, business, and health."
    }
    var progressText: String { "\(options.count) live routes" }
    var rewardText: String { "+30 XP · +2 gems · Surprise stamp" }
    var ctaTitle: String { "Spin" }
    var pickedOption: QuestRouletteOption? {
        guard !options.isEmpty else { return nil }
        return options[abs(spinSeed) % options.count]
    }
    var accessibilityLabel: String {
        "\(title). \(subtitle). \(progressText). Reward \(rewardText)."
    }
}

struct QuestBoardMission: Identifiable, Equatable {
    let id: String
    let kind: QuestBoardMissionKind
    let title: String
    let subtitle: String
    let reward: String
    let systemImage: String
    let subject: Subject
    let worldId: String?
    let progress: Double

    var accessibilityLabel: String {
        "\(title). \(subtitle). Reward \(reward)."
    }
}

struct WorldRewardBadge: Identifiable, Equatable {
    let subject: Subject
    let world: PlayableWorld
    let isEarned: Bool
    let xpRemaining: Int

    var id: String { "\(subject.rawValue)-\(world.id)" }
    var title: String { world.rewardName }
    var subtitle: String {
        isEarned ? "\(subject.displayName) unlocked" : "\(xpRemaining) XP left"
    }
    var systemImage: String {
        isEarned ? "seal.fill" : "lock.fill"
    }
}

struct RelicVaultItem: Identifiable, Equatable {
    let relic: MysteryRelic
    let isCollected: Bool

    var id: String { relic.id }
    var subtitle: String {
        isCollected ? "\(relic.rarity) collected" : "Hidden relic"
    }
}

enum RewardShopItemKind: String, Codable, Equatable {
    case avatarAura
    case mapSkin
    case studyTrail
}

struct RewardShopItem: Identifiable, Equatable {
    let id: String
    let kind: RewardShopItemKind
    let name: String
    let emoji: String
    let subject: Subject
    let costGems: Int
    let requirementText: String
    let isUnlocked: Bool
    let isOwned: Bool
    let isEquipped: Bool

    var title: String { "\(emoji) \(name)" }
    var statusText: String {
        if isEquipped { return "Equipped" }
        if isOwned { return "Owned" }
        if isUnlocked { return "\(costGems) gems" }
        return requirementText
    }
    var ctaTitle: String {
        if isEquipped { return "Equipped" }
        if isOwned { return "Equip" }
        if isUnlocked { return "Unlock" }
        return "Locked"
    }
    var systemImage: String {
        switch kind {
        case .avatarAura: return "sparkles"
        case .mapSkin: return "map.fill"
        case .studyTrail: return "point.3.connected.trianglepath.dotted"
        }
    }
    var accessibilityLabel: String {
        "\(title). \(statusText). \(ctaTitle)."
    }
}

struct RewardShop: Equatable {
    let gems: Int
    let items: [RewardShopItem]
    let featuredItem: RewardShopItem?

    var title: String { "Reward Shop" }
    var subtitle: String {
        if let featuredItem {
            if featuredItem.isEquipped { return "\(featuredItem.name) is active on your profile." }
            if featuredItem.isOwned { return "Equip \(featuredItem.name) to personalize your next run." }
            if featuredItem.isUnlocked { return "Spend gems on visible cosmetics earned through study." }
            return "Keep learning to reveal the next cosmetic reward."
        }
        return "Cosmetics appear as you level up, earn stamps, and collect relics."
    }
    var ownedCount: Int { items.filter(\.isOwned).count }
    var totalCount: Int { items.count }
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(ownedCount) / Double(totalCount)
    }
    var progressText: String { "\(ownedCount)/\(totalCount) owned" }
    var affordabilityText: String {
        guard let featuredItem, featuredItem.isUnlocked, !featuredItem.isOwned else { return "\(gems) gems" }
        let remaining = max(0, featuredItem.costGems - gems)
        return remaining == 0 ? "Ready to unlock" : "\(remaining) gems needed"
    }
    var accessibilityLabel: String {
        "\(title). \(subtitle). \(progressText). \(affordabilityText)."
    }
}

struct WorldCompletionReward: Identifiable, Equatable {
    let subject: Subject
    let world: PlayableWorld
    let completedMissions: Int
    let totalMissions: Int
    let nextWorld: PlayableWorld?
    let nextWorldXPRemaining: Int?

    var id: String { "\(subject.rawValue)-\(world.id)-complete" }
    var title: String { "\(world.name) Cleared" }
    var rewardLine: String { "+40 XP · +4 gems · \(world.rewardName)" }
    var progressText: String { "\(min(completedMissions, totalMissions))/\(totalMissions) missions complete" }
    var nextStepText: String {
        if let nextWorld {
            if let nextWorldXPRemaining, nextWorldXPRemaining > 0 {
                return "\(nextWorldXPRemaining) XP to unlock \(nextWorld.name)."
            }
            return "\(nextWorld.name) is ready for your next run."
        }
        return "Subject route cleared. Spin Quest Roulette for a fresh world."
    }
    var accessibilityLabel: String {
        "\(title). \(progressText). Reward \(rewardLine). \(nextStepText)"
    }
}

struct WorldPathStop: Identifiable, Equatable {
    let subject: Subject
    let world: PlayableWorld
    let index: Int
    let isSelected: Bool
    let isLocked: Bool
    let completedChallenges: Int
    let totalChallenges: Int
    let xpRemaining: Int

    var id: String { "\(subject.rawValue)-\(world.id)" }
    var stepLabel: String { "Stage \(index + 1)" }
    var progressText: String {
        guard totalChallenges > 0 else { return isLocked ? "\(xpRemaining) XP to unlock" : "Ready to explore" }
        return "\(min(completedChallenges, totalChallenges))/\(totalChallenges) missions"
    }
    var statusText: String {
        if isSelected { return "Active" }
        if isLocked { return "\(xpRemaining) XP" }
        return "Playable"
    }
    var progress: Double {
        guard totalChallenges > 0 else { return isLocked ? 0 : 1 }
        return min(1, Double(completedChallenges) / Double(totalChallenges))
    }
    var accessibilityLabel: String {
        "\(world.name), \(stepLabel), \(statusText), \(progressText)"
    }
}

struct AtlasSubjectProgress: Identifiable, Equatable {
    let subject: Subject
    let openedWorlds: Int
    let totalWorlds: Int
    let completedMissions: Int
    let totalMissions: Int
    let nextWorld: PlayableWorld?
    let xpRemaining: Int

    var id: String { subject.rawValue }
    var progress: Double {
        guard totalWorlds > 0 else { return subject == .languages ? 1 : 0 }
        return Double(openedWorlds) / Double(totalWorlds)
    }
    var title: String { subject.displayName }
    var routeText: String {
        if subject == .languages { return "Language Harbor" }
        return "\(openedWorlds)/\(totalWorlds) worlds open"
    }
    var missionText: String {
        if subject == .languages { return "Speak, type, review" }
        guard totalMissions > 0 else { return "Route ready" }
        return "\(completedMissions)/\(totalMissions) missions"
    }
    var nextText: String {
        if subject == .languages { return "Review gate ready" }
        if let nextWorld {
            return "\(xpRemaining) XP to \(nextWorld.name)"
        }
        return "Route fully open"
    }
    var accessibilityLabel: String {
        "\(title). \(routeText). \(missionText). \(nextText)."
    }
}

struct MasteryLeagueStanding: Identifiable, Equatable {
    let rank: Int
    let subject: Subject
    let score: Int
    let completedMissions: Int
    let totalMissions: Int
    let openedWorlds: Int
    let totalWorlds: Int
    let collectedRelics: Int
    let isSelected: Bool

    var id: String { subject.rawValue }
    var title: String { subject.displayName }
    var progress: Double {
        guard totalMissions > 0 else {
            return totalWorlds == 0 ? min(1, Double(score) / 100.0) : Double(openedWorlds) / Double(max(1, totalWorlds))
        }
        return min(1, Double(completedMissions) / Double(totalMissions))
    }
    var rankText: String { "#\(rank)" }
    var scoreText: String { "\(score) pts" }
    var detailText: String {
        if subject == .languages {
            return "\(completedMissions)/\(totalMissions) daily reps · \(collectedRelics) relics"
        }
        return "\(completedMissions)/\(totalMissions) missions · \(openedWorlds)/\(totalWorlds) worlds"
    }
    var accessibilityLabel: String {
        "\(rankText), \(title), \(scoreText), \(detailText)"
    }
}

struct MasteryLeague: Equatable {
    let standings: [MasteryLeagueStanding]
    let selectedStanding: MasteryLeagueStanding?
    let catchUpTarget: MasteryLeagueStanding?

    var title: String { "Mastery League" }
    var subtitle: String {
        if let selectedStanding {
            return "\(selectedStanding.subject.displayName) is \(selectedStanding.rankText). Keep every domain climbing."
        }
        return "Rank every learning domain by progress, worlds, and relics."
    }
    var topThree: [MasteryLeagueStanding] { Array(standings.prefix(3)) }
    var catchUpTitle: String {
        guard let catchUpTarget else { return "Spin a fresh domain" }
        return "Boost \(catchUpTarget.subject.displayName)"
    }
    var catchUpSubtitle: String {
        guard let catchUpTarget else { return "All domains are moving. Pick any world next." }
        return "\(catchUpTarget.scoreText) · \(catchUpTarget.detailText)"
    }
    var accessibilityLabel: String {
        "\(title). \(subtitle). \(catchUpTitle)."
    }
}

struct LearningPassportStamp: Identifiable, Equatable {
    let subject: Subject
    let title: String
    let subtitle: String
    let systemImage: String
    let progress: Double
    let isEarned: Bool

    var id: String { subject.rawValue }
    var progressText: String { isEarned ? "Stamped" : "\(Int((min(1, max(0, progress)) * 100).rounded()))%" }
    var accessibilityLabel: String {
        "\(title), \(subtitle), \(progressText)"
    }
}

struct LearningPassport: Equatable {
    let stamps: [LearningPassportStamp]
    let nextStamp: LearningPassportStamp?

    var earnedCount: Int { stamps.filter(\.isEarned).count }
    var totalCount: Int { stamps.count }
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(earnedCount) / Double(totalCount)
    }
    var progressText: String { "\(earnedCount)/\(totalCount) stamps" }
    var title: String { "Learning Passport" }
    var subtitle: String {
        if earnedCount == totalCount {
            return "Every domain has a stamp. Keep clearing worlds for rarer rewards."
        }
        return "Collect one stamp in every domain to turn study into a world tour."
    }
    var ctaTitle: String {
        guard let nextStamp else { return "Spin a World" }
        return "Stamp \(nextStamp.subject.displayName)"
    }
    var ctaSubtitle: String {
        nextStamp?.subtitle ?? "All domains stamped. Quest Roulette is ready."
    }
    var accessibilityLabel: String {
        "\(title). \(subtitle). \(progressText). \(ctaTitle)."
    }
}

struct KnowledgeCodexEntry: Identifiable, Equatable {
    let id: String
    let subject: Subject
    let worldName: String?
    let title: String
    let subtitle: String
    let body: String
    let source: String
    let systemImage: String
    let isUnlocked: Bool

    var displayTitle: String { isUnlocked ? title : "Hidden Lesson" }
    var displayBody: String { isUnlocked ? body : "Complete this encounter to add the lesson to your codex." }
    var statusText: String { isUnlocked ? "Collected" : "Locked" }
    var accessibilityLabel: String {
        "\(displayTitle). \(subtitle). \(statusText). \(displayBody)"
    }
}

struct KnowledgeCodex: Equatable {
    let entries: [KnowledgeCodexEntry]
    let featuredEntries: [KnowledgeCodexEntry]

    var unlockedCount: Int { entries.filter(\.isUnlocked).count }
    var totalCount: Int { entries.count }
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalCount)
    }
    var title: String { "Knowledge Codex" }
    var progressText: String { "\(unlockedCount)/\(totalCount) lessons" }
    var subtitle: String {
        if unlockedCount == 0 {
            return "Every completed mission becomes a collectible lesson card."
        }
        return "Review the facts, rules, and practical ideas earned from your runs."
    }
    var accessibilityLabel: String {
        "\(title). \(subtitle). \(progressText)."
    }
}

extension Subject {
    var bossName: String {
        switch self {
        case .languages: return "Grammar Kraken"
        case .history: return "Timeline Warden"
        case .science: return "Entropy Core"
        case .geography: return "Lost Compass"
        case .math: return "Pattern Hydra"
        case .culture: return "Etiquette Phantom"
        case .business: return "Market Mirage"
        case .health: return "Habit Breaker"
        }
    }

    var mysteryRelics: [MysteryRelic] {
        switch self {
        case .languages:
            return [
                MysteryRelic(id: "languages-phrase-compass", subject: self, name: "Phrase Compass", emoji: "🧭", lore: "Points toward the next useful sentence before you need it.", rarity: "Rare"),
                MysteryRelic(id: "languages-fluency-shell", subject: self, name: "Fluency Shell", emoji: "🐚", lore: "Keeps echoes of phrases you can actually use in conversation.", rarity: "Uncommon")
            ]
        case .history:
            return [
                MysteryRelic(id: "history-bronze-denarius", subject: self, name: "Bronze Denarius", emoji: "🪙", lore: "A grounded clue from the Roman economy, campaigns, and daily trade.", rarity: "Rare"),
                MysteryRelic(id: "history-archive-fragment", subject: self, name: "Archive Fragment", emoji: "📜", lore: "A torn source note that links a choice to what historians can verify.", rarity: "Uncommon")
            ]
        case .science:
            return [
                MysteryRelic(id: "science-orbit-spark", subject: self, name: "Orbit Spark", emoji: "✨", lore: "A bright reminder that every mission depends on real forces and evidence.", rarity: "Rare"),
                MysteryRelic(id: "science-field-lens", subject: self, name: "Field Lens", emoji: "🔎", lore: "Reveals the observation hiding behind a good explanation.", rarity: "Uncommon")
            ]
        case .geography:
            return [
                MysteryRelic(id: "geography-river-pin", subject: self, name: "River Pin", emoji: "📍", lore: "Marks how rivers, mountains, and routes shape real places.", rarity: "Uncommon"),
                MysteryRelic(id: "geography-atlas-key", subject: self, name: "Atlas Key", emoji: "🗝️", lore: "Unlocks the mental map between clue, region, and capital.", rarity: "Rare")
            ]
        case .math:
            return [
                MysteryRelic(id: "math-logic-rune", subject: self, name: "Logic Rune", emoji: "🔷", lore: "Glows when a pattern becomes a rule you can reuse.", rarity: "Rare"),
                MysteryRelic(id: "math-ratio-gear", subject: self, name: "Ratio Gear", emoji: "⚙️", lore: "Keeps equivalent relationships turning in sync.", rarity: "Uncommon")
            ]
        case .culture:
            return [
                MysteryRelic(id: "culture-festival-thread", subject: self, name: "Festival Thread", emoji: "🧵", lore: "Connects food, music, ritual, and meaning without flattening them.", rarity: "Rare"),
                MysteryRelic(id: "culture-market-token", subject: self, name: "Market Token", emoji: "🏮", lore: "A small object from everyday culture, not a tourist stereotype.", rarity: "Uncommon")
            ]
        case .business:
            return [
                MysteryRelic(id: "business-margin-gem", subject: self, name: "Margin Gem", emoji: "💎", lore: "Shines when a decision respects cash, value, and incentives.", rarity: "Rare"),
                MysteryRelic(id: "business-signal-card", subject: self, name: "Signal Card", emoji: "💳", lore: "Separates useful market evidence from noisy confidence.", rarity: "Uncommon")
            ]
        case .health:
            return [
                MysteryRelic(id: "health-vitality-leaf", subject: self, name: "Vitality Leaf", emoji: "🍃", lore: "Rewards practical recovery, steady energy, and small repeatable habits.", rarity: "Rare"),
                MysteryRelic(id: "health-breath-stone", subject: self, name: "Breath Stone", emoji: "🪨", lore: "Anchors a fast reset before stress turns into avoidance.", rarity: "Uncommon")
            ]
        }
    }

    func challengeIds(for worldId: String) -> [String] {
        switch self {
        case .languages:
            return []
        case .history:
            return HistoryData.challenges(for: worldId).map(\.id)
        case .science:
            return ScienceData.challenges(for: worldId).map(\.id)
        case .geography:
            return GeographyData.challenges(for: worldId).map(\.id)
        case .math:
            return MathData.challenges(for: worldId).map(\.id)
        case .culture:
            return CultureData.challenges(for: worldId).map(\.id)
        case .business:
            return BusinessData.challenges(for: worldId).map(\.id)
        case .health:
            return HealthData.challenges(for: worldId).map(\.id)
        }
    }

    func encounterPreview(for worldId: String, completedIds: [String]) -> CampaignEncounterPreview? {
        switch self {
        case .languages:
            return CampaignEncounterPreview(
                title: "Review Gate",
                context: "A mixed speaking and typing prompt is ready.",
                clue: "Type, speak, then bank the fluency drop."
            )
        case .history:
            return HistoryData.challenges(for: worldId)
                .first { !completedIds.contains($0.id) }
                .map { CampaignEncounterPreview(title: "\($0.era) · \($0.yearLabel)", context: $0.question, clue: $0.context) }
        case .science:
            return ScienceData.challenges(for: worldId)
                .first { !completedIds.contains($0.id) }
                .map { CampaignEncounterPreview(title: "\($0.field) · \($0.era)", context: $0.question, clue: $0.context) }
        case .geography:
            return GeographyData.challenges(for: worldId)
                .first { !completedIds.contains($0.id) }
                .map { CampaignEncounterPreview(title: "\($0.region) · \(String($0.mapTargetLabel.prefix(18)))", context: $0.question, clue: $0.mapClue) }
        case .math:
            return MathData.challenges(for: worldId)
                .first { !completedIds.contains($0.id) }
                .map { CampaignEncounterPreview(title: "\($0.domain) Gate", context: $0.question, clue: $0.patternClue) }
        case .culture:
            return CultureData.challenges(for: worldId)
                .first { !completedIds.contains($0.id) }
                .map { CampaignEncounterPreview(title: "\($0.region) Scene", context: $0.question, clue: $0.traditionClue) }
        case .business:
            return BusinessData.challenges(for: worldId)
                .first { !completedIds.contains($0.id) }
                .map { CampaignEncounterPreview(title: "\($0.domain) Decision", context: $0.question, clue: $0.marketSignal) }
        case .health:
            return HealthData.challenges(for: worldId)
                .first { !completedIds.contains($0.id) }
                .map { CampaignEncounterPreview(title: "\($0.domain) Habit", context: $0.question, clue: $0.bodySignal) }
        }
    }

    func journalSceneTitle(for world: PlayableWorld?) -> String {
        switch self {
        case .languages: return "Harbor Gate"
        case .history: return world?.name == "Ancient Rome" ? "Forum at a Turning Point" : "Source Room"
        case .science: return "Mission Control Briefing"
        case .geography: return "Compass Table"
        case .math: return "Pattern Vault"
        case .culture: return "Living Context"
        case .business: return "Founder Desk"
        case .health: return "Energy Check-In"
        }
    }

    func journalSceneText(for world: PlayableWorld?) -> String {
        switch self {
        case .languages:
            return "A short deck of speaking and typing prompts is waiting at the dock."
        case .history:
            return "Step into \(world?.era ?? "a real era") through grounded choices, sources, and consequences."
        case .science:
            return "Read the evidence, test the idea, and leave with a reusable explanation."
        case .geography:
            return "Use rivers, borders, routes, and place clues to build a mental map."
        case .math:
            return "Turn the visible pattern into a rule before choosing the key."
        case .culture:
            return "Slow down, read the social setting, and learn why the respectful move fits."
        case .business:
            return "Separate signal from noise before spending time, money, or trust."
        case .health:
            return "Choose the small practical move that improves energy today and can repeat tomorrow."
        }
    }

    func journalChoiceText(for world: PlayableWorld?) -> String {
        switch self {
        case .languages:
            return "Speak first, then type from memory."
        case .history:
            return "Choose the action, then compare it with what actually happened."
        case .science:
            return "Pick the explanation that matches the evidence."
        case .geography:
            return "Follow the map clue before picking the place."
        case .math:
            return "Name the rule, solve the gate, keep the pattern."
        case .culture:
            return "Act from context, not from a tourist shortcut."
        case .business:
            return "Choose the move a durable operator would make."
        case .health:
            return "Pick the habit decision that is useful, modest, and repeatable."
        }
    }

    func codexEntries(for progress: SubjectProgress) -> [KnowledgeCodexEntry] {
        switch self {
        case .languages:
            return []
        case .history:
            return worlds.flatMap { world in
                HistoryData.challenges(for: world.id).map { challenge in
                    KnowledgeCodexEntry(
                        id: challenge.id,
                        subject: self,
                        worldName: world.name,
                        title: "\(challenge.era) · \(challenge.yearLabel)",
                        subtitle: world.name,
                        body: challenge.historicalFact,
                        source: challenge.sourceCitation,
                        systemImage: "scroll.fill",
                        isUnlocked: progress.completedChallengeIds.contains(challenge.id)
                    )
                }
            }
        case .science:
            return worlds.flatMap { world in
                ScienceData.challenges(for: world.id).map { challenge in
                    KnowledgeCodexEntry(
                        id: challenge.id,
                        subject: self,
                        worldName: world.name,
                        title: "\(challenge.field) · \(challenge.era)",
                        subtitle: world.name,
                        body: challenge.funFact,
                        source: "Evidence note",
                        systemImage: "atom",
                        isUnlocked: progress.completedChallengeIds.contains(challenge.id)
                    )
                }
            }
        case .geography:
            return worlds.flatMap { world in
                GeographyData.challenges(for: world.id).map { challenge in
                    KnowledgeCodexEntry(
                        id: challenge.id,
                        subject: self,
                        worldName: world.name,
                        title: "\(challenge.region) · \(challenge.mapTargetLabel)",
                        subtitle: world.name,
                        body: challenge.fieldNote,
                        source: challenge.mapClue,
                        systemImage: "map.fill",
                        isUnlocked: progress.completedChallengeIds.contains(challenge.id)
                    )
                }
            }
        case .math:
            return worlds.flatMap { world in
                MathData.challenges(for: world.id).map { challenge in
                    KnowledgeCodexEntry(
                        id: challenge.id,
                        subject: self,
                        worldName: world.name,
                        title: "\(challenge.domain) Rule",
                        subtitle: world.name,
                        body: challenge.ruleExplanation,
                        source: challenge.patternClue,
                        systemImage: "function",
                        isUnlocked: progress.completedChallengeIds.contains(challenge.id)
                    )
                }
            }
        case .culture:
            return worlds.flatMap { world in
                CultureData.challenges(for: world.id).map { challenge in
                    KnowledgeCodexEntry(
                        id: challenge.id,
                        subject: self,
                        worldName: world.name,
                        title: "\(challenge.region) Context",
                        subtitle: world.name,
                        body: challenge.culturalNote,
                        source: challenge.traditionClue,
                        systemImage: "theatermasks.fill",
                        isUnlocked: progress.completedChallengeIds.contains(challenge.id)
                    )
                }
            }
        case .business:
            return worlds.flatMap { world in
                BusinessData.challenges(for: world.id).map { challenge in
                    KnowledgeCodexEntry(
                        id: challenge.id,
                        subject: self,
                        worldName: world.name,
                        title: "\(challenge.domain) Principle",
                        subtitle: world.name,
                        body: challenge.lesson,
                        source: challenge.marketSignal,
                        systemImage: "chart.line.uptrend.xyaxis",
                        isUnlocked: progress.completedChallengeIds.contains(challenge.id)
                    )
                }
            }
        case .health:
            return worlds.flatMap { world in
                HealthData.challenges(for: world.id).map { challenge in
                    KnowledgeCodexEntry(
                        id: challenge.id,
                        subject: self,
                        worldName: world.name,
                        title: "\(challenge.domain) Habit",
                        subtitle: world.name,
                        body: challenge.habitLesson,
                        source: challenge.bodySignal,
                        systemImage: "heart.text.square.fill",
                        isUnlocked: progress.completedChallengeIds.contains(challenge.id)
                    )
                }
            }
        }
    }
}

extension HistoryChallenge {
    var yearLabel: String {
        year < 0 ? "\(abs(year)) BCE" : "\(year) CE"
    }
}

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
    var displayName: String { source.flag + " " + source.name + " → " + target.name + " " + target.flag }
    var learningName: String { "Learn \(target.flag) \(target.name) from \(source.flag) \(source.name)" }
    static var allPairs: [LanguagePair] {
        AppLanguage.allCases.flatMap { source in
            AppLanguage.allCases.compactMap { target in
                source == target ? nil : LanguagePair(source: source, target: target)
            }
        }
    }
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
    var lastStreakChestClaimDate: Date? = nil
    var lastBossDefeatDate: Date? = nil
    var lastMysteryRelicClaimDate: Date? = nil
    var collectedRelicIds: [String]? = nil
    var ownedRewardIds: [String]? = nil
    var equippedRewardId: String? = nil
    var unlockedLevels: [CEFRLevel] = [.a1]
    var pet: Pet = Pet()
    var hasSeenPetPicker: Bool = false
    var hasSkippedAuth: Bool = false
    var fluency: Double { 0 }
    var accuracyToday: Double { reviewedToday == 0 ? 0 : Double(correctToday) / Double(reviewedToday) }
    
    // MARK: - Subject System
    var selectedSubject: Subject = .languages
    var subjectProgress: [String: SubjectProgress] = [:]
    var hasSeenSubjectPicker: Bool = false
    
    mutating func progress(for subject: Subject) -> SubjectProgress {
        if let existing = subjectProgress[subject.rawValue] { return existing }
        var new = SubjectProgress()
        subjectProgress[subject.rawValue] = new
        return new
    }
    
    mutating func updateProgress(for subject: Subject, _ progress: SubjectProgress) {
        subjectProgress[subject.rawValue] = progress
    }
}

extension UserStats {
    func currentWorldId(for subject: Subject) -> String? {
        subjectProgress[subject.rawValue]?.currentWorldId ?? subject.worlds.first?.id
    }

    var worldJournal: WorldJournal {
        if selectedSubject == .languages {
            let total = max(dailyGoal, 1)
            let completed = min(reviewedToday, total)
            return WorldJournal(
                subject: .languages,
                world: nil,
                sceneTitle: "Harbor Gate",
                sceneText: "A short deck of speaking and typing prompts is waiting at the dock.",
                objective: "Clear \(max(1, total - completed)) more mixed prompts to fill today's fluency drop.",
                choiceText: "Speak first, then type from memory.",
                rewardText: "+30 XP · Fluency Drop",
                progress: min(1, Double(completed) / Double(total)),
                progressText: "\(completed)/\(total) prompts",
                nextUnlockText: nextWorldUnlockBadge.map { "\($0.xpRemaining) XP to \($0.world.name)." } ?? "All current worlds are open."
            )
        }

        let progress = subjectProgress[selectedSubject.rawValue] ?? SubjectProgress()
        let world = selectedSubject.worlds.first { $0.id == (progress.currentWorldId ?? "") }
            ?? selectedSubject.worlds.first { $0.isUnlocked(withXP: xp) }
            ?? selectedSubject.worlds.first
        let challengeIds = world.map { selectedSubject.challengeIds(for: $0.id) } ?? []
        let completed = progress.completedChallengeIds.filter { challengeIds.contains($0) }.count
        let total = max(challengeIds.count, 1)
        let remaining = max(0, total - completed)

        return WorldJournal(
            subject: selectedSubject,
            world: world,
            sceneTitle: selectedSubject.journalSceneTitle(for: world),
            sceneText: selectedSubject.journalSceneText(for: world),
            objective: remaining == 0 ? "World cleared. Chase the next unlock or spin into a different domain." : "Complete \(remaining) more \(remaining == 1 ? "mission" : "missions") to close this world chapter.",
            choiceText: selectedSubject.journalChoiceText(for: world),
            rewardText: "+30 XP · \(DailyAdventure(subject: selectedSubject, world: world, xp: xp, streak: streak).rewardName)",
            progress: min(1, Double(completed) / Double(total)),
            progressText: "\(min(completed, total))/\(total) missions",
            nextUnlockText: selectedSubject.nextLockedWorld(withXP: xp).map { "\($0.xpRemaining(withXP: xp)) XP to unlock \($0.name)." } ?? "All \(selectedSubject.displayName) worlds are open."
        )
    }

    func worldPathStops(for subject: Subject) -> [WorldPathStop] {
        guard subject != .languages else { return [] }
        let progress = subjectProgress[subject.rawValue] ?? SubjectProgress()
        let activeWorldId = currentWorldId(for: subject)

        return subject.worlds.enumerated().map { index, world in
            let challengeIds = subject.challengeIds(for: world.id)
            let completed = progress.completedChallengeIds.filter { challengeIds.contains($0) }.count
            return WorldPathStop(
                subject: subject,
                world: world,
                index: index,
                isSelected: world.id == activeWorldId,
                isLocked: !world.isUnlocked(withXP: xp),
                completedChallenges: completed,
                totalChallenges: challengeIds.count,
                xpRemaining: world.xpRemaining(withXP: xp)
            )
        }
    }

    var learningLevel: Int {
        max(1, (xp / 100) + 1)
    }

    var xpIntoCurrentLevel: Int {
        max(0, xp % 100)
    }

    var xpNeededForNextLevel: Int {
        max(0, 100 - xpIntoCurrentLevel)
    }

    var levelProgress: Double {
        Double(xpIntoCurrentLevel) / 100.0
    }

    var levelTitle: String {
        switch learningLevel {
        case 1...2: return "Trail Starter"
        case 3...4: return "World Walker"
        case 5...7: return "Quest Adept"
        case 8...11: return "Realm Scholar"
        default: return "Master Explorer"
        }
    }

    var streakBoostText: String {
        guard streak > 1 else { return "Start a streak for bonus momentum" }
        let boost = min(25, streak * 2)
        return "\(streak)-day streak · +\(boost)% momentum"
    }

    var worldRewardBadges: [WorldRewardBadge] {
        Subject.allCases.flatMap { subject in
            subject.worlds.map { world in
                WorldRewardBadge(
                    subject: subject,
                    world: world,
                    isEarned: world.isUnlocked(withXP: xp),
                    xpRemaining: world.xpRemaining(withXP: xp)
                )
            }
        }
    }

    var earnedWorldRewardCount: Int {
        worldRewardBadges.filter(\.isEarned).count
    }

    var totalWorldRewardCount: Int {
        worldRewardBadges.count
    }

    var worldRewardProgress: Double {
        guard totalWorldRewardCount > 0 else { return 0 }
        return Double(earnedWorldRewardCount) / Double(totalWorldRewardCount)
    }

    var featuredWorldRewardBadges: [WorldRewardBadge] {
        let badges = worldRewardBadges
        let earned = badges.filter(\.isEarned).suffix(3)
        let nextLocked = badges.first { !$0.isEarned }.map { [$0] } ?? []
        return Array(earned) + nextLocked
    }

    var nextWorldUnlockBadge: WorldRewardBadge? {
        worldRewardBadges
            .filter { !$0.isEarned }
            .sorted { $0.xpRemaining < $1.xpRemaining }
            .first
    }

    var collectedRelicSet: Set<String> {
        Set(collectedRelicIds ?? [])
    }

    var allRelicVaultItems: [RelicVaultItem] {
        let collected = collectedRelicSet
        return Subject.allCases.flatMap { subject in
            subject.mysteryRelics.map { relic in
                RelicVaultItem(relic: relic, isCollected: collected.contains(relic.id))
            }
        }
    }

    var collectedRelicCount: Int {
        allRelicVaultItems.filter(\.isCollected).count
    }

    var totalRelicCount: Int {
        allRelicVaultItems.count
    }

    var featuredRelicVaultItems: [RelicVaultItem] {
        let items = allRelicVaultItems
        let collected = items.filter(\.isCollected).suffix(2)
        let hidden = items.first { !$0.isCollected }.map { [$0] } ?? []
        return Array(collected) + hidden
    }

    var rewardShop: RewardShop {
        let passport = learningPassport
        let baseItems: [(id: String, kind: RewardShopItemKind, name: String, emoji: String, subject: Subject, cost: Int, unlocked: Bool, requirement: String)] = [
            ("aura-trail-starter", .avatarAura, "Trail Starter Aura", "✨", selectedSubject, 6, learningLevel >= 2, "Reach level 2"),
            ("map-ancient-parchment", .mapSkin, "Ancient Parchment Map", "🗺️", .history, 10, earnedWorldRewardCount >= 2, "Collect 2 world badges"),
            ("trail-scholar-circuit", .studyTrail, "Scholar Circuit Trail", "🔷", .science, 12, passport.earnedCount >= 3, "Earn 3 passport stamps"),
            ("aura-relic-glow", .avatarAura, "Relic Glow Aura", "💎", .culture, 16, collectedRelicCount >= 1, "Collect 1 relic")
        ]

        let items = baseItems.map { item in
            RewardShopItem(
                id: item.id,
                kind: item.kind,
                name: item.name,
                emoji: item.emoji,
                subject: item.subject,
                costGems: item.cost,
                requirementText: item.requirement,
                isUnlocked: item.unlocked,
                isOwned: (ownedRewardIds ?? []).contains(item.id),
                isEquipped: equippedRewardId == item.id
            )
        }

        let featured = items.first { $0.isEquipped }
            ?? items.first { $0.isOwned }
            ?? items.first { $0.isUnlocked && gems >= $0.costGems }
            ?? items.first { $0.isUnlocked }
            ?? items.first

        return RewardShop(gems: gems, items: items, featuredItem: featured)
    }

    var atlasSubjectProgress: [AtlasSubjectProgress] {
        Subject.allCases.map { subject in
            if subject == .languages {
                return AtlasSubjectProgress(
                    subject: subject,
                    openedWorlds: 1,
                    totalWorlds: 1,
                    completedMissions: min(reviewedToday, max(dailyGoal, 1)),
                    totalMissions: max(dailyGoal, 1),
                    nextWorld: nil,
                    xpRemaining: 0
                )
            }

            let progress = subjectProgress[subject.rawValue] ?? SubjectProgress()
            let totalMissions = subject.worlds.reduce(0) { $0 + subject.challengeIds(for: $1.id).count }
            let completedMissions = subject.worlds.reduce(0) { partial, world in
                let ids = subject.challengeIds(for: world.id)
                return partial + progress.completedChallengeIds.filter { ids.contains($0) }.count
            }
            let nextWorld = subject.nextLockedWorld(withXP: xp)
            return AtlasSubjectProgress(
                subject: subject,
                openedWorlds: subject.unlockedWorldCount(withXP: xp),
                totalWorlds: subject.worlds.count,
                completedMissions: completedMissions,
                totalMissions: totalMissions,
                nextWorld: nextWorld,
                xpRemaining: nextWorld?.xpRemaining(withXP: xp) ?? 0
            )
        }
    }

    var atlasOpenWorldCount: Int {
        atlasSubjectProgress.reduce(0) { $0 + $1.openedWorlds }
    }

    var atlasTotalWorldCount: Int {
        atlasSubjectProgress.reduce(0) { $0 + $1.totalWorlds }
    }

    var atlasProgress: Double {
        guard atlasTotalWorldCount > 0 else { return 0 }
        return Double(atlasOpenWorldCount) / Double(atlasTotalWorldCount)
    }

    var atlasNextTarget: AtlasSubjectProgress? {
        atlasSubjectProgress
            .filter { $0.subject != .languages && $0.nextWorld != nil }
            .sorted { $0.xpRemaining < $1.xpRemaining }
            .first
    }

    var masteryLeague: MasteryLeague {
        let collectedRelics = collectedRelicSet
        let standings = Subject.allCases.map { subject in
            let relicCount = subject.mysteryRelics.filter { collectedRelics.contains($0.id) }.count

            if subject == .languages {
                let reps = min(reviewedToday, max(dailyGoal, 1))
                let score = reps * 12 + relicCount * 45 + (streak * 4)
                return MasteryLeagueStanding(
                    rank: 0,
                    subject: subject,
                    score: score,
                    completedMissions: reps,
                    totalMissions: max(dailyGoal, 1),
                    openedWorlds: 1,
                    totalWorlds: 1,
                    collectedRelics: relicCount,
                    isSelected: selectedSubject == subject
                )
            }

            let progress = subjectProgress[subject.rawValue] ?? SubjectProgress()
            let worldScore = progress.worldScores.values.reduce(0, +)
            let totalMissions = subject.worlds.reduce(0) { $0 + subject.challengeIds(for: $1.id).count }
            let completedMissions = subject.worlds.reduce(0) { partial, world in
                let ids = subject.challengeIds(for: world.id)
                return partial + progress.completedChallengeIds.filter { ids.contains($0) }.count
            }
            let openedWorlds = subject.unlockedWorldCount(withXP: xp)
            let score = worldScore + completedMissions * 55 + openedWorlds * 30 + relicCount * 45
            return MasteryLeagueStanding(
                rank: 0,
                subject: subject,
                score: score,
                completedMissions: completedMissions,
                totalMissions: totalMissions,
                openedWorlds: openedWorlds,
                totalWorlds: subject.worlds.count,
                collectedRelics: relicCount,
                isSelected: selectedSubject == subject
            )
        }
        .sorted {
            if $0.score == $1.score { return $0.subject.rawValue < $1.subject.rawValue }
            return $0.score > $1.score
        }
        .enumerated()
        .map { index, standing in
            MasteryLeagueStanding(
                rank: index + 1,
                subject: standing.subject,
                score: standing.score,
                completedMissions: standing.completedMissions,
                totalMissions: standing.totalMissions,
                openedWorlds: standing.openedWorlds,
                totalWorlds: standing.totalWorlds,
                collectedRelics: standing.collectedRelics,
                isSelected: standing.isSelected
            )
        }

        let selected = standings.first { $0.subject == selectedSubject }
        let catchUp = standings
            .filter { $0.subject != selectedSubject }
            .sorted {
                if $0.score == $1.score { return $0.subject.rawValue < $1.subject.rawValue }
                return $0.score < $1.score
            }
            .first
        return MasteryLeague(standings: standings, selectedStanding: selected, catchUpTarget: catchUp)
    }

    var learningPassport: LearningPassport {
        let stamps = Subject.allCases.map { subject -> LearningPassportStamp in
            if subject == .languages {
                let target = max(1, dailyGoal)
                let reps = min(target, max(reviewedToday, totalReviews))
                let earned = reviewedToday > 0 || totalReviews > 0
                return LearningPassportStamp(
                    subject: subject,
                    title: "Language Harbor Stamp",
                    subtitle: earned ? "Phrase review logged" : "Complete 1 phrase review",
                    systemImage: "book.closed.fill",
                    progress: min(1, Double(reps) / Double(target)),
                    isEarned: earned
                )
            }

            let progress = subjectProgress[subject.rawValue] ?? SubjectProgress()
            let completed = progress.completedChallengeIds.count
            let firstWorld = subject.worlds.first
            let firstWorldTotal = firstWorld.map { max(1, subject.challengeIds(for: $0.id).count) } ?? 1
            let earned = completed > 0 || progress.worldScores.values.contains { $0 > 0 }
            return LearningPassportStamp(
                subject: subject,
                title: "\(subject.displayName) Stamp",
                subtitle: earned ? "\(completed) mission\(completed == 1 ? "" : "s") logged" : "Start \(firstWorld?.name ?? subject.mapTitle)",
                systemImage: earned ? "checkmark.seal.fill" : subject.icon,
                progress: min(1, Double(completed) / Double(firstWorldTotal)),
                isEarned: earned
            )
        }

        let next = stamps.first { !$0.isEarned && $0.subject == selectedSubject } ?? stamps.first { !$0.isEarned }
        return LearningPassport(stamps: stamps, nextStamp: next)
    }

    var knowledgeCodex: KnowledgeCodex {
        let languageEntry = KnowledgeCodexEntry(
            id: "languages-review-gate",
            subject: .languages,
            worldName: "Language Harbor",
            title: "Spaced Review Loop",
            subtitle: selectedLanguagePair.displayName,
            body: "Speaking, typing, and spaced repetition turn recognition into usable recall.",
            source: "Review gate",
            systemImage: "textformat.abc",
            isUnlocked: totalReviews > 0 || reviewedToday > 0
        )

        let subjectEntries = Subject.allCases
            .filter { $0 != .languages }
            .flatMap { subject in
                subject.codexEntries(for: subjectProgress[subject.rawValue] ?? SubjectProgress())
            }
        let entries = [languageEntry] + subjectEntries
        let unlocked = entries.filter(\.isUnlocked).suffix(2)
        let selectedLocked = entries.first { !$0.isUnlocked && $0.subject == selectedSubject }
        let nextLocked = selectedLocked ?? entries.first { !$0.isUnlocked }
        let featured = Array(unlocked) + (nextLocked.map { [$0] } ?? [])
        return KnowledgeCodex(entries: entries, featuredEntries: Array(featured.prefix(3)))
    }

    var questRoulette: QuestRoulette {
        let languageOption = QuestRouletteOption(
            subject: .languages,
            world: nil,
            title: "Language Harbor",
            subtitle: "Mixed speaking and typing prompts",
            reward: "+30 XP · Fluency Drop",
            systemImage: "textformat.abc"
        )

        let worldOptions = Subject.allCases
            .filter { $0 != .languages }
            .flatMap { subject in
                subject.worlds
                    .filter { $0.isUnlocked(withXP: xp) }
                    .map { world in
                        QuestRouletteOption(
                            subject: subject,
                            world: world,
                            title: world.name,
                            subtitle: "\(subject.displayName) · \(world.era)",
                            reward: "+30 XP · \(world.rewardName)",
                            systemImage: subject.mapSystemImage
                        )
                    }
            }

        let options = [languageOption] + worldOptions
        let offset = options.isEmpty ? 0 : abs(xp + reviewedToday + correctToday + streak) % options.count
        let featured = Array(Self.rotated(options, by: offset).prefix(4))
        return QuestRoulette(options: options, featuredOptions: featured, spinSeed: offset)
    }

    private static func rotated<T>(_ values: [T], by offset: Int) -> [T] {
        guard !values.isEmpty else { return [] }
        let normalized = ((offset % values.count) + values.count) % values.count
        return Array(values[normalized...]) + Array(values[..<normalized])
    }
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
