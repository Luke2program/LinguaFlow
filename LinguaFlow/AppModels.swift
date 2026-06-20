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
        case .geography: return "Know the world, one fact at a time"
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
        case .languages, .math, .culture, .business, .health:
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
}

enum UnlockRequirement: Codable, Equatable {
    case none
    case xpRequired(Int)
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
