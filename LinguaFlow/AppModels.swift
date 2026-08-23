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
                PlayableWorld(id: "renaissance-cities", name: "Renaissance Cities", emoji: "🎨", era: "1300 – 1600 CE", description: "Enter Florence, Venice, and Rome where art, banking, print, and power remake Europe.", unlockRequirement: .xpRequired(1500)),
                PlayableWorld(id: "nile-kingdoms", name: "Nile Kingdoms", emoji: "𓂀", era: "3100 – 30 BCE", description: "Follow floods, pharaohs, trade, temples, and scribes through one of history's longest-lived civilizations.", unlockRequirement: .xpRequired(2000)),
                PlayableWorld(id: "industrial-revolution", name: "Industrial Revolution", emoji: "🏭", era: "1760 – 1914 CE", description: "Cross mills, railways, cities, strikes, and reform campaigns as steam power rewires everyday life.", unlockRequirement: .xpRequired(2500)),
            ]
        case .science:
            return [
                PlayableWorld(id: "space-exploration", name: "Space Frontiers", emoji: "🚀", era: "1957 – Present", description: "From Sputnik to Mars. Learn orbital mechanics and mission control.", unlockRequirement: .none),
                PlayableWorld(id: "quantum-realm", name: "Quantum Realm", emoji: "⚛️", era: "1900 – Present", description: "Particles, waves, and spooky action at a distance.", unlockRequirement: .xpRequired(750)),
                PlayableWorld(id: "earth-systems", name: "Earth Systems", emoji: "🌋", era: "Deep Time – Present", description: "Trace climate, water, carbon, and ecosystems as one living planetary machine.", unlockRequirement: .xpRequired(1200)),
                PlayableWorld(id: "human-body-lab", name: "Human Body Lab", emoji: "🫀", era: "Living systems", description: "Run quick physiology missions through breathing, blood, nerves, immunity, and energy.", unlockRequirement: .xpRequired(1700)),
            ]
        case .geography:
            return [
                PlayableWorld(id: "european-capitals", name: "European Capitals", emoji: "🇪🇺", era: "Modern", description: "Navigate Europe by capital cities, rivers, mountains, and borders.", unlockRequirement: .none),
                PlayableWorld(id: "african-wonders", name: "African Wonders", emoji: "🌍", era: "Ancient – Modern", description: "From the Sahara to Kilimanjaro. Rivers, deserts, and ecosystems.", unlockRequirement: .xpRequired(300)),
                PlayableWorld(id: "silk-road-routes", name: "Silk Road Routes", emoji: "🐫", era: "130 BCE – 1450 CE", description: "Guide caravans across oases, mountain passes, deserts, and ports that connected Eurasia.", unlockRequirement: .xpRequired(900)),
                PlayableWorld(id: "pacific-ring", name: "Pacific Ring", emoji: "🌋", era: "Deep Earth – Present", description: "Trace volcanoes, trenches, earthquakes, tsunamis, and island arcs around the Pacific Rim.", unlockRequirement: .xpRequired(1300)),
            ]
        case .math:
            return [
                PlayableWorld(id: "logic-gates", name: "Logic Gates", emoji: "🔢", era: "Foundations", description: "Crack pattern locks, ratios, and number rules in a neon puzzle vault.", unlockRequirement: .none),
                PlayableWorld(id: "probability-casino", name: "Probability Casino", emoji: "🎲", era: "Chance", description: "Read odds, avoid traps, and make smarter bets with probability.", unlockRequirement: .xpRequired(400)),
                PlayableWorld(id: "geometry-studio", name: "Geometry Studio", emoji: "📐", era: "Shape Lab", description: "Rotate, measure, and rebuild spatial puzzles with angles, area, volume, and scale.", unlockRequirement: .xpRequired(800)),
                PlayableWorld(id: "data-detective", name: "Data Detective", emoji: "🕵️", era: "Evidence Lab", description: "Interrogate charts, averages, samples, and causation clues before a misleading headline escapes.", unlockRequirement: .xpRequired(1200)),
            ]
        case .culture:
            return [
                PlayableWorld(id: "heritage-kitchens", name: "Heritage Kitchens", emoji: "🍜", era: "Living traditions", description: "Travel through food rituals, etiquette, markets, and everyday meanings behind iconic dishes.", unlockRequirement: .none),
                PlayableWorld(id: "festival-roads", name: "Festival Roads", emoji: "🎊", era: "Seasonal cycles", description: "Follow real festivals through music, symbols, calendars, and community traditions.", unlockRequirement: .xpRequired(450)),
                PlayableWorld(id: "world-music-stage", name: "World Music Stage", emoji: "🎶", era: "Oral memory – Present", description: "Listen through rhythm, call-and-response, instruments, and social meaning in real music traditions.", unlockRequirement: .xpRequired(850)),
                PlayableWorld(id: "architecture-trails", name: "Architecture Trails", emoji: "🏯", era: "Built memory", description: "Explore real buildings, sacred spaces, conservation choices, and the stories encoded in stone, wood, light, and city plans.", unlockRequirement: .xpRequired(1250)),
            ]
        case .business:
            return [
                PlayableWorld(id: "founder-guild", name: "Founder Guild", emoji: "📈", era: "Startup basics", description: "Make practical startup, pricing, cash-flow, and customer decisions under pressure.", unlockRequirement: .none),
                PlayableWorld(id: "wall-street-desk", name: "Wall Street Desk", emoji: "💼", era: "Markets", description: "Read incentives, risk, diversification, and market signals without falling for hype.", unlockRequirement: .xpRequired(550)),
                PlayableWorld(id: "negotiation-room", name: "Negotiation Room", emoji: "🤝", era: "Dealcraft", description: "Practice offers, anchors, BATNA, tradeoffs, and trust without burning the relationship.", unlockRequirement: .xpRequired(950)),
                PlayableWorld(id: "personal-finance-lab", name: "Personal Finance Lab", emoji: "🏦", era: "Money systems", description: "Turn budgeting, emergency funds, debt, credit, and investing into practical life decisions.", unlockRequirement: .xpRequired(1400)),
            ]
        case .health:
            return [
                PlayableWorld(id: "energy-clinic", name: "Energy Clinic", emoji: "💚", era: "Daily systems", description: "Stabilize sleep, food, movement, hydration, and stress with practical habit decisions.", unlockRequirement: .none),
                PlayableWorld(id: "resilience-gym", name: "Resilience Gym", emoji: "🧠", era: "Mind and recovery", description: "Train recovery, focus, emotional regulation, and long-term wellbeing without health fads.", unlockRequirement: .xpRequired(500)),
                PlayableWorld(id: "nutrition-lab", name: "Nutrition Lab", emoji: "🥗", era: "Fuel and recovery", description: "Build practical meal, hydration, protein, fiber, and label-reading instincts without diet myths.", unlockRequirement: .xpRequired(900)),
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

    static let medievalEuropeChallenges: [HistoryChallenge] = [
        HistoryChallenge(
            id: "medieval-01",
            worldId: "medieval-europe",
            era: "Early Middle Ages",
            year: 800,
            question: "Charlemagne is crowned emperor in Rome. What does the coronation change?",
            context: "On Christmas Day in 800 CE, Pope Leo III crowned the Frankish king Charlemagne as emperor. The title tied Frankish power, Roman memory, and the Latin Church together in a new western imperial project.",
            choices: [
                HistoryChoice(id: "a", text: "It restores the old Western Roman Empire exactly as it was", consequence: "The title returns, but the world is different: power is Frankish, Christian, feudal, and negotiated with the pope.", isCorrect: false, historicalOutcome: "Charlemagne's empire was not a direct restoration of the ancient Western Roman state. It blended Frankish kingship, Christian authority, and Roman symbolism."),
                HistoryChoice(id: "b", text: "It creates a new western imperial model linked to the Church", consequence: "You see how legitimacy now flows through kings, bishops, monasteries, and Roman memory rather than ancient Roman institutions alone.", isCorrect: true, historicalOutcome: "The coronation helped shape the idea of a Christian emperor in western Europe and later influenced the Holy Roman Empire.")
            ],
            historicalFact: "Charlemagne's coronation did not revive ancient Rome as a state, but it made Roman imperial language useful again in medieval western politics.",
            sourceCitation: "Einhard, Life of Charlemagne; Royal Frankish Annals"
        ),
        HistoryChallenge(
            id: "medieval-02",
            worldId: "medieval-europe",
            era: "Norman Conquest",
            year: 1066,
            question: "William of Normandy wins at Hastings. What is his best next move to control England?",
            context: "After defeating Harold Godwinson at the Battle of Hastings, William still needed to turn a military victory into durable rule over a kingdom with local elites, shires, and resistance.",
            choices: [
                HistoryChoice(id: "a", text: "Replace key elites, build castles, and record obligations", consequence: "Control tightens. Castles project power, Norman lords replace many Anglo-Saxon landholders, and records make taxation and service visible.", isCorrect: true, historicalOutcome: "William redistributed land, built castles, and ordered the Domesday survey in 1086 to document landholding and resources."),
                HistoryChoice(id: "b", text: "Leave all local power untouched and sail home", consequence: "Resistance hardens. A distant conqueror with no garrisons, loyal nobles, or administrative grip would struggle to hold the kingdom.", isCorrect: false, historicalOutcome: "William spent years suppressing rebellions and reshaping English landholding. Conquest required administration, not only one battlefield victory.")
            ],
            historicalFact: "The Domesday Book shows how conquest became administration: land, tenants, livestock, mills, and taxable value were recorded across much of England.",
            sourceCitation: "Anglo-Saxon Chronicle; Domesday Book"
        ),
        HistoryChallenge(
            id: "medieval-03",
            worldId: "medieval-europe",
            era: "Magna Carta",
            year: 1215,
            question: "King John faces rebel barons at Runnymede. Why does Magna Carta matter?",
            context: "John's military failures, taxes, and conflict with nobles created a crisis. The charter was meant to settle immediate baronial demands, but later generations gave it wider constitutional meaning.",
            choices: [
                HistoryChoice(id: "a", text: "It instantly creates modern democracy for everyone", consequence: "That sounds satisfying, but it skips the messy history. Most people in 1215 had little political voice.", isCorrect: false, historicalOutcome: "Magna Carta mainly protected elite rights at first. Its later importance grew through reinterpretation and reuse in legal and political struggles."),
                HistoryChoice(id: "b", text: "It limits royal power through law and precedent", consequence: "You spot the long-term lesson: even a king can be forced to negotiate rules that outlive the crisis.", isCorrect: true, historicalOutcome: "Magna Carta became a symbol of lawful limits on rulers, especially through later reissues and legal traditions.")
            ],
            historicalFact: "Magna Carta was annulled within weeks by Pope Innocent III, but reissued versions helped it survive as a powerful legal symbol.",
            sourceCitation: "Magna Carta 1215; Carpenter, Magna Carta"
        ),
        HistoryChallenge(
            id: "medieval-04",
            worldId: "medieval-europe",
            era: "Black Death",
            year: 1348,
            question: "Plague reaches your town. What does the disaster do to medieval society?",
            context: "The Black Death killed a huge share of Europe's population between 1347 and 1351. Communities faced fear, labor shortages, disrupted trade, religious anxiety, and violence against scapegoated minorities.",
            choices: [
                HistoryChoice(id: "a", text: "It leaves the social order unchanged after the bodies are buried", consequence: "The old structures survive on paper, but wages, labor bargaining, piety, taxation, and authority all come under pressure.", isCorrect: false, historicalOutcome: "The plague changed labor markets and social expectations. Elites tried to freeze wages and duties, but scarcity made workers more valuable."),
                HistoryChoice(id: "b", text: "It shakes labor, faith, and authority across Europe", consequence: "You connect the human catastrophe to structural change: fewer workers can demand more, while rulers and churches face hard questions.", isCorrect: true, historicalOutcome: "The Black Death contributed to labor shortages, wage pressure, social unrest, and new religious responses, while also intensifying persecution of Jewish communities in many places.")
            ],
            historicalFact: "After the plague, England's Statute of Labourers tried to hold wages near pre-plague levels, showing how deeply labor conditions had shifted.",
            sourceCitation: "Boccaccio, Decameron; Statute of Labourers 1351"
        )
    ]

    static let ageDiscoveryChallenges: [HistoryChallenge] = [
        HistoryChallenge(
            id: "discovery-01",
            worldId: "age-discovery",
            era: "Atlantic Navigation",
            year: 1492,
            question: "Columbus reaches Caribbean islands while seeking Asia. What should a careful explorer report?",
            context: "In 1492, Christopher Columbus crossed the Atlantic under the Spanish crown. He did not reach Asia; he landed in the Caribbean, where Indigenous societies already had long histories, trade, farming, and political life.",
            choices: [
                HistoryChoice(id: "a", text: "Claim you reached Asia and ignore the people already there", consequence: "You please sponsors in the short term, but your report erases real societies and spreads a false map of the world.", isCorrect: false, historicalOutcome: "Columbus insisted he had reached lands near Asia. European naming and conquest often erased Indigenous geography, sovereignty, and knowledge."),
                HistoryChoice(id: "b", text: "Record a new Atlantic encounter and describe Indigenous societies accurately", consequence: "Your chart becomes more truthful: this is not an empty world, but a contact zone with people, power, and consequences.", isCorrect: true, historicalOutcome: "The voyages opened sustained contact between Europe, Africa, and the Americas, reshaping global history while bringing conquest, disease, forced labor, and resistance.")
            ],
            historicalFact: "The Taino and other Caribbean peoples had complex communities before European arrival; the encounter was not a discovery of empty land.",
            sourceCitation: "Columbus, Journal of the First Voyage; Las Casas, History of the Indies"
        ),
        HistoryChallenge(
            id: "discovery-02",
            worldId: "age-discovery",
            era: "Indian Ocean Trade",
            year: 1498,
            question: "Vasco da Gama reaches Calicut by sea. What does this route change?",
            context: "Portuguese ships rounded the Cape of Good Hope and entered the Indian Ocean, where Arab, Persian, Indian, Malay, Chinese, and East African traders were already connected by monsoon routes.",
            choices: [
                HistoryChoice(id: "a", text: "It enters an existing trade network and militarizes parts of it", consequence: "You understand the world map better: Portugal did not create Indian Ocean trade, but tried to force advantage with ships, cannon, forts, and licenses.", isCorrect: true, historicalOutcome: "The Portuguese Estado da India built fortified posts and used naval power to redirect some spice trade, though older networks continued and adapted."),
                HistoryChoice(id: "b", text: "It invents ocean trade from scratch", consequence: "That misses centuries of movement. Merchants, pilgrims, sailors, and scholars had crossed the Indian Ocean long before Portuguese arrival.", isCorrect: false, historicalOutcome: "Indian Ocean commerce was ancient and sophisticated. European sea routes changed power balances but did not create the network.")
            ],
            historicalFact: "Monsoon wind patterns helped connect East Africa, Arabia, India, and Southeast Asia across regular sailing seasons.",
            sourceCitation: "The Book of Duarte Barbosa; Subrahmanyam, The Career and Legend of Vasco da Gama"
        ),
        HistoryChallenge(
            id: "discovery-03",
            worldId: "age-discovery",
            era: "Conquest of Mexico",
            year: 1521,
            question: "Tenochtitlan falls after siege, alliance, and disease. What best explains the Spanish victory?",
            context: "Hernan Cortes did not conquer the Mexica Empire alone. Indigenous allies, especially Tlaxcalans, played decisive roles, while smallpox devastated communities with no prior immunity.",
            choices: [
                HistoryChoice(id: "a", text: "A handful of Spaniards defeated an empire by themselves", consequence: "That myth hides the real forces: local rivalries, alliances, epidemic disease, siege warfare, and Indigenous strategy.", isCorrect: false, historicalOutcome: "Spanish accounts often exaggerated European superiority. Modern histories emphasize Indigenous allies and the catastrophic impact of disease."),
                HistoryChoice(id: "b", text: "Alliances, epidemic disease, and siege conditions broke Mexica power", consequence: "You see the conquest as a collision of politics and biology, not a simple duel between two armies.", isCorrect: true, historicalOutcome: "Tenochtitlan fell in 1521 after months of siege. Indigenous allies supplied large forces, and smallpox severely weakened the city.")
            ],
            historicalFact: "Tlaxcalan and other Indigenous allies were essential to Cortes's campaign and shaped the early colonial order afterward.",
            sourceCitation: "Bernal Diaz, True History of the Conquest of New Spain; Restall, Seven Myths of the Spanish Conquest"
        ),
        HistoryChallenge(
            id: "discovery-04",
            worldId: "age-discovery",
            era: "First Circumnavigation",
            year: 1522,
            question: "Only one ship of Magellan's expedition returns. What did the voyage prove?",
            context: "Magellan died in the Philippines in 1521, but the Victoria returned to Spain in 1522 under Juan Sebastian Elcano. The expedition showed the planet could be circumnavigated by sea, at enormous human cost.",
            choices: [
                HistoryChoice(id: "a", text: "The globe was smaller and easier to cross than expected", consequence: "The Pacific proves otherwise. Hunger, scurvy, storms, mutiny, and violence reveal the scale of the ocean world.", isCorrect: false, historicalOutcome: "The Pacific was far larger than many Europeans expected. The expedition suffered extreme losses before one ship returned."),
                HistoryChoice(id: "b", text: "The Earth could be circled by sea, but global routes were dangerous and unequal", consequence: "You complete the map while remembering the cost: sailors died, island societies were pulled into conflict, and empires chased control.", isCorrect: true, historicalOutcome: "The Victoria's return completed the first circumnavigation, proving a continuous sea route around the globe and accelerating imperial competition.")
            ],
            historicalFact: "Of roughly 270 crew who began the expedition, only about 18 returned to Spain on the Victoria in 1522.",
            sourceCitation: "Pigafetta, Account of the First Voyage Around the World"
        )
    ]

    static let renaissanceCitiesChallenges: [HistoryChallenge] = [
        HistoryChallenge(
            id: "renaissance-01",
            worldId: "renaissance-cities",
            era: "Florentine Banking",
            year: 1434,
            question: "Cosimo de' Medici returns from exile. How does the Medici family build durable power in Florence?",
            context: "Florence was officially a republic, but banking wealth, patronage networks, marriage alliances, and careful office-holding could shape decisions without a royal crown.",
            choices: [
                HistoryChoice(id: "a", text: "Use banking wealth, alliances, and patronage while keeping republican forms", consequence: "You see soft power at work: artists, scholars, clients, and political allies make Medici influence hard to uproot.", isCorrect: true, historicalOutcome: "Cosimo de' Medici dominated Florentine politics through wealth, patronage, and factional alliances while preserving many republican institutions on the surface."),
                HistoryChoice(id: "b", text: "Declare himself king of Florence immediately", consequence: "That would make the hidden structure visible too early and unite enemies against him.", isCorrect: false, historicalOutcome: "The Medici usually avoided open monarchy in this period. Their power worked through influence inside republican offices and patronage systems.")
            ],
            historicalFact: "Medici patronage helped support figures such as Donatello, Brunelleschi, and later Botticelli, making political power and cultural production closely linked.",
            sourceCitation: "Machiavelli, Florentine Histories; Kent, The Rise of the Medici"
        ),
        HistoryChallenge(
            id: "renaissance-02",
            worldId: "renaissance-cities",
            era: "Printing Press",
            year: 1455,
            question: "Gutenberg's movable type spreads through Europe. What changes most for learning and authority?",
            context: "Manuscripts were copied by hand before print shops could multiply texts faster and cheaper. Books, pamphlets, maps, technical diagrams, and religious arguments began moving through cities at new speed.",
            choices: [
                HistoryChoice(id: "a", text: "Texts become easier to reproduce, compare, and argue over", consequence: "Knowledge travels faster. Scholars can check editions, merchants can share manuals, and religious controversy can spread beyond local control.", isCorrect: true, historicalOutcome: "Printing accelerated the circulation of classical texts, scientific diagrams, vernacular literature, maps, and Reformation pamphlets."),
                HistoryChoice(id: "b", text: "Every person in Europe instantly becomes literate", consequence: "Print helps literacy grow, but access still depends on language, money, schooling, and local institutions.", isCorrect: false, historicalOutcome: "Literacy expanded unevenly over centuries. Printing changed availability and speed, but did not instantly educate everyone.")
            ],
            historicalFact: "By 1500, European presses had produced millions of printed books, often called incunabula for the earliest print era.",
            sourceCitation: "Eisenstein, The Printing Press as an Agent of Change; Febvre and Martin, The Coming of the Book"
        ),
        HistoryChallenge(
            id: "renaissance-03",
            worldId: "renaissance-cities",
            era: "Venetian Trade",
            year: 1500,
            question: "Venice faces Ottoman pressure and Atlantic competition. What keeps the city powerful?",
            context: "Venice connected Mediterranean trade, shipbuilding, diplomacy, finance, and state control. Its Arsenal could organize large-scale naval production, while merchants managed risk across long routes.",
            choices: [
                HistoryChoice(id: "a", text: "Combine naval production, trade intelligence, diplomacy, and finance", consequence: "You keep routes alive by treating commerce as a system: ships, credit, information, law, and alliances all matter.", isCorrect: true, historicalOutcome: "Venice remained a major maritime and commercial power through organized shipbuilding, diplomatic intelligence, financial tools, and control of strategic routes."),
                HistoryChoice(id: "b", text: "Ignore shipping and rely only on paintings", consequence: "Art flourishes, but without ships, credit, and diplomacy the republic loses the engine of its wealth.", isCorrect: false, historicalOutcome: "Venetian art was famous, but the city's power rested heavily on maritime trade, institutions, and strategic diplomacy.")
            ],
            historicalFact: "The Venetian Arsenal was one of Europe's largest industrial complexes, coordinating specialized labor for ship construction and repair.",
            sourceCitation: "Lane, Venice: A Maritime Republic; Sanudo, Diaries"
        ),
        HistoryChallenge(
            id: "renaissance-04",
            worldId: "renaissance-cities",
            era: "Scientific Observation",
            year: 1543,
            question: "Copernicus publishes a Sun-centered model. Why is this dangerous and important?",
            context: "The geocentric model had deep roots in ancient astronomy, teaching, and theology. A heliocentric model asked readers to rethink evidence, authority, mathematics, and the place of Earth.",
            choices: [
                HistoryChoice(id: "a", text: "It challenges inherited authority with mathematical observation", consequence: "You open a long debate where better models, instruments, and arguments slowly shift what counts as knowledge.", isCorrect: true, historicalOutcome: "Copernicus's heliocentric model did not instantly win, but it reshaped astronomy and helped set up later work by Kepler, Galileo, and Newton."),
                HistoryChoice(id: "b", text: "It proves all ancient learning was worthless overnight", consequence: "That misses the real story. Renaissance science reused ancient math while testing and revising inherited models.", isCorrect: false, historicalOutcome: "Early modern science developed through continuity and challenge: ancient astronomy, new calculations, instruments, and debate all mattered.")
            ],
            historicalFact: "De revolutionibus orbium coelestium appeared in 1543, the year Copernicus died, and became a key reference point in the Scientific Revolution.",
            sourceCitation: "Copernicus, De revolutionibus; Kuhn, The Copernican Revolution"
        )
    ]

    static let nileKingdomsChallenges: [HistoryChallenge] = [
        HistoryChallenge(
            id: "nile-01",
            worldId: "nile-kingdoms",
            era: "Old Kingdom",
            year: -2560,
            question: "A royal building project rises at Giza. What makes pyramid construction possible?",
            context: "The Nile flood cycle, farming surplus, skilled labor organization, stone transport, scribal records, and royal ideology all combine around the pharaoh's monument.",
            choices: [
                HistoryChoice(id: "a", text: "Coordinate seasonal labor, food surplus, stone logistics, and royal authority", consequence: "You read the pyramid as a state project: farming, surveying, accounting, transport, belief, and command all lock together.", isCorrect: true, historicalOutcome: "The Great Pyramid of Khufu was built through organized labor, logistics, and state authority, not by a single simple trick."),
                HistoryChoice(id: "b", text: "Assume one mysterious machine replaces all human planning", consequence: "That shortcut misses the real achievement: administrators, workers, quarry teams, boat crews, and food systems made the project possible.", isCorrect: false, historicalOutcome: "Archaeology points to large organized workforces, worker settlements, provisioning, and transport systems rather than a lost miracle machine.")
            ],
            historicalFact: "Worker villages, bakeries, ramps, quarries, and administrative evidence show pyramid building depended on logistics and labor organization as much as engineering.",
            sourceCitation: "Lehner, The Complete Pyramids; Wadi al-Jarf papyri"
        ),
        HistoryChallenge(
            id: "nile-02",
            worldId: "nile-kingdoms",
            era: "Female Kingship",
            year: -1479,
            question: "Hatshepsut takes full royal titles. How can she strengthen legitimacy in a male-coded office?",
            context: "Egyptian kingship used male language and imagery, but royal women could hold serious power. Hatshepsut governed as pharaoh while linking herself to dynasty, gods, monuments, and prosperity.",
            choices: [
                HistoryChoice(id: "a", text: "Use temple building, divine birth imagery, trade success, and royal titles", consequence: "You turn symbols into political infrastructure: monuments, rituals, and prosperity make rule visible and hard to dismiss.", isCorrect: true, historicalOutcome: "Hatshepsut ruled successfully for about two decades, built major monuments at Deir el-Bahri, and promoted trade expeditions such as Punt."),
                HistoryChoice(id: "b", text: "Hide all evidence of rule and avoid public monuments", consequence: "A silent pharaoh would struggle to claim cosmic order, dynasty, and authority in a society where monuments performed power.", isCorrect: false, historicalOutcome: "Hatshepsut used visible royal display. Later attempts to erase some images show how politically charged her memory became.")
            ],
            historicalFact: "Hatshepsut's mortuary temple at Deir el-Bahri presents divine legitimacy, trade wealth, and royal power in carefully staged images and inscriptions.",
            sourceCitation: "Deir el-Bahri inscriptions; Cooney, The Woman Who Would Be King"
        ),
        HistoryChallenge(
            id: "nile-03",
            worldId: "nile-kingdoms",
            era: "Amarna Revolution",
            year: -1353,
            question: "Akhenaten promotes Aten worship and builds a new capital. What risk does this create?",
            context: "The pharaoh shifts religious focus toward the Aten, moves the court to Akhetaten, and disrupts older priestly networks tied to Amun and traditional temples.",
            choices: [
                HistoryChoice(id: "a", text: "It centralizes power but destabilizes temples, elites, and inherited ritual", consequence: "You feel the strain immediately: a bold reform can concentrate authority while alienating institutions that help the kingdom function.", isCorrect: true, historicalOutcome: "Akhenaten's changes were short-lived. After his death, successors restored older cults and the Amarna experiment was partly erased from official memory."),
                HistoryChoice(id: "b", text: "It creates a smooth reform with no political enemies", consequence: "That underestimates how deeply temples, land, labor, offerings, art, and administration were tied together.", isCorrect: false, historicalOutcome: "The backlash after Akhenaten suggests the reform disrupted powerful religious and political systems.")
            ],
            historicalFact: "The Amarna Letters reveal a Late Bronze Age diplomatic world where Egypt negotiated with other kings and local rulers while internal religious change unfolded.",
            sourceCitation: "Amarna Letters; Kemp, The City of Akhenaten and Nefertiti"
        ),
        HistoryChallenge(
            id: "nile-04",
            worldId: "nile-kingdoms",
            era: "Ptolemaic Egypt",
            year: -196,
            question: "Priests issue a decree in hieroglyphic, demotic, and Greek. Why does this matter centuries later?",
            context: "After Alexander's conquests, Egypt was ruled by the Greek-speaking Ptolemaic dynasty. Multilingual administration connected temple authority, local scripts, and imperial Greek politics.",
            choices: [
                HistoryChoice(id: "a", text: "It preserves the same decree in scripts that later unlock hieroglyphs", consequence: "You spot the future clue: a political text becomes a bridge between languages, scripts, and lost reading systems.", isCorrect: true, historicalOutcome: "The Rosetta Stone carried versions of the same decree in three scripts, allowing Champollion and others to decipher Egyptian hieroglyphs in the 19th century."),
                HistoryChoice(id: "b", text: "It proves everyone in Egypt used only one language", consequence: "The stone says the opposite: rulers, priests, and officials operated across scripts, languages, and communities.", isCorrect: false, historicalOutcome: "Ptolemaic Egypt was multilingual and culturally layered, with Greek administration interacting with older Egyptian temple traditions.")
            ],
            historicalFact: "The Rosetta Stone, carved in 196 BCE, became the key comparison text for deciphering hieroglyphs because it included Greek alongside Egyptian scripts.",
            sourceCitation: "Rosetta Stone decree; Parkinson, Cracking Codes"
        )
    ]

    static let industrialRevolutionChallenges: [HistoryChallenge] = [
        HistoryChallenge(
            id: "industrial-01",
            worldId: "industrial-revolution",
            era: "Steam Power",
            year: 1776,
            question: "Watt's improved steam engine spreads through mines and workshops. What makes it historically important?",
            context: "James Watt's separate condenser made steam engines more efficient than earlier Newcomen engines. Power could now be placed near mines, mills, and factories instead of depending only on wind, water, animals, or muscle.",
            choices: [
                HistoryChoice(id: "a", text: "It helps detach production from local water power", consequence: "You see why factories can cluster, scale, and run more predictably as coal, iron, and machinery reinforce each other.", isCorrect: true, historicalOutcome: "Improved steam engines helped pump mines, power machinery, and support industrial growth. They did not cause industrialization alone, but they changed where and how power could be used."),
                HistoryChoice(id: "b", text: "It instantly replaces every worker with one machine", consequence: "That makes the story too simple. Industrial change was uneven, industry-specific, and still depended on human labor.", isCorrect: false, historicalOutcome: "Factories often increased demand for labor even while changing tasks, discipline, skill, and bargaining power.")
            ],
            historicalFact: "Watt's improvements raised engine efficiency and helped make steam a flexible industrial power source, especially when paired with coal mining and iron production.",
            sourceCitation: "Mokyr, The Lever of Riches; Hills, Power from Steam"
        ),
        HistoryChallenge(
            id: "industrial-02",
            worldId: "industrial-revolution",
            era: "Factory Labor",
            year: 1833,
            question: "Parliament debates limits on child labor in textile factories. What does the Factory Act reveal?",
            context: "Industrial textile mills used long hours, strict discipline, and child labor. Reformers gathered testimony about injuries, exhaustion, schooling, and family poverty while manufacturers warned that regulation would raise costs.",
            choices: [
                HistoryChoice(id: "a", text: "Industrial growth creates social problems that politics starts regulating", consequence: "You connect production gains with new public debates about childhood, schooling, inspection, and the limits of employer power.", isCorrect: true, historicalOutcome: "The 1833 Factory Act restricted work for children in textile mills, required some schooling, and created factory inspectors, though enforcement and coverage remained limited."),
                HistoryChoice(id: "b", text: "Factories already protected every worker equally", consequence: "The testimony points the other way: reform emerged because existing protections were weak and uneven.", isCorrect: false, historicalOutcome: "Industrial labor regulation developed gradually after campaigns exposed harsh conditions, especially for children and women in textile work.")
            ],
            historicalFact: "The 1833 Factory Act introduced inspectors and limited textile factory work for children, making state oversight part of Britain's industrial society.",
            sourceCitation: "Factory Act 1833; Sadler Committee evidence"
        ),
        HistoryChallenge(
            id: "industrial-03",
            worldId: "industrial-revolution",
            era: "Railway Age",
            year: 1830,
            question: "The Liverpool and Manchester Railway opens. Why does rail transport change industrial Britain?",
            context: "Steam railways moved people, coal, cotton, mail, and manufactured goods faster and more reliably than canals and roads. Cities, ports, factories, and markets began to run on tighter timetables.",
            choices: [
                HistoryChoice(id: "a", text: "It compresses distance for goods, workers, news, and markets", consequence: "You feel the map shrink: supply chains speed up, local prices connect, and people begin living by railway time.", isCorrect: true, historicalOutcome: "Railways lowered transport costs, linked industrial regions, accelerated travel, and pushed standard timekeeping because timetables needed coordination."),
                HistoryChoice(id: "b", text: "It matters only for luxury tourism", consequence: "Pleasure travel grew later, but the early railway's deeper impact was industrial, commercial, and social.", isCorrect: false, historicalOutcome: "Railways transformed freight, commuting, regional specialization, military logistics, newspapers, mail, and time discipline.")
            ],
            historicalFact: "Railway timetables helped drive standardized time in Britain, because local solar times made coordinated train schedules impractical.",
            sourceCitation: "Freeman, Railways and the Victorian Imagination; Bagwell, The Transport Revolution"
        ),
        HistoryChallenge(
            id: "industrial-04",
            worldId: "industrial-revolution",
            era: "Public Health",
            year: 1854,
            question: "Cholera strikes Soho. John Snow maps deaths around the Broad Street pump. What is the key lesson?",
            context: "Many officials still accepted miasma theory, blaming foul air for disease. Snow mapped cases and argued contaminated water from a pump better explained the outbreak's pattern.",
            choices: [
                HistoryChoice(id: "a", text: "Use evidence patterns to challenge a popular but weak explanation", consequence: "You remove the pump handle and learn how urban data, sanitation, and disease theory start to reshape city life.", isCorrect: true, historicalOutcome: "Snow's mapping supported the waterborne transmission argument. Germ theory and sanitation reform later changed public health, though acceptance was gradual."),
                HistoryChoice(id: "b", text: "Ignore the map because bad smells explain every case", consequence: "The outbreak pattern stays hidden. A convincing theory still needs to fit observed evidence.", isCorrect: false, historicalOutcome: "Miasma theory influenced sanitation reform, but cholera's spread was better explained by contaminated water in this case.")
            ],
            historicalFact: "Snow's Broad Street pump investigation became a classic example of epidemiological reasoning: mapping cases to test explanations about disease spread.",
            sourceCitation: "Snow, On the Mode of Communication of Cholera; Johnson, The Ghost Map"
        )
    ]
    
    static func challenges(for worldId: String) -> [HistoryChallenge] {
        switch worldId {
        case "ancient-rome": return ancientRomeChallenges
        case "medieval-europe": return medievalEuropeChallenges
        case "age-discovery": return ageDiscoveryChallenges
        case "renaissance-cities": return renaissanceCitiesChallenges
        case "nile-kingdoms": return nileKingdomsChallenges
        case "industrial-revolution": return industrialRevolutionChallenges
        default: return []
        }
    }
    
    static func allChallenges(for subject: Subject) -> [HistoryChallenge] {
        switch subject {
        case .history: return ancientRomeChallenges + medievalEuropeChallenges + ageDiscoveryChallenges + renaissanceCitiesChallenges + nileKingdomsChallenges + industrialRevolutionChallenges
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

    static let quantumRealmChallenges: [ScienceChallenge] = [
        ScienceChallenge(
            id: "quantum-01",
            worldId: "quantum-realm",
            era: "1900",
            question: "Why did Max Planck introduce the idea of energy quanta?",
            context: "A blackbody oven glowed with a spectrum classical physics could not explain. Planck found that the math worked if energy came in small packets rather than any continuous amount.",
            choices: [
                ScienceChoice(id: "a", text: "To explain blackbody radiation", isCorrect: true, explanation: "Correct. Planck modeled energy exchange in discrete packets, later called quanta, to match the observed blackbody spectrum."),
                ScienceChoice(id: "b", text: "To prove atoms do not exist", isCorrect: false, explanation: "Quantum theory did not disprove atoms. It became part of the evidence-rich physics used to explain atomic behavior."),
                ScienceChoice(id: "c", text: "To describe planetary orbits around the Sun", isCorrect: false, explanation: "Planetary motion is described well by gravity. Planck was working on thermal radiation from hot objects."),
                ScienceChoice(id: "d", text: "To make light travel faster than normal", isCorrect: false, explanation: "Quantum theory did not change the speed limit of light. It changed how physicists understood energy and matter at small scales.")
            ],
            funFact: "Planck originally treated quantization as a mathematical move, but it opened the door to modern quantum physics.",
            field: "Quantum Origins"
        ),
        ScienceChallenge(
            id: "quantum-02",
            worldId: "quantum-realm",
            era: "1905",
            question: "What did Einstein argue in his explanation of the photoelectric effect?",
            context: "Metal plates release electrons when hit by light, but only if the light has high enough frequency. Brighter low-frequency light still fails to eject them.",
            choices: [
                ScienceChoice(id: "a", text: "Light can act as packets of energy", isCorrect: true, explanation: "Correct. Einstein explained the effect by treating light as photons whose energy depends on frequency."),
                ScienceChoice(id: "b", text: "Only sound waves can move electrons", isCorrect: false, explanation: "The photoelectric effect is caused by light interacting with electrons, not sound."),
                ScienceChoice(id: "c", text: "Electron energy depends only on brightness", isCorrect: false, explanation: "Brightness affects how many photons arrive, but frequency determines whether each photon has enough energy to eject an electron."),
                ScienceChoice(id: "d", text: "Metals glow because they are radioactive", isCorrect: false, explanation: "The photoelectric effect does not require radioactivity. It is an interaction between light and electrons in a material.")
            ],
            funFact: "Einstein received the 1921 Nobel Prize in Physics especially for explaining the photoelectric effect, not for relativity.",
            field: "Photons"
        ),
        ScienceChallenge(
            id: "quantum-03",
            worldId: "quantum-realm",
            era: "1927",
            question: "What does Heisenberg's uncertainty principle say?",
            context: "In the quantum vault, a particle is not a tiny billiard ball with every property sharply fixed before measurement. Some pairs of properties trade precision.",
            choices: [
                ScienceChoice(id: "a", text: "Position and momentum cannot both be known exactly", isCorrect: true, explanation: "Correct. The more precisely position is known, the less precisely momentum can be known, and vice versa."),
                ScienceChoice(id: "b", text: "Scientists are uncertain only because tools are bad", isCorrect: false, explanation: "Better tools do not remove the limit. The uncertainty principle is built into quantum mechanics."),
                ScienceChoice(id: "c", text: "Particles randomly ignore all physical laws", isCorrect: false, explanation: "Quantum mechanics is highly predictive. It uses probabilities, not lawless randomness."),
                ScienceChoice(id: "d", text: "Gravity stops working inside atoms", isCorrect: false, explanation: "Gravity still exists, but it is extremely weak compared with electromagnetic and nuclear forces at atomic scales.")
            ],
            funFact: "The uncertainty principle is not just measurement error; it follows from the wave-like math of quantum states.",
            field: "Measurement"
        ),
        ScienceChallenge(
            id: "quantum-04",
            worldId: "quantum-realm",
            era: "Modern",
            question: "Why can quantum tunneling matter in real technology?",
            context: "A particle reaches a barrier it does not seem to have enough energy to cross. In quantum mechanics, there can still be a small chance it appears on the other side.",
            choices: [
                ScienceChoice(id: "a", text: "It allows particles to pass through barriers probabilistically", isCorrect: true, explanation: "Correct. Tunneling lets particles cross barriers with a probability set by the barrier and the particle's quantum state."),
                ScienceChoice(id: "b", text: "It lets large objects walk through walls on command", isCorrect: false, explanation: "Tunneling is important at tiny scales. For large everyday objects, the probability is effectively zero."),
                ScienceChoice(id: "c", text: "It proves energy is never conserved", isCorrect: false, explanation: "Quantum tunneling does not break energy conservation. It changes how barriers and wavefunctions are understood."),
                ScienceChoice(id: "d", text: "It only happens in science fiction", isCorrect: false, explanation: "Tunneling is real and used to explain alpha decay, scanning tunneling microscopes, and behavior in some electronic devices.")
            ],
            funFact: "Scanning tunneling microscopes use tunneling current to image surfaces with atomic-scale detail.",
            field: "Quantum Technology"
        )
    ]

    static let earthSystemsChallenges: [ScienceChallenge] = [
        ScienceChallenge(
            id: "earth-01",
            worldId: "earth-systems",
            era: "Modern Climate",
            question: "Why do greenhouse gases warm Earth's surface?",
            context: "Sunlight reaches the ground, the surface releases heat as infrared radiation, and some gases absorb and re-emit part of that heat instead of letting it escape directly to space.",
            choices: [
                ScienceChoice(id: "a", text: "They absorb and re-emit infrared heat from Earth", isCorrect: true, explanation: "Correct. Greenhouse gases such as carbon dioxide, methane, and water vapor interact with outgoing infrared radiation, warming the lower atmosphere and surface."),
                ScienceChoice(id: "b", text: "They block all sunlight before it reaches the ground", isCorrect: false, explanation: "Most sunlight still reaches the surface. The key greenhouse effect involves outgoing infrared heat."),
                ScienceChoice(id: "c", text: "They create heat from nothing", isCorrect: false, explanation: "They do not create energy from nothing. They change how energy leaves the Earth system."),
                ScienceChoice(id: "d", text: "They only matter at night", isCorrect: false, explanation: "The greenhouse effect operates continuously, though local temperature patterns also depend on sunlight, clouds, land, and oceans.")
            ],
            funFact: "Without the natural greenhouse effect, Earth's average surface temperature would be far below freezing; extra greenhouse gases strengthen that heat-trapping effect.",
            field: "Climate Physics"
        ),
        ScienceChallenge(
            id: "earth-02",
            worldId: "earth-systems",
            era: "Water Cycle",
            question: "A warm ocean surface feeds a storm. Which process loads the air with water vapor?",
            context: "The mission map shows sunlight over ocean, rising humid air, clouds, and heavy rain over land. The first move is water changing from liquid to gas.",
            choices: [
                ScienceChoice(id: "a", text: "Evaporation", isCorrect: true, explanation: "Correct. Evaporation moves liquid water from oceans, lakes, and soils into the atmosphere as vapor."),
                ScienceChoice(id: "b", text: "Subduction", isCorrect: false, explanation: "Subduction is a plate tectonic process where one plate sinks beneath another."),
                ScienceChoice(id: "c", text: "Photosynthesis", isCorrect: false, explanation: "Photosynthesis uses light energy to build sugars in plants and algae; it is not the main ocean-to-air water transfer."),
                ScienceChoice(id: "d", text: "Magnetism", isCorrect: false, explanation: "Magnetism shapes compass behavior and Earth's magnetic field, not the basic water cycle step here.")
            ],
            funFact: "Most water vapor enters the atmosphere through evaporation from oceans, then later condenses into clouds and returns as precipitation.",
            field: "Hydrology"
        ),
        ScienceChallenge(
            id: "earth-03",
            worldId: "earth-systems",
            era: "Carbon Cycle",
            question: "Why can cutting forests increase carbon dioxide in the atmosphere?",
            context: "A forest stores carbon in trunks, roots, soils, and leaves. After clearing, stored carbon can be released by burning or decay, and fewer trees remain to absorb carbon dioxide through growth.",
            choices: [
                ScienceChoice(id: "a", text: "It releases stored carbon and reduces future uptake", isCorrect: true, explanation: "Correct. Deforestation can emit stored carbon and remove a living sink that would have taken up carbon dioxide."),
                ScienceChoice(id: "b", text: "Trees are made only of water", isCorrect: false, explanation: "Trees contain lots of carbon-based biomass, including wood, roots, bark, and leaves."),
                ScienceChoice(id: "c", text: "Soils cannot store carbon", isCorrect: false, explanation: "Soils can store large amounts of organic carbon, and land-use change can disturb those stores."),
                ScienceChoice(id: "d", text: "Carbon dioxide disappears when plants are removed", isCorrect: false, explanation: "Removing plants usually reduces carbon uptake, not atmospheric carbon dioxide itself.")
            ],
            funFact: "Forests are both carbon stores and carbon sinks; whether a landscape absorbs or releases carbon depends on growth, disturbance, decay, fire, and land use.",
            field: "Carbon Cycle"
        ),
        ScienceChallenge(
            id: "earth-04",
            worldId: "earth-systems",
            era: "Ecosystems",
            question: "What can happen when a keystone species is removed from an ecosystem?",
            context: "The simulation removes one predator from a coastal food web. Prey populations shift, vegetation changes, and habitat structure begins to transform.",
            choices: [
                ScienceChoice(id: "a", text: "A cascade of changes can spread through the food web", isCorrect: true, explanation: "Correct. Keystone species have effects larger than their abundance, so losing one can trigger trophic cascades and habitat changes."),
                ScienceChoice(id: "b", text: "Only that one species changes", isCorrect: false, explanation: "Species interact through predation, competition, shelter, pollination, and nutrient cycling, so one loss can affect many others."),
                ScienceChoice(id: "c", text: "Every ecosystem instantly becomes more stable", isCorrect: false, explanation: "Removing a keystone species can destabilize ecosystems rather than strengthen them."),
                ScienceChoice(id: "d", text: "Food webs stop needing energy", isCorrect: false, explanation: "Energy flow remains fundamental. The issue is how relationships and population pressures change.")
            ],
            funFact: "Sea otters are a classic keystone example: by eating sea urchins, they can help kelp forests persist in some coastal ecosystems.",
            field: "Ecology"
        )
    ]

    static let humanBodyLabChallenges: [ScienceChallenge] = [
        ScienceChallenge(
            id: "body-01",
            worldId: "human-body-lab",
            era: "Breathing",
            question: "What actually moves oxygen from the air into your blood?",
            context: "In the lung mission, inhaled air reaches millions of tiny alveoli wrapped in capillaries. Oxygen crosses a thin moist surface into blood while carbon dioxide moves the other way.",
            choices: [
                ScienceChoice(id: "a", text: "Diffusion across thin alveoli into capillaries", isCorrect: true, explanation: "Correct. Oxygen moves down its concentration gradient across the alveolar-capillary membrane and binds to hemoglobin in red blood cells."),
                ScienceChoice(id: "b", text: "The stomach pumps oxygen directly into arteries", isCorrect: false, explanation: "The stomach digests food. Gas exchange happens in the lungs, not the digestive tract."),
                ScienceChoice(id: "c", text: "Bones create oxygen whenever muscles move", isCorrect: false, explanation: "Bone marrow makes blood cells, but it does not create oxygen for the body."),
                ScienceChoice(id: "d", text: "The heart pulls oxygen through skin pores", isCorrect: false, explanation: "Human skin is not the main respiratory surface. The heart circulates blood after lungs load it with oxygen.")
            ],
            funFact: "Alveoli create a huge exchange surface inside the lungs, helping oxygen enter blood fast enough to support active tissues.",
            field: "Respiration"
        ),
        ScienceChallenge(
            id: "body-02",
            worldId: "human-body-lab",
            era: "Circulation",
            question: "Why does heart rate rise when you sprint up stairs?",
            context: "Working muscles need more oxygen and glucose and produce more carbon dioxide and heat. The circulatory system has to deliver and remove materials faster.",
            choices: [
                ScienceChoice(id: "a", text: "To increase blood flow to working muscles", isCorrect: true, explanation: "Correct. A faster heart rate helps raise cardiac output so muscles receive more oxygen and nutrients while wastes are carried away."),
                ScienceChoice(id: "b", text: "To stop blood from reaching muscles", isCorrect: false, explanation: "Exercise usually increases blood flow to active muscles, not blocks it."),
                ScienceChoice(id: "c", text: "Because blood turns into air during exercise", isCorrect: false, explanation: "Blood remains blood. It carries gases, nutrients, cells, hormones, and waste products."),
                ScienceChoice(id: "d", text: "Because bones need to beat in rhythm", isCorrect: false, explanation: "Bones provide structure and blood cell production, but they do not beat like the heart.")
            ],
            funFact: "Cardiac output equals heart rate times stroke volume; both can change during exercise to meet tissue demand.",
            field: "Cardiovascular"
        ),
        ScienceChallenge(
            id: "body-03",
            worldId: "human-body-lab",
            era: "Nervous System",
            question: "A hot pan touches your finger. Why can your hand pull away before you consciously process the pain?",
            context: "The reflex mission shows sensory neurons carrying danger signals to the spinal cord, where motor neurons can trigger a quick withdrawal response before the brain finishes interpreting the event.",
            choices: [
                ScienceChoice(id: "a", text: "A spinal reflex can trigger fast withdrawal", isCorrect: true, explanation: "Correct. Reflex arcs can route through the spinal cord for speed, while signals also travel to the brain for conscious pain perception."),
                ScienceChoice(id: "b", text: "Pain signals wait several minutes before moving", isCorrect: false, explanation: "Pain and heat signals can travel quickly; reflexes are designed for rapid protection."),
                ScienceChoice(id: "c", text: "The liver decides which muscles contract", isCorrect: false, explanation: "The liver has many metabolic roles, but motor commands for a reflex route through the nervous system."),
                ScienceChoice(id: "d", text: "Skin cells become tiny muscles", isCorrect: false, explanation: "Skin detects the stimulus; muscles perform the withdrawal.")
            ],
            funFact: "Fast reflexes protect tissue by shortening the time between danger detection and movement.",
            field: "Neural Reflexes"
        ),
        ScienceChallenge(
            id: "body-04",
            worldId: "human-body-lab",
            era: "Immunity",
            question: "Why do vaccines train immune memory without needing you to suffer the full disease?",
            context: "The immune lab presents a harmless piece, weakened form, or genetic instruction linked to a pathogen. Immune cells learn the pattern and build memory for faster future response.",
            choices: [
                ScienceChoice(id: "a", text: "They expose the immune system to a safe target pattern", isCorrect: true, explanation: "Correct. Vaccines help the adaptive immune system recognize antigens and form memory cells, reducing risk from later infection."),
                ScienceChoice(id: "b", text: "They replace the immune system forever", isCorrect: false, explanation: "Vaccines work with your immune system. They do not replace it."),
                ScienceChoice(id: "c", text: "They make pathogens helpful nutrients", isCorrect: false, explanation: "Vaccines do not turn pathogens into food; they prepare immune recognition and response."),
                ScienceChoice(id: "d", text: "They prevent every illness instantly", isCorrect: false, explanation: "Vaccine protection varies by disease and time. The main idea is trained immune memory and reduced risk or severity.")
            ],
            funFact: "Adaptive immune memory is why a second encounter with the same pathogen pattern can produce a faster, stronger response.",
            field: "Immune Memory"
        )
    ]
    
    static func challenges(for worldId: String) -> [ScienceChallenge] {
        switch worldId {
        case "space-exploration": return spaceExplorationChallenges
        case "quantum-realm": return quantumRealmChallenges
        case "earth-systems": return earthSystemsChallenges
        case "human-body-lab": return humanBodyLabChallenges
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

    static let africanWondersChallenges: [GeographyChallenge] = [
        GeographyChallenge(
            id: "geo-africa-01",
            worldId: "african-wonders",
            region: "Nile Basin",
            question: "Which river valley linked ancient Egyptian cities with farming, transport, and predictable flood cycles?",
            context: "Your field map shows a green corridor through desert. Settlements, temples, and grain stores cluster near a river that flows north toward the Mediterranean.",
            choices: [
                GeographyChoice(id: "a", text: "The Nile", isCorrect: true, explanation: "Correct. The Nile supported agriculture, transport, and state power in ancient Egypt, especially through its annual flood cycle."),
                GeographyChoice(id: "b", text: "The Niger", isCorrect: false, explanation: "The Niger is vital in West Africa, but it is not the river valley of ancient Egypt."),
                GeographyChoice(id: "c", text: "The Zambezi", isCorrect: false, explanation: "The Zambezi flows in southern Africa and is famous for Victoria Falls, not Egyptian agriculture."),
                GeographyChoice(id: "d", text: "The Congo", isCorrect: false, explanation: "The Congo drains central Africa's rainforest basin, far from the Egyptian Nile valley.")
            ],
            mapClue: "Trace the long river corridor from northeast Africa to the Mediterranean delta.",
            mapTargetLabel: "Nile Valley",
            mapStartX: 0.58,
            mapStartY: 0.66,
            mapTargetX: 0.62,
            mapTargetY: 0.30,
            fieldNote: "The Nile made dense farming possible in a dry region, helping Egypt sustain cities, officials, armies, and monumental building."
        ),
        GeographyChallenge(
            id: "geo-africa-02",
            worldId: "african-wonders",
            region: "East African Rift",
            question: "Which mountain is Africa's highest peak and rises near the East African Rift?",
            context: "The expedition turns toward volcanic highlands. Snow can appear near the summit even though the mountain stands close to the equator.",
            choices: [
                GeographyChoice(id: "a", text: "Mount Kilimanjaro", isCorrect: true, explanation: "Correct. Kilimanjaro in Tanzania is Africa's highest mountain at 5,895 meters."),
                GeographyChoice(id: "b", text: "Table Mountain", isCorrect: false, explanation: "Table Mountain overlooks Cape Town, but it is much lower and far south."),
                GeographyChoice(id: "c", text: "Mount Toubkal", isCorrect: false, explanation: "Toubkal is the highest peak in the Atlas Mountains of Morocco, not Africa's highest overall."),
                GeographyChoice(id: "d", text: "Drakensberg", isCorrect: false, explanation: "The Drakensberg range is important in southern Africa, but Kilimanjaro is higher.")
            ],
            mapClue: "Look for the equatorial volcano in northern Tanzania, near Kenya and the Rift Valley.",
            mapTargetLabel: "Kilimanjaro",
            mapStartX: 0.52,
            mapStartY: 0.50,
            mapTargetX: 0.65,
            mapTargetY: 0.54,
            fieldNote: "Kilimanjaro is a volcanic massif with distinct climate zones, from cultivated foothills to alpine desert and summit ice."
        ),
        GeographyChallenge(
            id: "geo-africa-03",
            worldId: "african-wonders",
            region: "Sahara",
            question: "Why did historic caravan routes often depend on oasis towns across the Sahara?",
            context: "Your route crosses a huge dry belt. Traders carried salt, gold, books, and textiles, but survival depended on reliable water and resting points.",
            choices: [
                GeographyChoice(id: "a", text: "Oases provided water, shade, and trade stops", isCorrect: true, explanation: "Correct. Oasis towns made desert crossings possible by supplying water, food, rest, and exchange points."),
                GeographyChoice(id: "b", text: "Oases made the Sahara humid everywhere", isCorrect: false, explanation: "Oases are local water sources. They do not change the climate of the whole desert."),
                GeographyChoice(id: "c", text: "Caravans avoided all towns by design", isCorrect: false, explanation: "Caravans needed networks of settlements and guides because desert travel was risky."),
                GeographyChoice(id: "d", text: "Trade routes only followed rivers", isCorrect: false, explanation: "Some routes connected rivers, but long Sahara crossings depended heavily on wells and oases.")
            ],
            mapClue: "Follow the desert belt between North Africa and the Sahel, where small water nodes matter.",
            mapTargetLabel: "Sahara Oases",
            mapStartX: 0.45,
            mapStartY: 0.62,
            mapTargetX: 0.48,
            mapTargetY: 0.38,
            fieldNote: "Trans-Saharan routes connected Mediterranean markets with West African kingdoms and helped cities such as Timbuktu become centers of trade and learning."
        ),
        GeographyChallenge(
            id: "geo-africa-04",
            worldId: "african-wonders",
            region: "Southern Africa",
            question: "Which waterfall forms where the Zambezi River drops into a deep gorge on the Zambia-Zimbabwe border?",
            context: "The map clue is not just a dot. It is a river, a border, spray visible from far away, and a gorge system carved by moving water.",
            choices: [
                GeographyChoice(id: "a", text: "Victoria Falls", isCorrect: true, explanation: "Correct. Victoria Falls sits on the Zambezi River at the border of Zambia and Zimbabwe."),
                GeographyChoice(id: "b", text: "Angel Falls", isCorrect: false, explanation: "Angel Falls is in Venezuela, not Africa."),
                GeographyChoice(id: "c", text: "Niagara Falls", isCorrect: false, explanation: "Niagara Falls is on the US-Canada border."),
                GeographyChoice(id: "d", text: "Tugela Falls", isCorrect: false, explanation: "Tugela Falls is in South Africa's Drakensberg, not on the Zambezi border gorge.")
            ],
            mapClue: "Track the Zambezi through southern Africa until it drops between Zambia and Zimbabwe.",
            mapTargetLabel: "Victoria Falls",
            mapStartX: 0.60,
            mapStartY: 0.52,
            mapTargetX: 0.58,
            mapTargetY: 0.76,
            fieldNote: "Victoria Falls is one of the world's largest waterfall systems by combined width and height, and its local Lozi name, Mosi-oa-Tunya, means 'the smoke that thunders.'"
        )
    ]

    static let silkRoadRoutesChallenges: [GeographyChallenge] = [
        GeographyChallenge(
            id: "geo-silk-01",
            worldId: "silk-road-routes",
            region: "Tarim Basin",
            question: "Why did Silk Road caravans often skirt the Taklamakan Desert instead of crossing straight through its center?",
            context: "Your caravan needs water, fodder, guides, and resting towns. The shortest line across the map is not the safest route through one of Asia's harshest deserts.",
            choices: [
                GeographyChoice(id: "a", text: "Oasis towns around the desert edge made travel possible", isCorrect: true, explanation: "Correct. Routes commonly followed oasis chains around the Taklamakan because water and supplies mattered more than a straight line."),
                GeographyChoice(id: "b", text: "The desert center had the largest permanent cities", isCorrect: false, explanation: "Permanent settlements were tied to water sources, especially around oasis margins, not the dry interior."),
                GeographyChoice(id: "c", text: "Caravans avoided mountains but preferred open sand", isCorrect: false, explanation: "Open sand could be deadly without water. Geography forced traders to balance deserts, passes, and oasis networks."),
                GeographyChoice(id: "d", text: "Sea winds pushed caravans north", isCorrect: false, explanation: "The Tarim Basin is inland; caravan routes were shaped by water, terrain, and political control.")
            ],
            mapClue: "Trace the oasis necklace around the Taklamakan between Kashgar, Khotan, and Dunhuang.",
            mapTargetLabel: "Taklamakan Edge",
            mapStartX: 0.31,
            mapStartY: 0.54,
            mapTargetX: 0.56,
            mapTargetY: 0.48,
            fieldNote: "Oasis cities such as Kashgar, Khotan, Turfan, and Dunhuang became route nodes because desert geography concentrated people, trade, and information."
        ),
        GeographyChallenge(
            id: "geo-silk-02",
            worldId: "silk-road-routes",
            region: "Pamir and Tian Shan",
            question: "Which terrain feature made places like Kashgar strategic meeting points for Silk Road routes?",
            context: "Your route leaves China and approaches Central Asia. Roads funnel through high passes where mountains narrow the number of practical crossings.",
            choices: [
                GeographyChoice(id: "a", text: "Mountain passes linking basins and valleys", isCorrect: true, explanation: "Correct. Kashgar sat near routes through the Pamir, Tian Shan, and Kunlun systems, where passes controlled movement."),
                GeographyChoice(id: "b", text: "A deep ocean harbor", isCorrect: false, explanation: "Kashgar is far inland. Its importance came from overland routes, not maritime access."),
                GeographyChoice(id: "c", text: "A tropical rainforest corridor", isCorrect: false, explanation: "The region is arid and mountainous, not tropical rainforest."),
                GeographyChoice(id: "d", text: "A polar ice shelf crossing", isCorrect: false, explanation: "High-altitude cold mattered, but Silk Road geography here was about passes through mountain systems.")
            ],
            mapClue: "Look west of the Tarim Basin where caravan roads squeeze through the high mountains.",
            mapTargetLabel: "Kashgar Passes",
            mapStartX: 0.59,
            mapStartY: 0.47,
            mapTargetX: 0.39,
            mapTargetY: 0.45,
            fieldNote: "Mountain gateways turned certain towns into brokerage points for goods, languages, currencies, religions, and diplomatic news."
        ),
        GeographyChallenge(
            id: "geo-silk-03",
            worldId: "silk-road-routes",
            region: "Sogdian Trade Cities",
            question: "Which city was a major Silk Road hub in Transoxiana, between the Amu Darya and Syr Darya river systems?",
            context: "The caravan enters a region of irrigated cities and merchant networks. This city linked Persian, Turkic, Chinese, and Islamic worlds across Central Asia.",
            choices: [
                GeographyChoice(id: "a", text: "Samarkand", isCorrect: true, explanation: "Correct. Samarkand was a major Central Asian hub in Transoxiana and a famous Silk Road city."),
                GeographyChoice(id: "b", text: "Reykjavik", isCorrect: false, explanation: "Reykjavik is in Iceland and was not part of Central Asian caravan networks."),
                GeographyChoice(id: "c", text: "Cape Town", isCorrect: false, explanation: "Cape Town is in southern Africa and belongs to a very different maritime geography."),
                GeographyChoice(id: "d", text: "Kyoto", isCorrect: false, explanation: "Kyoto is historically important in Japan, but this clue points to Central Asia.")
            ],
            mapClue: "Find the irrigated hub east of the Iranian plateau and west of the Tian Shan route gates.",
            mapTargetLabel: "Samarkand",
            mapStartX: 0.43,
            mapStartY: 0.46,
            mapTargetX: 0.28,
            mapTargetY: 0.50,
            fieldNote: "Sogdian merchants helped connect long-distance trade across Eurasia; Samarkand's location made it a durable crossroads."
        ),
        GeographyChallenge(
            id: "geo-silk-04",
            worldId: "silk-road-routes",
            region: "Maritime Silk Roads",
            question: "Why did monsoon wind patterns matter for Indian Ocean Silk Road trade?",
            context: "Your route shifts from caravan tracks to sea lanes. Ships could time departures because seasonal winds reversed direction across the Indian Ocean.",
            choices: [
                GeographyChoice(id: "a", text: "Seasonal winds helped sailors plan outbound and return voyages", isCorrect: true, explanation: "Correct. Monsoon reversals made predictable sailing calendars possible between East Africa, Arabia, India, and Southeast Asia."),
                GeographyChoice(id: "b", text: "Monsoons made all ocean routes windless", isCorrect: false, explanation: "Monsoons are wind systems, not the absence of wind."),
                GeographyChoice(id: "c", text: "They only mattered in the Arctic Ocean", isCorrect: false, explanation: "The clue is about Indian Ocean routes, where monsoon winds shaped navigation."),
                GeographyChoice(id: "d", text: "They stopped ports from trading with each other", isCorrect: false, explanation: "Reliable seasonal winds often increased long-distance exchange by making timing more predictable.")
            ],
            mapClue: "Follow sea lanes from the Arabian Sea toward India and Southeast Asia, then wait for the wind to reverse.",
            mapTargetLabel: "Monsoon Routes",
            mapStartX: 0.22,
            mapStartY: 0.65,
            mapTargetX: 0.63,
            mapTargetY: 0.72,
            fieldNote: "The Silk Roads were not only overland. Indian Ocean routes moved silk, spices, ceramics, ideas, and people through ports timed around monsoon seasons."
        )
    ]

    static let pacificRingChallenges: [GeographyChallenge] = [
        GeographyChallenge(
            id: "geo-pacific-01",
            worldId: "pacific-ring",
            region: "Andean Margin",
            question: "Why do the Andes line the western edge of South America with frequent volcanoes and earthquakes?",
            context: "Your expedition follows the Pacific coast from Peru toward Chile. A dense oceanic plate dives beneath the continent, building mountains and feeding volcanic arcs.",
            choices: [
                GeographyChoice(id: "a", text: "The Nazca Plate subducts beneath South America", isCorrect: true, explanation: "Correct. Subduction of the Nazca Plate under the South American Plate helps create the Andes, earthquakes, and volcanoes."),
                GeographyChoice(id: "b", text: "A desert wind pushes mountains upward", isCorrect: false, explanation: "Wind shapes erosion and dunes, but it does not build a continental mountain chain."),
                GeographyChoice(id: "c", text: "The Amazon River deposits lava along the coast", isCorrect: false, explanation: "Rivers move sediment and water, not lava from deep plate boundaries."),
                GeographyChoice(id: "d", text: "South America floats over a calm inactive plate", isCorrect: false, explanation: "The western margin is highly active because plates converge there.")
            ],
            mapClue: "Follow the ocean trench and volcano belt along Peru and Chile where the Pacific floor bends under the continent.",
            mapTargetLabel: "Andes Margin",
            mapStartX: 0.28,
            mapStartY: 0.68,
            mapTargetX: 0.22,
            mapTargetY: 0.76,
            fieldNote: "The Peru-Chile Trench marks one of Earth's major subduction zones, where plate motion helps raise the Andes and trigger powerful earthquakes."
        ),
        GeographyChallenge(
            id: "geo-pacific-02",
            worldId: "pacific-ring",
            region: "Japan Trench",
            question: "Which hazard can a powerful offshore subduction earthquake create for Japan's Pacific coast?",
            context: "The map shows a quake under the seafloor east of Honshu. If the seabed suddenly shifts, it can move a huge volume of ocean water toward shore.",
            choices: [
                GeographyChoice(id: "a", text: "A tsunami", isCorrect: true, explanation: "Correct. Large undersea earthquakes can displace water and generate tsunamis that travel quickly across the ocean."),
                GeographyChoice(id: "b", text: "A permanent monsoon reversal", isCorrect: false, explanation: "Monsoon winds are seasonal atmospheric patterns, not direct products of a sudden seafloor rupture."),
                GeographyChoice(id: "c", text: "A new desert in Hokkaido overnight", isCorrect: false, explanation: "Earthquakes do not instantly create regional deserts."),
                GeographyChoice(id: "d", text: "A total stop to all tides", isCorrect: false, explanation: "Tides are mainly driven by the Moon and Sun. A tsunami is a separate wave process.")
            ],
            mapClue: "Look just offshore from northeastern Honshu, where the Pacific Plate descends near the Japan Trench.",
            mapTargetLabel: "Japan Trench",
            mapStartX: 0.70,
            mapStartY: 0.36,
            mapTargetX: 0.78,
            mapTargetY: 0.38,
            fieldNote: "The 2011 Tohoku earthquake and tsunami showed how subduction zones link offshore plate motion with coastal risk, preparedness, and land-use decisions."
        ),
        GeographyChallenge(
            id: "geo-pacific-03",
            worldId: "pacific-ring",
            region: "Aleutian Arc",
            question: "Why does Alaska's Aleutian chain form a curved string of volcanic islands?",
            context: "Your route crosses the northern Pacific. The islands are not random dots; they trace a boundary where one plate sinks beneath another in an arc.",
            choices: [
                GeographyChoice(id: "a", text: "Subduction creates magma that feeds an island arc", isCorrect: true, explanation: "Correct. The Pacific Plate subducts beneath the North American Plate, producing magma and the Aleutian volcanic island arc."),
                GeographyChoice(id: "b", text: "Glaciers arrange islands into perfect circles", isCorrect: false, explanation: "Glaciers shape landforms, but the Aleutian arc is primarily tied to plate convergence."),
                GeographyChoice(id: "c", text: "Coral reefs grow fastest in Arctic water", isCorrect: false, explanation: "The Aleutians are cold volcanic islands, not tropical coral atolls."),
                GeographyChoice(id: "d", text: "The islands are the tops of buried skyscrapers", isCorrect: false, explanation: "They are natural volcanic islands formed by tectonic processes.")
            ],
            mapClue: "Trace the arc from mainland Alaska toward Kamchatka along the northern Pacific plate boundary.",
            mapTargetLabel: "Aleutian Arc",
            mapStartX: 0.56,
            mapStartY: 0.24,
            mapTargetX: 0.48,
            mapTargetY: 0.20,
            fieldNote: "Island arcs often form where oceanic plates subduct, making curved chains of volcanoes such as the Aleutians, Japan, and parts of Indonesia."
        ),
        GeographyChallenge(
            id: "geo-pacific-04",
            worldId: "pacific-ring",
            region: "New Zealand Boundary",
            question: "Why is New Zealand such a useful place to study active plate-boundary landscapes?",
            context: "The field map shows the Alpine Fault, uplifted mountains, offshore trenches, and volcanic zones. Several boundary styles meet across a compact set of islands.",
            choices: [
                GeographyChoice(id: "a", text: "It sits across the Pacific and Australian plate boundary", isCorrect: true, explanation: "Correct. New Zealand straddles a complex boundary between the Pacific and Australian plates, including strike-slip motion, subduction, uplift, and volcanism."),
                GeographyChoice(id: "b", text: "It is thousands of kilometers from any plate edge", isCorrect: false, explanation: "New Zealand is directly shaped by an active plate boundary."),
                GeographyChoice(id: "c", text: "Its mountains are only artificial tourist structures", isCorrect: false, explanation: "The Southern Alps and other landforms are natural, shaped by tectonic uplift, erosion, and climate."),
                GeographyChoice(id: "d", text: "It has no earthquakes because it is an island country", isCorrect: false, explanation: "Island status does not prevent earthquakes; New Zealand has significant seismic hazard.")
            ],
            mapClue: "Find the plate boundary cutting through New Zealand, from the Alpine Fault to volcanic North Island zones.",
            mapTargetLabel: "New Zealand",
            mapStartX: 0.78,
            mapStartY: 0.74,
            mapTargetX: 0.83,
            mapTargetY: 0.82,
            fieldNote: "New Zealand compresses several plate-boundary processes into a small region, making it a strong real-world case for reading earthquakes, mountains, volcanoes, and hazards together."
        )
    ]

    static func challenges(for worldId: String) -> [GeographyChallenge] {
        switch worldId {
        case "european-capitals": return europeanCapitalsChallenges
        case "african-wonders": return africanWondersChallenges
        case "silk-road-routes": return silkRoadRoutesChallenges
        case "pacific-ring": return pacificRingChallenges
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

    static let probabilityCasinoChallenges: [MathChallenge] = [
        MathChallenge(
            id: "math-probability-01",
            worldId: "probability-casino",
            domain: "Expected Value",
            question: "A game pays 12 chips on a win, but you win only 1 time in 6. It costs 3 chips to play. Is the game fair?",
            context: "The table is bright, loud, and designed to make the jackpot feel close. Ignore the lights. Compare the average payout with the entry cost.",
            choices: [
                MathChoice(id: "a", text: "No, the expected payout is 2 chips, below the 3-chip cost", isCorrect: true, explanation: "Correct. 12 x 1/6 = 2 chips on average, so paying 3 chips loses 1 chip per play over time."),
                MathChoice(id: "b", text: "Yes, because 12 is bigger than 3", isCorrect: false, explanation: "The prize is bigger than the cost, but it happens rarely. Probability must be included."),
                MathChoice(id: "c", text: "Yes, because every sixth play must win", isCorrect: false, explanation: "A 1-in-6 chance does not guarantee one win in each block of six. Random results can cluster."),
                MathChoice(id: "d", text: "No, because winning is impossible", isCorrect: false, explanation: "Winning is possible. The problem is that the average return is lower than the cost.")
            ],
            patternClue: "Expected value = payout x probability, then compare it with cost.",
            ruleExplanation: "Expected value is the long-run average result. A positive-looking jackpot can still be a bad bet when the probability is low."
        ),
        MathChallenge(
            id: "math-probability-02",
            worldId: "probability-casino",
            domain: "Independent Events",
            question: "A fair coin lands heads five times in a row. What is the chance the next flip is heads?",
            context: "The dealer says tails is due. The crowd nods. Your job is to separate memory from math.",
            choices: [
                MathChoice(id: "a", text: "1/2", isCorrect: true, explanation: "Correct. For a fair coin, each flip is independent. Previous heads do not change the next flip."),
                MathChoice(id: "b", text: "Almost 0, because heads already happened too much", isCorrect: false, explanation: "That is the gambler's fallacy. Past independent flips do not force balance on the next flip."),
                MathChoice(id: "c", text: "5/6", isCorrect: false, explanation: "The streak length is not the numerator of the next-flip chance."),
                MathChoice(id: "d", text: "1/6", isCorrect: false, explanation: "There are only two equally likely coin outcomes, not six.")
            ],
            patternClue: "Ask whether the next event remembers the previous event.",
            ruleExplanation: "Independent events do not affect each other. A fair coin has a 1/2 chance of heads on every flip, even after a long streak."
        ),
        MathChallenge(
            id: "math-probability-03",
            worldId: "probability-casino",
            domain: "Conditional Probability",
            question: "A bag has 3 red gems and 2 blue gems. You draw one red gem and do not replace it. What is the chance the next gem is red?",
            context: "The vault removes each gem after it is drawn. The second draw depends on what happened first.",
            choices: [
                MathChoice(id: "a", text: "2/4", isCorrect: true, explanation: "Correct. After one red is removed, 2 red gems remain out of 4 total gems."),
                MathChoice(id: "b", text: "3/5", isCorrect: false, explanation: "That was the chance before drawing. The bag changed after the first red gem was removed."),
                MathChoice(id: "c", text: "1/5", isCorrect: false, explanation: "Only one gem was removed, and two red gems still remain."),
                MathChoice(id: "d", text: "0", isCorrect: false, explanation: "Red is still possible because the bag started with three red gems.")
            ],
            patternClue: "Update the counts after the first draw.",
            ruleExplanation: "Without replacement, probabilities change because the sample space changes. Conditional probability uses the information you already have."
        ),
        MathChallenge(
            id: "math-probability-04",
            worldId: "probability-casino",
            domain: "Risk",
            question: "Two offers have the same average payout: a guaranteed 5 chips, or a 50% chance at 10 chips and 50% chance at 0. What differs?",
            context: "Both offers average to 5 chips, but one keeps your mission stable and the other can leave you empty.",
            choices: [
                MathChoice(id: "a", text: "Risk and variance", isCorrect: true, explanation: "Correct. The average payout is the same, but the second option has more spread and more downside risk."),
                MathChoice(id: "b", text: "The guaranteed offer has no value", isCorrect: false, explanation: "A guaranteed 5 chips has an expected value of 5 and no payout variance."),
                MathChoice(id: "c", text: "The risky offer must pay 10 every other turn", isCorrect: false, explanation: "A 50% chance does not force a perfect alternating pattern."),
                MathChoice(id: "d", text: "Nothing at all differs", isCorrect: false, explanation: "Expected value is the same, but the possible outcomes and emotional/business risk are different.")
            ],
            patternClue: "Same average does not mean same ride.",
            ruleExplanation: "Variance describes spread around the average. Decisions often need both expected value and risk, especially when losses matter."
        )
    ]

    static let geometryStudioChallenges: [MathChallenge] = [
        MathChallenge(
            id: "math-geometry-01",
            worldId: "geometry-studio",
            domain: "Angles",
            question: "Two straight-line angles sit together. One is 125 degrees. What is the other angle?",
            context: "The studio door is a flat beam split by a glowing hinge. Adjacent angles on a straight line must rebuild the full 180-degree beam.",
            choices: [
                MathChoice(id: "a", text: "45 degrees", isCorrect: false, explanation: "45 plus 125 makes 170, so the straight line is still missing 10 degrees."),
                MathChoice(id: "b", text: "55 degrees", isCorrect: true, explanation: "Correct. Angles on a straight line add to 180 degrees, and 180 - 125 = 55."),
                MathChoice(id: "c", text: "65 degrees", isCorrect: false, explanation: "65 plus 125 makes 190, which bends past a straight line."),
                MathChoice(id: "d", text: "125 degrees", isCorrect: false, explanation: "Equal adjacent angles would make 250 degrees here, not a straight line.")
            ],
            patternClue: "A straight line is 180 degrees.",
            ruleExplanation: "Supplementary angles add to 180 degrees. If one angle is known, subtract it from 180 to find the other."
        ),
        MathChallenge(
            id: "math-geometry-02",
            worldId: "geometry-studio",
            domain: "Area",
            question: "A mural panel is 9 meters wide and 4 meters tall. What is its area?",
            context: "Paint drones need the exact surface before they launch. The rectangle grid counts every square meter inside the frame.",
            choices: [
                MathChoice(id: "a", text: "13 square meters", isCorrect: false, explanation: "That adds width and height. Area needs multiplication."),
                MathChoice(id: "b", text: "26 square meters", isCorrect: false, explanation: "That doubles 13, which is perimeter for this rectangle, not area."),
                MathChoice(id: "c", text: "36 square meters", isCorrect: true, explanation: "Correct. Rectangle area is width times height: 9 x 4 = 36."),
                MathChoice(id: "d", text: "81 square meters", isCorrect: false, explanation: "81 is 9 x 9. The height is 4, not 9.")
            ],
            patternClue: "Count rows of equal squares: width times height.",
            ruleExplanation: "Rectangle area measures the space inside the shape. Multiply length by width, and keep square units."
        ),
        MathChallenge(
            id: "math-geometry-03",
            worldId: "geometry-studio",
            domain: "Scale",
            question: "A model tower is built at 1:50 scale. The model is 30 cm tall. How tall is the real tower?",
            context: "The blueprint table shrinks a real structure into a manageable model. Every centimeter on the model stands for 50 centimeters in reality.",
            choices: [
                MathChoice(id: "a", text: "1.5 meters", isCorrect: false, explanation: "That divides by the scale instead of multiplying."),
                MathChoice(id: "b", text: "15 meters", isCorrect: true, explanation: "Correct. 30 cm x 50 = 1500 cm, which equals 15 meters."),
                MathChoice(id: "c", text: "30 meters", isCorrect: false, explanation: "That treats 30 cm like 30 meters and ignores the scale conversion."),
                MathChoice(id: "d", text: "50 meters", isCorrect: false, explanation: "50 is the scale factor, not the final tower height.")
            ],
            patternClue: "Multiply the model length by the scale factor, then convert units.",
            ruleExplanation: "A scale ratio keeps proportions constant. At 1:50, real lengths are 50 times the model lengths."
        ),
        MathChallenge(
            id: "math-geometry-04",
            worldId: "geometry-studio",
            domain: "Volume",
            question: "A storage cube has side length 5 cm. What is its volume?",
            context: "The studio vault stacks tiny unit cubes inside a perfect cube. The scanner needs length, width, and height together.",
            choices: [
                MathChoice(id: "a", text: "15 cubic centimeters", isCorrect: false, explanation: "That adds three side lengths. Volume needs three dimensions multiplied."),
                MathChoice(id: "b", text: "25 cubic centimeters", isCorrect: false, explanation: "25 is the area of one face, not the volume inside the cube."),
                MathChoice(id: "c", text: "75 cubic centimeters", isCorrect: false, explanation: "That multiplies the face area by 3, but the depth is 5."),
                MathChoice(id: "d", text: "125 cubic centimeters", isCorrect: true, explanation: "Correct. Cube volume is side cubed: 5 x 5 x 5 = 125.")
            ],
            patternClue: "A cube has equal length, width, and height.",
            ruleExplanation: "Volume measures three-dimensional space. For a cube, multiply side length by itself three times and use cubic units."
        )
    ]

    static let dataDetectiveChallenges: [MathChallenge] = [
        MathChallenge(
            id: "math-data-01",
            worldId: "data-detective",
            domain: "Averages",
            question: "A score list is 4, 5, 5, 6, 80. Which average best describes a typical score?",
            context: "A flashy dashboard claims the team is performing near 20 points because one extreme score distorts the mean. The case file asks for the more typical center.",
            choices: [
                MathChoice(id: "a", text: "Mean, because every report should use it", isCorrect: false, explanation: "The mean uses every value, but an extreme outlier can pull it far away from most scores."),
                MathChoice(id: "b", text: "Median, because it resists the outlier", isCorrect: true, explanation: "Correct. The median is 5, right in the middle of the sorted list, while the mean is 20."),
                MathChoice(id: "c", text: "80, because it is the biggest clue", isCorrect: false, explanation: "80 is an outlier here. It is important to explain, but it does not represent the typical score."),
                MathChoice(id: "d", text: "Range, because it gives one typical value", isCorrect: false, explanation: "Range measures spread from low to high. It does not give the center of the data.")
            ],
            patternClue: "When one value is extreme, compare mean and median before trusting the headline.",
            ruleExplanation: "The mean can be pulled by outliers. The median often gives a better typical value when data is skewed."
        ),
        MathChallenge(
            id: "math-data-02",
            worldId: "data-detective",
            domain: "Sampling",
            question: "A school survey asks only students in the chess club whether lunch should change. What is the biggest problem?",
            context: "The principal wants a decision for the whole school, but the detective board shows the sample came from one small, specialized group.",
            choices: [
                MathChoice(id: "a", text: "The sample may be biased", isCorrect: true, explanation: "Correct. Chess club students may not represent the whole school, so the result could be biased."),
                MathChoice(id: "b", text: "The survey has too many people", isCorrect: false, explanation: "The issue is not too many people. The issue is whether the people represent the population."),
                MathChoice(id: "c", text: "Surveys can never be useful", isCorrect: false, explanation: "Surveys can be useful when questions and samples are designed carefully."),
                MathChoice(id: "d", text: "Lunch opinions cannot be counted", isCorrect: false, explanation: "Opinions can be counted, but the sample needs to match the group you want to understand.")
            ],
            patternClue: "Ask who was included, who was excluded, and what population the claim is about.",
            ruleExplanation: "A sample should represent the population. Biased samples can make precise-looking numbers support the wrong decision."
        ),
        MathChallenge(
            id: "math-data-03",
            worldId: "data-detective",
            domain: "Causation",
            question: "Ice cream sales and sunburns rise together in summer. What should you conclude?",
            context: "A viral post says ice cream causes sunburn. Your evidence wall shows both numbers climb when hot sunny weather brings people outside.",
            choices: [
                MathChoice(id: "a", text: "Ice cream directly causes sunburn", isCorrect: false, explanation: "The data only shows the two rise together. It does not prove ice cream causes sunburn."),
                MathChoice(id: "b", text: "Sunburn causes people to buy ice cream", isCorrect: false, explanation: "That reverses the story without evidence. Another factor can explain both patterns."),
                MathChoice(id: "c", text: "A lurking variable may explain both", isCorrect: true, explanation: "Correct. Hot sunny weather can increase both ice cream sales and sunburn risk."),
                MathChoice(id: "d", text: "The numbers must be fake", isCorrect: false, explanation: "The numbers can be real while the causal claim is still wrong.")
            ],
            patternClue: "Correlation is a clue, not a confession. Look for a third variable.",
            ruleExplanation: "Correlation means variables move together. Causation needs stronger evidence that one variable directly changes the other."
        ),
        MathChallenge(
            id: "math-data-04",
            worldId: "data-detective",
            domain: "Rates",
            question: "A chart says downloads doubled from 50 to 100, then rose from 100 to 150. Which jump had the bigger percent increase?",
            context: "Both jumps add 50 downloads, but the magnifying lens checks growth relative to the starting value.",
            choices: [
                MathChoice(id: "a", text: "50 to 100, because it is a 100% increase", isCorrect: true, explanation: "Correct. 50 more on a base of 50 is 100%, while 50 more on a base of 100 is 50%."),
                MathChoice(id: "b", text: "100 to 150, because 150 is the largest number", isCorrect: false, explanation: "The ending value is larger, but percent increase compares the change to the starting value."),
                MathChoice(id: "c", text: "They are the same percent because both add 50", isCorrect: false, explanation: "They are the same absolute increase, not the same relative increase."),
                MathChoice(id: "d", text: "Neither jump is growth", isCorrect: false, explanation: "Both are growth. The first grows faster in percentage terms.")
            ],
            patternClue: "Percent change = change divided by the starting value.",
            ruleExplanation: "Absolute change and percent change answer different questions. Relative growth depends on the baseline."
        )
    ]

    static func challenges(for worldId: String) -> [MathChallenge] {
        switch worldId {
        case "logic-gates": return logicGateChallenges
        case "probability-casino": return probabilityCasinoChallenges
        case "geometry-studio": return geometryStudioChallenges
        case "data-detective": return dataDetectiveChallenges
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

    static let festivalRoadsChallenges: [CultureChallenge] = [
        CultureChallenge(
            id: "culture-festival-01",
            worldId: "festival-roads",
            region: "Día de Muertos · Mexico",
            question: "A family invites you to visit their ofrenda. What is the most respectful first move?",
            context: "Candles, marigolds, photos, food, and personal objects are arranged for relatives who have died. The space is colorful, but it is also intimate family memory.",
            choices: [
                CultureChoice(id: "a", text: "Ask before taking photos and listen to the story behind the altar", isCorrect: true, explanation: "Correct. Ofrendas are acts of remembrance. Asking first and listening treats the altar as a family memorial, not just decoration."),
                CultureChoice(id: "b", text: "Move objects around to make the altar look better", isCorrect: false, explanation: "The objects were placed intentionally. Rearranging them would be intrusive and disrespectful."),
                CultureChoice(id: "c", text: "Call it a Mexican Halloween party", isCorrect: false, explanation: "That flattens a distinct tradition. Día de Muertos centers remembrance, return, food, and family bonds."),
                CultureChoice(id: "d", text: "Take food from the altar without asking", isCorrect: false, explanation: "Offerings have meaning. You should wait for the host to explain what can be shared.")
            ],
            traditionClue: "Bright colors can still belong to a serious act of remembrance.",
            culturalNote: "Día de Muertos blends Indigenous and Catholic elements and focuses on welcoming the dead through memory, food, scent, and family presence."
        ),
        CultureChallenge(
            id: "culture-festival-02",
            worldId: "festival-roads",
            region: "Songkran · Thailand",
            question: "During Songkran, why should you avoid splashing monks, elders, or people who clearly opt out?",
            context: "The Thai New Year is famous for public water fights, but it also includes temple visits, family respect, and ritual water pouring for blessing and renewal.",
            choices: [
                CultureChoice(id: "a", text: "Because the festival includes respect rituals, not only street play", isCorrect: true, explanation: "Correct. Water can symbolize cleansing and blessing, but consent and respect matter, especially around elders, monks, and religious spaces."),
                CultureChoice(id: "b", text: "Because water has no cultural meaning during Songkran", isCorrect: false, explanation: "Water is central to Songkran. The issue is context: playful splashing is not appropriate everywhere or for everyone."),
                CultureChoice(id: "c", text: "Because only tourists participate in water events", isCorrect: false, explanation: "Many locals participate too. The respectful move is to read the setting and the person's consent."),
                CultureChoice(id: "d", text: "Because the festival is only held indoors", isCorrect: false, explanation: "Songkran includes public outdoor celebrations as well as family and temple practices.")
            ],
            traditionClue: "A playful ritual still has boundaries.",
            culturalNote: "Songkran marks the Thai New Year. Water rituals connect cleansing, blessing, family respect, and public celebration."
        ),
        CultureChallenge(
            id: "culture-festival-03",
            worldId: "festival-roads",
            region: "Diwali · India",
            question: "A neighbor invites you for Diwali. Which interpretation best captures the lamps, sweets, and visits?",
            context: "Homes are cleaned, lamps are lit, sweets are shared, and families may worship Lakshmi. Customs vary by region and religion across South Asia and the diaspora.",
            choices: [
                CultureChoice(id: "a", text: "Light overcoming darkness, renewal, hospitality, and shared prosperity", isCorrect: true, explanation: "Correct. Diwali is often framed around light, renewal, good fortune, family, and community, though meanings vary across traditions."),
                CultureChoice(id: "b", text: "A single identical ritual practiced the same way everywhere", isCorrect: false, explanation: "Diwali practices vary widely by region, religion, language, and family tradition."),
                CultureChoice(id: "c", text: "A private event where visitors should never bring greetings", isCorrect: false, explanation: "Visits, greetings, and sweets are common in many Diwali settings, though hosts' customs should guide you."),
                CultureChoice(id: "d", text: "Only a fireworks competition", isCorrect: false, explanation: "Fireworks can appear, but reducing Diwali to noise misses its themes of light, worship, family, and renewal.")
            ],
            traditionClue: "A lamp can be ritual, welcome, and symbol at once.",
            culturalNote: "Diwali is celebrated by Hindus, Jains, Sikhs, and others in different ways; good cultural learning notices variation instead of forcing one script."
        ),
        CultureChallenge(
            id: "culture-festival-04",
            worldId: "festival-roads",
            region: "Carnival · Brazil",
            question: "At a samba school parade in Rio, what are you actually watching besides costumes and music?",
            context: "Samba schools prepare a theme, floats, choreography, percussion, costumes, and community labor for months before entering the Sambadrome competition.",
            choices: [
                CultureChoice(id: "a", text: "A community-built performance with story, rhythm, craft, and competition", isCorrect: true, explanation: "Correct. Carnival parades are staged by organized samba schools whose performances combine neighborhood identity, artistic labor, music, and judged storytelling."),
                CultureChoice(id: "b", text: "A spontaneous parade with no planning or structure", isCorrect: false, explanation: "Samba school parades are highly planned and judged across categories such as theme, harmony, costumes, floats, and percussion."),
                CultureChoice(id: "c", text: "A tradition that exists only for foreign visitors", isCorrect: false, explanation: "Tourism is visible, but samba schools are rooted in local communities, histories, and identities."),
                CultureChoice(id: "d", text: "A ceremony where silence is the main sign of respect", isCorrect: false, explanation: "Rhythm, singing, movement, and crowd energy are central; respect means understanding the performance and community behind it.")
            ],
            traditionClue: "Follow the drumline, then look for the story it carries.",
            culturalNote: "Brazilian Carnival includes many regional forms. Rio's samba school parade is both spectacle and organized community art."
        )
    ]

    static let worldMusicStageChallenges: [CultureChallenge] = [
        CultureChallenge(
            id: "culture-music-01",
            worldId: "world-music-stage",
            region: "Griot Tradition · West Africa",
            question: "A kora player begins a praise song at a community gathering. What are you hearing beyond entertainment?",
            context: "In Mandinka and related West African traditions, griots and jeliw can preserve genealogies, histories, moral lessons, and public memory through music and spoken performance.",
            choices: [
                CultureChoice(id: "a", text: "Oral history, social memory, artistry, and public identity carried through performance", isCorrect: true, explanation: "Correct. Griot performance can combine musicianship with history, praise, counsel, and community memory."),
                CultureChoice(id: "b", text: "A random tune with no social role", isCorrect: false, explanation: "That misses the tradition's role in preserving lineages, stories, reputation, and public meaning."),
                CultureChoice(id: "c", text: "A written archive being read word for word", isCorrect: false, explanation: "The tradition is oral and performative. It can adapt to the moment while carrying inherited knowledge."),
                CultureChoice(id: "d", text: "A private hobby unrelated to community life", isCorrect: false, explanation: "Griot performance is deeply social and often connected to families, ceremonies, leadership, and memory.")
            ],
            traditionClue: "The instrument is also an archive.",
            culturalNote: "West African griot traditions show how music can store history, authority, praise, and identity without needing a written page."
        ),
        CultureChallenge(
            id: "culture-music-02",
            worldId: "world-music-stage",
            region: "Flamenco · Andalusia",
            question: "In a small flamenco venue, why does the singer's emotional delivery matter as much as fast footwork?",
            context: "Flamenco grew from Andalusian social worlds shaped by Gitano, Moorish, Jewish, and Spanish influences. Cante, guitar, palmas, and dance build tension together.",
            choices: [
                CultureChoice(id: "a", text: "Because flamenco is an expressive conversation between voice, rhythm, guitar, and body", isCorrect: true, explanation: "Correct. The singer's phrasing and emotional force guide the performance as much as dance technique."),
                CultureChoice(id: "b", text: "Because dance is forbidden in flamenco", isCorrect: false, explanation: "Dance is central in many flamenco forms, but it works with singing, guitar, and clapping rather than replacing them."),
                CultureChoice(id: "c", text: "Because all flamenco pieces have the same mood", isCorrect: false, explanation: "Flamenco has many palos, or forms, with different rhythms, moods, and settings."),
                CultureChoice(id: "d", text: "Because the guitar should always drown out the singer", isCorrect: false, explanation: "The guitar supports and answers the singer and dancer; balance and dialogue are key.")
            ],
            traditionClue: "Listen for call, answer, tension, and release.",
            culturalNote: "Flamenco is not just a tourist image of fast steps. It is a layered performance practice with rhythm cycles, vocal expression, and regional history."
        ),
        CultureChallenge(
            id: "culture-music-03",
            worldId: "world-music-stage",
            region: "Taiko · Japan",
            question: "A taiko ensemble starts with synchronized movement before the first big strike. What should you notice?",
            context: "Modern ensemble taiko combines drumming, stance, choreography, group timing, and visible physical discipline, drawing on older festival, theater, and ritual drumming contexts.",
            choices: [
                CultureChoice(id: "a", text: "The performance uses sound, posture, timing, and group energy together", isCorrect: true, explanation: "Correct. Taiko is visual and physical as well as musical; the group's coordinated movement is part of the impact."),
                CultureChoice(id: "b", text: "Only the loudest strike matters", isCorrect: false, explanation: "Volume matters, but timing, silence, choreography, stamina, and ensemble coordination shape the performance."),
                CultureChoice(id: "c", text: "The drums are props and should not be played", isCorrect: false, explanation: "The drums are the core instruments, played with technique and ensemble structure."),
                CultureChoice(id: "d", text: "Every taiko setting has exactly the same meaning", isCorrect: false, explanation: "Taiko appears in festivals, temples, theater, and modern stage groups, and meanings vary by context.")
            ],
            traditionClue: "The rhythm is also in the stance.",
            culturalNote: "Taiko learning benefits from watching the whole ensemble: sound, silence, breath, posture, and timing create the shared force."
        ),
        CultureChallenge(
            id: "culture-music-04",
            worldId: "world-music-stage",
            region: "Blues · Mississippi Delta",
            question: "A blues lyric repeats a line, then answers it with a twist. What does that structure help the song do?",
            context: "Delta blues developed in Black communities in the American South, shaped by work, migration, segregation, church sounds, field hollers, and personal storytelling.",
            choices: [
                CultureChoice(id: "a", text: "Turn lived experience into a memorable call, repeat, and response", isCorrect: true, explanation: "Correct. Repetition and variation let the singer emphasize feeling, build memory, and land a final turn of meaning."),
                CultureChoice(id: "b", text: "Prove the singer forgot the words", isCorrect: false, explanation: "The repetition is a common form, not a mistake. It creates structure and emotional weight."),
                CultureChoice(id: "c", text: "Remove all personal meaning from the song", isCorrect: false, explanation: "Blues often carries personal, social, and historical meaning through compact lyrical patterns."),
                CultureChoice(id: "d", text: "Make rhythm irrelevant", isCorrect: false, explanation: "Rhythm, phrasing, guitar patterns, and vocal timing are central to the style.")
            ],
            traditionClue: "The repeated line prepares the turn.",
            culturalNote: "The blues helped shape jazz, rock, soul, and popular music worldwide while carrying stories of pain, humor, endurance, and change."
        )
    ]

    static let architectureTrailsChallenges: [CultureChallenge] = [
        CultureChallenge(
            id: "culture-architecture-01",
            worldId: "architecture-trails",
            region: "Kyoto · Japan",
            question: "At Kiyomizu-dera, why is the wooden stage more than a scenic balcony?",
            context: "The temple's famous veranda projects from the hillside on a lattice of timber columns. Pilgrims, seasonal views, and ritual movement all shape how the site is experienced.",
            choices: [
                CultureChoice(id: "a", text: "It frames worship, landscape, movement, and craft together", isCorrect: true, explanation: "Correct. The stage is part of a sacred route and a crafted relationship with the hillside, city, and changing seasons."),
                CultureChoice(id: "b", text: "It was built only as a modern selfie platform", isCorrect: false, explanation: "The site long predates phones and tourism. Contemporary visitors use it differently, but its temple context matters."),
                CultureChoice(id: "c", text: "It proves wood cannot support large buildings", isCorrect: false, explanation: "The structure shows sophisticated timber construction and repair traditions, not weakness."),
                CultureChoice(id: "d", text: "It has no connection to the surrounding landscape", isCorrect: false, explanation: "The view, hillside, approach, and seasonal setting are central to the experience.")
            ],
            traditionClue: "A platform can turn looking, walking, worship, and craft into one scene.",
            culturalNote: "Kiyomizu-dera shows how Japanese temple architecture can bind timber technique, pilgrimage, landscape, and seasonal perception rather than treating a building as an isolated object."
        ),
        CultureChallenge(
            id: "culture-architecture-02",
            worldId: "architecture-trails",
            region: "Córdoba · Spain",
            question: "Inside the Mosque-Cathedral of Córdoba, what should a careful learner notice first?",
            context: "Rows of striped arches, a mihrab, later Christian chapels, and a cathedral nave occupy the same complex. The building carries layers from Islamic al-Andalus and later Christian rule.",
            choices: [
                CultureChoice(id: "a", text: "Different periods and faith traditions are layered in one building", isCorrect: true, explanation: "Correct. The site is best read as layered history: Umayyad mosque architecture, Christian reuse, additions, and contested memory."),
                CultureChoice(id: "b", text: "The building was created in a single unchanged moment", isCorrect: false, explanation: "Its form changed across centuries through expansion, conversion, and additions."),
                CultureChoice(id: "c", text: "The arches are random decoration with no spatial role", isCorrect: false, explanation: "The repeated arches shape rhythm, scale, direction, and the experience of the prayer hall."),
                CultureChoice(id: "d", text: "Only one community's memory exists there", isCorrect: false, explanation: "The building is culturally powerful precisely because multiple histories remain visible and debated.")
            ],
            traditionClue: "Read the arches like a timeline, not wallpaper.",
            culturalNote: "The Mosque-Cathedral of Córdoba is a major example of layered Mediterranean history, where architecture preserves beauty, power, religious change, and contested interpretation in the same space."
        ),
        CultureChallenge(
            id: "culture-architecture-03",
            worldId: "architecture-trails",
            region: "Mali · Djenné",
            question: "Why does the Great Mosque of Djenné require community maintenance instead of a one-time repair?",
            context: "The mosque is built in an earthen Sudano-Sahelian style. Rain and heat weather the surface, and local maintenance traditions renew the building's protective plaster.",
            choices: [
                CultureChoice(id: "a", text: "Earthen architecture needs regular replastering and shared care", isCorrect: true, explanation: "Correct. The building's material life includes periodic maintenance, craft knowledge, and community participation."),
                CultureChoice(id: "b", text: "Mud-brick buildings never need upkeep", isCorrect: false, explanation: "Earthen buildings can be durable, but they depend on maintenance and climate-aware design."),
                CultureChoice(id: "c", text: "The mosque is rebuilt every week from nothing", isCorrect: false, explanation: "The structure is maintained and renewed, not casually recreated from scratch every week."),
                CultureChoice(id: "d", text: "Only imported steel explains its value", isCorrect: false, explanation: "Its significance comes from local materials, craft, urban form, religious life, and community practice.")
            ],
            traditionClue: "Conservation can be a festival of maintenance, not a sealed museum case.",
            culturalNote: "Djenné's mosque teaches that architecture can be a living social process: material, climate, craft, faith, and collective maintenance all keep the place meaningful."
        ),
        CultureChallenge(
            id: "culture-architecture-04",
            worldId: "architecture-trails",
            region: "Mexico · Teotihuacan",
            question: "Walking the Avenue of the Dead, what makes Teotihuacan a cultural map rather than only a pile of ruins?",
            context: "The city was carefully planned with pyramids, plazas, apartment compounds, murals, and long axial routes. Its builders predated the Mexica, and its influence spread across Mesoamerica.",
            choices: [
                CultureChoice(id: "a", text: "Urban layout, ritual routes, housing, and power were organized together", isCorrect: true, explanation: "Correct. Teotihuacan's plan links monumental architecture with everyday residence, ritual movement, craft production, and political authority."),
                CultureChoice(id: "b", text: "It was built by the Aztec Empire as its capital", isCorrect: false, explanation: "Teotihuacan flourished centuries before the Mexica/Aztec Empire; later peoples encountered it as an ancient sacred place."),
                CultureChoice(id: "c", text: "Only the tallest pyramid matters", isCorrect: false, explanation: "The pyramids are important, but the avenue, compounds, murals, and city planning reveal the broader urban system."),
                CultureChoice(id: "d", text: "Its streets were placed randomly with no pattern", isCorrect: false, explanation: "The city's strong grid and monumental axis are among its most recognizable features.")
            ],
            traditionClue: "Zoom out from monument to city plan.",
            culturalNote: "Teotihuacan shows how ancient urban design can encode movement, ritual, residence, labor, and authority long after the city's original language and rulers remain uncertain."
        )
    ]

    static func challenges(for worldId: String) -> [CultureChallenge] {
        switch worldId {
        case "heritage-kitchens": return heritageKitchenChallenges
        case "festival-roads": return festivalRoadsChallenges
        case "world-music-stage": return worldMusicStageChallenges
        case "architecture-trails": return architectureTrailsChallenges
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

    static let wallStreetDeskChallenges: [BusinessChallenge] = [
        BusinessChallenge(
            id: "business-wallstreet-01",
            worldId: "wall-street-desk",
            domain: "Diversification",
            question: "A trader wants to put the whole portfolio into one hot stock after a viral earnings clip. What is the sharper move?",
            context: "The stock may keep rising, but the desk has limited capital and one bad headline could wipe out months of progress.",
            choices: [
                BusinessChoice(id: "a", text: "Size the position and keep exposure diversified", isCorrect: true, explanation: "Correct. Position sizing and diversification reduce single-company risk while still allowing upside."),
                BusinessChoice(id: "b", text: "Go all-in because the clip sounds confident", isCorrect: false, explanation: "Confidence is not a risk control. One concentrated bet can dominate the whole outcome."),
                BusinessChoice(id: "c", text: "Ignore all financial statements and follow comments", isCorrect: false, explanation: "Comments can reveal sentiment, but they are weak evidence without fundamentals, valuation, and risk context."),
                BusinessChoice(id: "d", text: "Short every competitor immediately", isCorrect: false, explanation: "A strong company does not automatically make every competitor a good short.")
            ],
            marketSignal: "High excitement, single-name concentration risk, limited capital.",
            lesson: "Diversification is not about avoiding conviction. It is about surviving uncertainty when any one thesis can be wrong."
        ),
        BusinessChallenge(
            id: "business-wallstreet-02",
            worldId: "wall-street-desk",
            domain: "Liquidity",
            question: "A fund owns a thinly traded asset that looks cheap on paper. What hidden risk matters most?",
            context: "The screen price looks attractive, but only a small number of buyers trade the asset each day.",
            choices: [
                BusinessChoice(id: "a", text: "You may not be able to exit near the quoted price", isCorrect: true, explanation: "Correct. Low liquidity can turn a paper gain into a bad exit when size meets a shallow market."),
                BusinessChoice(id: "b", text: "Liquidity means the asset is guaranteed to rise", isCorrect: false, explanation: "Liquidity describes how easily something trades, not whether its price will rise."),
                BusinessChoice(id: "c", text: "The quote removes all risk", isCorrect: false, explanation: "A quote is not a promise that a large order can trade there."),
                BusinessChoice(id: "d", text: "Thin markets always have zero value", isCorrect: false, explanation: "Illiquid assets can be valuable, but they need a margin of safety and exit plan.")
            ],
            marketSignal: "Cheap valuation, shallow order book, uncertain exit path.",
            lesson: "Liquidity is part of risk. The price you see is less useful if you cannot actually trade meaningful size at that price."
        ),
        BusinessChallenge(
            id: "business-wallstreet-03",
            worldId: "wall-street-desk",
            domain: "Incentives",
            question: "A broker pushes a complex product with a large upfront commission. What should the investor ask first?",
            context: "The brochure promises protection and upside, but the fee structure is hard to read and the salesperson is rushing the decision.",
            choices: [
                BusinessChoice(id: "a", text: "How is the seller paid, and what fees reduce my return?", isCorrect: true, explanation: "Correct. Incentives and fees can explain why a product is being pushed and how much return leaks away."),
                BusinessChoice(id: "b", text: "Can I sign before reading the documents?", isCorrect: false, explanation: "Complexity plus urgency is a warning sign. Slow down before committing capital."),
                BusinessChoice(id: "c", text: "Does the product have the longest name?", isCorrect: false, explanation: "A sophisticated name says little about suitability or cost."),
                BusinessChoice(id: "d", text: "Can the broker promise no losses forever?", isCorrect: false, explanation: "Guaranteed language needs careful scrutiny. Risks often move into fees, lockups, credit exposure, or capped upside.")
            ],
            marketSignal: "Complex payoff, rushed sale, high commission.",
            lesson: "In finance, incentives shape behavior. Before trusting advice, understand who gets paid, when, and from which pocket."
        ),
        BusinessChallenge(
            id: "business-wallstreet-04",
            worldId: "wall-street-desk",
            domain: "Risk Management",
            question: "Your trade thesis is still possible, but new evidence weakens it. What should a disciplined desk do?",
            context: "The original plan had a stop level and a reason to exit. Now the market is moving against you and the news contradicts your base case.",
            choices: [
                BusinessChoice(id: "a", text: "Recheck the thesis, reduce or exit if the reason for the trade broke", isCorrect: true, explanation: "Correct. A trade is not a loyalty test. When the evidence changes, risk should change too."),
                BusinessChoice(id: "b", text: "Double the position to avoid admitting a mistake", isCorrect: false, explanation: "Averaging down without a valid thesis can turn a manageable loss into a portfolio problem."),
                BusinessChoice(id: "c", text: "Delete the plan so the loss feels temporary", isCorrect: false, explanation: "Removing the plan removes discipline, not risk."),
                BusinessChoice(id: "d", text: "Only look at opinions that agree with you", isCorrect: false, explanation: "Confirmation bias makes bad decisions feel comfortable while the risk keeps growing.")
            ],
            marketSignal: "Thesis weakening, adverse move, prewritten exit rules.",
            lesson: "Risk management turns learning into action. The question is not whether you were wrong, but how fast you update when facts change."
        )
    ]

    static let negotiationRoomChallenges: [BusinessChallenge] = [
        BusinessChallenge(
            id: "business-negotiation-01",
            worldId: "negotiation-room",
            domain: "Preparation",
            question: "You enter a salary negotiation tomorrow. What should you prepare before discussing numbers?",
            context: "The role is attractive, but the first offer may anchor the conversation. You have market salary data, personal priorities, and one alternative interview still active.",
            choices: [
                BusinessChoice(id: "a", text: "Define your target, walk-away point, and strongest alternatives", isCorrect: true, explanation: "Correct. Preparation gives you a target, protects against bad pressure, and makes tradeoffs clearer."),
                BusinessChoice(id: "b", text: "Decide to accept whatever sounds friendly", isCorrect: false, explanation: "Friendliness is useful, but it does not replace a target range or a walk-away point."),
                BusinessChoice(id: "c", text: "Avoid all research so you sound flexible", isCorrect: false, explanation: "Flexibility without information often turns into weak bargaining."),
                BusinessChoice(id: "d", text: "Open with a threat before hearing the offer", isCorrect: false, explanation: "Threats can damage trust and may reveal insecurity instead of leverage.")
            ],
            marketSignal: "High stakes, asymmetric information, real alternative still alive.",
            lesson: "A strong negotiation starts before the meeting. Know your target, your BATNA, your walk-away line, and what non-salary terms matter."
        ),
        BusinessChallenge(
            id: "business-negotiation-02",
            worldId: "negotiation-room",
            domain: "Anchoring",
            question: "A vendor opens with a price far above budget. What is the best response?",
            context: "The vendor's product is useful, but the quote includes services you may not need. Your team can buy from another provider, though switching costs are real.",
            choices: [
                BusinessChoice(id: "a", text: "Separate the package, share constraints, and counter with a reasoned range", isCorrect: true, explanation: "Correct. You reset the anchor with facts, scope, and a credible counter instead of reacting emotionally."),
                BusinessChoice(id: "b", text: "Accept immediately because the first number must be fair", isCorrect: false, explanation: "Opening numbers can be strategic anchors, not final truth."),
                BusinessChoice(id: "c", text: "Insult the vendor to force a discount", isCorrect: false, explanation: "Attacking the person can reduce cooperation and make creative terms harder."),
                BusinessChoice(id: "d", text: "Hide your budget and refuse to discuss scope", isCorrect: false, explanation: "Some information should be protected, but useful scope and constraint details can create a better deal.")
            ],
            marketSignal: "High anchor, optional scope, credible alternative supplier.",
            lesson: "Anchors shape expectations. Counter with logic: comparable prices, must-have scope, budget constraints, timing, and alternatives."
        ),
        BusinessChallenge(
            id: "business-negotiation-03",
            worldId: "negotiation-room",
            domain: "Tradeoffs",
            question: "Both sides are stuck on price, but delivery speed matters more to you than a small discount. What move creates value?",
            context: "The supplier cannot cut much further without hurting margin. You need the launch date protected and can offer a longer contract if service levels improve.",
            choices: [
                BusinessChoice(id: "a", text: "Trade a longer commitment for faster delivery and clear service levels", isCorrect: true, explanation: "Correct. You move from one-issue bargaining to a package where each side gets something valuable."),
                BusinessChoice(id: "b", text: "Keep repeating the same price demand", isCorrect: false, explanation: "If the issue is stuck, repeating it may waste value hidden in other terms."),
                BusinessChoice(id: "c", text: "Pretend delivery speed does not matter", isCorrect: false, explanation: "Hiding a real priority can lead to a deal that looks cheap but fails the mission."),
                BusinessChoice(id: "d", text: "Drop all requirements to end the meeting faster", isCorrect: false, explanation: "Speed is useful only if the final agreement still protects the important outcome.")
            ],
            marketSignal: "Price deadlock, launch deadline, room for package terms.",
            lesson: "Good negotiators search for differences in priorities. Delivery, scope, risk, payment timing, support, and duration can unlock better packages."
        ),
        BusinessChallenge(
            id: "business-negotiation-04",
            worldId: "negotiation-room",
            domain: "Trust",
            question: "After agreement, the other side asks to leave one promise informal. What should you do?",
            context: "Everyone seems aligned, but the promise affects renewal pricing and support response times. Memories may differ once pressure returns.",
            choices: [
                BusinessChoice(id: "a", text: "Document the promise clearly before signing", isCorrect: true, explanation: "Correct. Clear written terms protect both sides and reduce future conflict."),
                BusinessChoice(id: "b", text: "Rely only on memory because trust means no paperwork", isCorrect: false, explanation: "Documentation does not destroy trust. It often protects it by making expectations explicit."),
                BusinessChoice(id: "c", text: "Add hidden terms the other side has not seen", isCorrect: false, explanation: "Surprise terms damage trust and may create legal or relationship risk."),
                BusinessChoice(id: "d", text: "Ignore the promise because support never matters", isCorrect: false, explanation: "Support and renewal terms can decide whether the deal works after the sale.")
            ],
            marketSignal: "Important promise, future pressure, risk of mismatched expectations.",
            lesson: "Trust and clarity work together. Written agreements turn shared intent into something both sides can inspect, remember, and honor."
        )
    ]

    static let personalFinanceLabChallenges: [BusinessChallenge] = [
        BusinessChallenge(
            id: "business-finance-01",
            worldId: "personal-finance-lab",
            domain: "Budgeting",
            question: "Your income arrives, bills are due, and a sale is tempting. What is the strongest first move?",
            context: "The lab console shows rent, groceries, transport, a minimum debt payment, and a fun purchase that would drain the account before the next paycheck.",
            choices: [
                BusinessChoice(id: "a", text: "Cover essentials, automate savings, then decide on wants", isCorrect: true, explanation: "Correct. A useful budget protects necessities and future stability before optional spending."),
                BusinessChoice(id: "b", text: "Buy the sale item first because discounts create money", isCorrect: false, explanation: "A discount still costs cash. It is only useful if it fits after priorities are covered."),
                BusinessChoice(id: "c", text: "Ignore all bills until the account feels less stressful", isCorrect: false, explanation: "Avoidance can create late fees, interest, and bigger stress later."),
                BusinessChoice(id: "d", text: "Spend based only on yesterday's balance", isCorrect: false, explanation: "A balance snapshot can hide upcoming bills. Cash flow timing matters.")
            ],
            marketSignal: "Fixed bills, variable wants, limited cash until next payday.",
            lesson: "Budgeting is a priority system, not a punishment. Essentials, minimum obligations, savings, and flexible wants need a clear order."
        ),
        BusinessChallenge(
            id: "business-finance-02",
            worldId: "personal-finance-lab",
            domain: "Emergency Fund",
            question: "Your phone breaks the same month a medical copay appears. What financial defense helps most?",
            context: "The expense is real, urgent, and not huge enough for a long-term loan. Without cash set aside, it would likely land on high-interest credit.",
            choices: [
                BusinessChoice(id: "a", text: "Use a small emergency fund and rebuild it afterward", isCorrect: true, explanation: "Correct. Emergency savings are designed to absorb irregular necessary costs without turning them into expensive debt."),
                BusinessChoice(id: "b", text: "Skip rent to keep the savings untouched", isCorrect: false, explanation: "Emergency funds are there to protect core obligations, not to sit unused while essentials fail."),
                BusinessChoice(id: "c", text: "Take the highest-interest option because it is fastest", isCorrect: false, explanation: "Speed matters, but high-interest debt can turn a small emergency into a long problem."),
                BusinessChoice(id: "d", text: "Pretend emergencies are too rare to plan for", isCorrect: false, explanation: "Irregular expenses are normal. Planning for them makes them less disruptive.")
            ],
            marketSignal: "Necessary surprise expense, no time to earn extra first, high-interest credit available.",
            lesson: "An emergency fund buys options. Even a modest buffer can prevent fees, panic borrowing, and missed essential payments."
        ),
        BusinessChallenge(
            id: "business-finance-03",
            worldId: "personal-finance-lab",
            domain: "Debt Strategy",
            question: "Two debts compete for attention: one has 24% interest and one has 4%. What should usually get extra payments first?",
            context: "Minimum payments are covered on both. Extra cash can reduce only one balance this month.",
            choices: [
                BusinessChoice(id: "a", text: "The 24% debt, because it grows fastest", isCorrect: true, explanation: "Correct. Paying extra toward the highest-interest debt usually saves the most money."),
                BusinessChoice(id: "b", text: "The 4% debt, because lower numbers are easier to ignore", isCorrect: false, explanation: "A low rate may be less urgent when minimums are covered and a high-rate balance is compounding."),
                BusinessChoice(id: "c", text: "Neither debt, because minimums make interest disappear", isCorrect: false, explanation: "Minimum payments prevent delinquency, but interest can still accumulate for a long time."),
                BusinessChoice(id: "d", text: "Pick randomly so the debts feel treated equally", isCorrect: false, explanation: "Equal attention is not the same as smart cost reduction.")
            ],
            marketSignal: "Both minimums paid, limited extra cash, large interest-rate gap.",
            lesson: "Debt strategy starts with the interest rate and required payments. The avalanche method targets high-rate balances to reduce total cost."
        ),
        BusinessChallenge(
            id: "business-finance-04",
            worldId: "personal-finance-lab",
            domain: "Long-Term Investing",
            question: "A friend says to invest everything in one trending coin because it doubled last week. What is the more durable move?",
            context: "The money is for a goal years away. The trend may continue, but the outcome depends on hype, volatility, and timing you cannot control.",
            choices: [
                BusinessChoice(id: "a", text: "Use diversified, low-cost investing sized to your time horizon", isCorrect: true, explanation: "Correct. Long-term investing usually favors diversification, costs, risk tolerance, and time horizon over chasing one recent winner."),
                BusinessChoice(id: "b", text: "Move every euro into the trend before learning the risk", isCorrect: false, explanation: "Recent performance does not remove concentration risk or volatility."),
                BusinessChoice(id: "c", text: "Borrow money to make the bet bigger", isCorrect: false, explanation: "Leverage can magnify losses and force bad exits."),
                BusinessChoice(id: "d", text: "Assume all investing is identical to gambling", isCorrect: false, explanation: "Speculation exists, but diversified investing with a long horizon and sensible costs is a different decision process.")
            ],
            marketSignal: "High hype, concentrated asset, long-term goal, uncertain timing.",
            lesson: "Investing is matching risk to goals. Diversification, low fees, time horizon, and position size help protect the plan from one loud story."
        )
    ]

    static func challenges(for worldId: String) -> [BusinessChallenge] {
        switch worldId {
        case "founder-guild": return founderGuildChallenges
        case "wall-street-desk": return wallStreetDeskChallenges
        case "negotiation-room": return negotiationRoomChallenges
        case "personal-finance-lab": return personalFinanceLabChallenges
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

    static let resilienceGymChallenges: [HealthChallenge] = [
        HealthChallenge(
            id: "health-resilience-01",
            worldId: "resilience-gym",
            domain: "Recovery",
            question: "You wake up after a short night and have a demanding day. What is the strongest recovery plan?",
            context: "You cannot erase the bad night. The goal is to protect energy without creating another late-night crash.",
            choices: [
                HealthChoice(id: "a", text: "Get morning light, keep caffeine early, and plan a slightly easier evening", isCorrect: true, explanation: "Correct. Light helps anchor the body clock, early caffeine limits sleep disruption, and a lighter evening protects recovery."),
                HealthChoice(id: "b", text: "Drink caffeine all afternoon to force normal output", isCorrect: false, explanation: "That can postpone tiredness and make the next sleep window harder."),
                HealthChoice(id: "c", text: "Cancel every useful habit because the day is ruined", isCorrect: false, explanation: "A rough day still benefits from small anchors like meals, movement, and a realistic bedtime."),
                HealthChoice(id: "d", text: "Take a late long nap and start serious work at midnight", isCorrect: false, explanation: "Long late naps can reduce sleep pressure and shift the problem into the next day.")
            ],
            bodySignal: "Sleep debt, heavy eyes, fragile focus, high temptation for late caffeine.",
            habitLesson: "Resilience is often a recovery adjustment, not heroic output. Morning light, early caffeine limits, lighter plans, and consistent sleep cues help the next night recover."
        ),
        HealthChallenge(
            id: "health-resilience-02",
            worldId: "resilience-gym",
            domain: "Focus",
            question: "Your attention keeps jumping between tabs. What move makes the next 25 minutes most likely to work?",
            context: "The task is important but fuzzy. You feel busy without moving the outcome forward.",
            choices: [
                HealthChoice(id: "a", text: "Write one tiny finish line, close extra tabs, and start a timed focus block", isCorrect: true, explanation: "Correct. A visible finish line plus fewer cues gives attention a smaller target to defend."),
                HealthChoice(id: "b", text: "Keep every tab open so you do not miss anything", isCorrect: false, explanation: "More open loops compete for attention and make the important task harder to start."),
                HealthChoice(id: "c", text: "Wait until motivation appears naturally", isCorrect: false, explanation: "Motivation often follows a clear first action, not the other way around."),
                HealthChoice(id: "d", text: "Switch tasks whenever the current one feels uncomfortable", isCorrect: false, explanation: "That trains escape from friction instead of building focus tolerance.")
            ],
            bodySignal: "Restless hands, scattered tabs, vague task, no clear finish line.",
            habitLesson: "Focus improves when the environment has fewer cues and the next action is concrete. Timed blocks work best with a small finish line, not a vague intention."
        ),
        HealthChallenge(
            id: "health-resilience-03",
            worldId: "resilience-gym",
            domain: "Emotion Regulation",
            question: "A criticism lands hard and you want to fire back immediately. What response protects the relationship and your judgment?",
            context: "Your body is already mobilized. The message may be unfair, but reacting at peak arousal usually narrows thinking.",
            choices: [
                HealthChoice(id: "a", text: "Pause, name the feeling, draft a reply, and send only after rereading", isCorrect: true, explanation: "Correct. Naming the feeling and delaying the send creates space for a response instead of a reflex."),
                HealthChoice(id: "b", text: "Reply instantly with the sharpest comeback", isCorrect: false, explanation: "A quick comeback can feel satisfying while making the real problem harder to solve."),
                HealthChoice(id: "c", text: "Pretend you feel nothing and ignore the issue forever", isCorrect: false, explanation: "Suppression can delay the reaction, but it does not resolve the need for a clear response."),
                HealthChoice(id: "d", text: "Read the message repeatedly until you are more angry", isCorrect: false, explanation: "Replaying the trigger usually increases arousal and reduces perspective.")
            ],
            bodySignal: "Tense chest, urge to reply, narrow attention, defensive thoughts.",
            habitLesson: "Emotion regulation is not pretending. It means noticing arousal, creating a delay, and choosing a response that still fits your values after the intensity drops."
        ),
        HealthChallenge(
            id: "health-resilience-04",
            worldId: "resilience-gym",
            domain: "Sustainable Progress",
            question: "You miss a habit two days in a row. What is the best way to restart without turning it into a shame spiral?",
            context: "The original plan was too large for a busy week. You still care about the habit, but the streak is gone.",
            choices: [
                HealthChoice(id: "a", text: "Shrink the habit to a two-minute version and restart today", isCorrect: true, explanation: "Correct. A small restart keeps identity and momentum alive while you rebuild capacity."),
                HealthChoice(id: "b", text: "Double the habit tomorrow as punishment", isCorrect: false, explanation: "Punishment makes the habit heavier and can increase avoidance."),
                HealthChoice(id: "c", text: "Quit because one missed streak proves failure", isCorrect: false, explanation: "Misses are data. The plan needs resizing, not a verdict on you."),
                HealthChoice(id: "d", text: "Wait for a perfect Monday with no stress", isCorrect: false, explanation: "Real habits need imperfect restarts. Waiting for perfect conditions delays learning.")
            ],
            bodySignal: "Avoidance, guilt, all-or-nothing thinking, plan too large for the week.",
            habitLesson: "A resilient habit has a restart protocol. Shrink the action, do it today, and use the miss as information about friction and capacity."
        )
    ]

    static let nutritionLabChallenges: [HealthChallenge] = [
        HealthChallenge(
            id: "health-nutrition-01",
            worldId: "nutrition-lab",
            domain: "Balanced Plate",
            question: "You have five minutes before a long work block. Which plate is most likely to keep energy steady?",
            context: "The goal is not a perfect diet. You need a realistic meal that gives fuel, protein, and fiber without a fast crash.",
            choices: [
                HealthChoice(id: "a", text: "Whole-grain wrap with eggs or tofu, vegetables, and water", isCorrect: true, explanation: "Correct. Carbohydrate, protein, fiber, and fluid together support steadier energy than a single fast fuel."),
                HealthChoice(id: "b", text: "Only a sweet pastry and no drink", isCorrect: false, explanation: "A pastry can be enjoyable, but alone it is less likely to keep energy stable through a long block."),
                HealthChoice(id: "c", text: "Skip the meal because productivity matters more", isCorrect: false, explanation: "Skipping food may backfire when attention and mood need fuel."),
                HealthChoice(id: "d", text: "Drink only an energy drink and call it breakfast", isCorrect: false, explanation: "Caffeine can mask tiredness, but it does not replace nutrients, fluid, or a balanced meal.")
            ],
            bodySignal: "Empty stomach, upcoming focus demand, low time, crash risk.",
            habitLesson: "A useful default plate pairs a carbohydrate source with protein, fiber-rich plants, and fluid. It does not need to be perfect to be effective."
        ),
        HealthChallenge(
            id: "health-nutrition-02",
            worldId: "nutrition-lab",
            domain: "Hydration",
            question: "You notice a mild headache after coffee and two hours of deep work. What is the best first reset?",
            context: "You are not diagnosing a medical problem. You are choosing the low-risk next step before continuing.",
            choices: [
                HealthChoice(id: "a", text: "Drink water, eat a small balanced snack if hungry, and reassess", isCorrect: true, explanation: "Correct. Fluid and a small snack are practical first checks when focus, caffeine, and hunger may be involved."),
                HealthChoice(id: "b", text: "Add another strong coffee immediately", isCorrect: false, explanation: "More caffeine can worsen jitters and does not address possible dehydration or hunger."),
                HealthChoice(id: "c", text: "Ignore thirst until the task is finished", isCorrect: false, explanation: "Ignoring basic signals can make the next block harder than it needs to be."),
                HealthChoice(id: "d", text: "Chug several liters of water at once", isCorrect: false, explanation: "More is not always better. Moderate drinking and reassessing is safer than overcorrecting.")
            ],
            bodySignal: "Mild headache, coffee, long focus block, possible thirst.",
            habitLesson: "Hydration works best as a steady habit: drink enough across the day, pair caffeine with water, and use thirst or dark urine as simple feedback signals."
        ),
        HealthChallenge(
            id: "health-nutrition-03",
            worldId: "nutrition-lab",
            domain: "Protein and Fiber",
            question: "Dinner is late and you want something quick. Which choice best supports fullness and recovery?",
            context: "You want a meal that is easy but still useful after a demanding day.",
            choices: [
                HealthChoice(id: "a", text: "Beans or lentils with rice, vegetables, olive oil, and yogurt or fruit", isCorrect: true, explanation: "Correct. Protein, fiber, carbohydrate, and fat create a more complete recovery meal."),
                HealthChoice(id: "b", text: "Plain chips as the entire dinner", isCorrect: false, explanation: "Chips can add salt and calories but miss protein, fiber, and micronutrient variety."),
                HealthChoice(id: "c", text: "Only a protein shake forever", isCorrect: false, explanation: "Protein can help, but relying only on shakes misses the benefits of whole foods and fiber."),
                HealthChoice(id: "d", text: "Avoid all carbohydrates at night by default", isCorrect: false, explanation: "Carbohydrates are not automatically bad at night; context and total pattern matter more.")
            ],
            bodySignal: "Late hunger, tired body, low cooking energy, recovery need.",
            habitLesson: "Protein helps repair and fullness; fiber supports digestion and steadier glucose. Combining both with practical staple foods is more durable than strict rules."
        ),
        HealthChallenge(
            id: "health-nutrition-04",
            worldId: "nutrition-lab",
            domain: "Label Reading",
            question: "Two snacks look healthy on the front label. What should you check before choosing?",
            context: "Packaging is persuasive. Your mission is to find the useful signal without obsessing over every number.",
            choices: [
                HealthChoice(id: "a", text: "Serving size, added sugar, fiber, protein, and ingredients you recognize", isCorrect: true, explanation: "Correct. These checks reveal whether the snack fits your actual need better than front-label claims."),
                HealthChoice(id: "b", text: "Only the biggest health claim on the package", isCorrect: false, explanation: "Front-label claims can be selective and do not show the full nutrition pattern."),
                HealthChoice(id: "c", text: "Assume expensive always means healthier", isCorrect: false, explanation: "Price is not a reliable nutrition signal."),
                HealthChoice(id: "d", text: "Ignore serving size because calories are all that matters", isCorrect: false, explanation: "Serving size changes how the numbers apply, and nutrition is broader than calories alone.")
            ],
            bodySignal: "Snack choice, persuasive packaging, unclear real portion.",
            habitLesson: "Good label reading is quick and practical: check serving size, added sugar, fiber, protein, and ingredients, then choose what fits the moment."
        )
    ]

    static func challenges(for worldId: String) -> [HealthChallenge] {
        switch worldId {
        case "energy-clinic": return energyClinicChallenges
        case "resilience-gym": return resilienceGymChallenges
        case "nutrition-lab": return nutritionLabChallenges
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

struct DailyRewardTrackDay: Identifiable, Equatable {
    let day: Int
    let subject: Subject
    let rewardXP: Int
    let rewardGems: Int
    let isCurrent: Bool
    let isCollected: Bool
    let isLocked: Bool

    var id: String { "day-\(day)" }
    var title: String { "Day \(day)" }
    var rewardText: String { "+\(rewardXP) XP · +\(rewardGems) gem\(rewardGems == 1 ? "" : "s")" }
    var statusText: String {
        if isCollected { return "Collected" }
        if isCurrent { return "Today" }
        return isLocked ? "Locked" : "Ready"
    }
    var systemImage: String {
        if isCollected { return "checkmark.seal.fill" }
        if isCurrent { return "gift.fill" }
        return isLocked ? "lock.fill" : "sparkles"
    }
    var accessibilityLabel: String {
        "\(title). \(statusText). Reward \(rewardText)."
    }
}

struct DailyRewardTrack: Equatable {
    let subject: Subject
    let streak: Int
    let reviewedToday: Int
    let isClaimedToday: Bool

    var cycleLength: Int { 7 }
    var currentDay: Int {
        let normalized = max(1, streak)
        return ((normalized - 1) % cycleLength) + 1
    }
    var isReady: Bool { reviewedToday > 0 && !isClaimedToday }
    var progress: Double { Double(currentDay) / Double(cycleLength) }
    var title: String { "Reward Calendar" }
    var subtitle: String {
        if isClaimedToday { return "Today is banked. Tomorrow advances the prize lane." }
        if reviewedToday > 0 { return "Claim today's \(subject.displayName) login prize." }
        return "Finish one encounter to light up today's reward."
    }
    var rewardXP: Int { 8 + currentDay * 2 }
    var rewardGems: Int { currentDay == cycleLength ? 4 : (currentDay >= 4 ? 2 : 1) }
    var rewardText: String { "+\(rewardXP) XP · +\(rewardGems) gem\(rewardGems == 1 ? "" : "s")" }
    var progressText: String { "Day \(currentDay)/\(cycleLength)" }
    var ctaTitle: String {
        if isClaimedToday { return "Collected" }
        return isReady ? "Claim Reward" : "Study First"
    }
    var days: [DailyRewardTrackDay] {
        (1...cycleLength).map { day in
            DailyRewardTrackDay(
                day: day,
                subject: subject,
                rewardXP: 8 + day * 2,
                rewardGems: day == cycleLength ? 4 : (day >= 4 ? 2 : 1),
                isCurrent: day == currentDay,
                isCollected: day < currentDay || (day == currentDay && isClaimedToday),
                isLocked: day > currentDay
            )
        }
    }
    var accessibilityLabel: String {
        "\(title). \(subtitle). \(progressText). Reward \(rewardText)."
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

struct WorldBriefing: Equatable {
    let subject: Subject
    let world: PlayableWorld?
    let title: String
    let subtitle: String
    let scene: String
    let stakes: String
    let skill: String
    let fact: String
    let rewardText: String
    let progress: Double
    let progressText: String
    let ctaTitle: String
    let systemImage: String

    var iconText: String {
        world?.emoji ?? "💧"
    }

    var accessibilityLabel: String {
        "\(title). \(subtitle). \(scene). Stakes: \(stakes). Skill: \(skill). Fact: \(fact). \(progressText). Reward \(rewardText)."
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

enum PlayMenuModeKind: String, Equatable {
    case sprint
    case expedition
    case boss
}

struct PlayMenuMode: Identifiable, Equatable {
    let id: String
    let kind: PlayMenuModeKind
    let title: String
    let subtitle: String
    let reward: String
    let ctaTitle: String
    let systemImage: String
    let subject: Subject
    let worldId: String?
    let progress: Double
    let tint: Subject

    var progressText: String {
        "\(Int((min(1, max(0, progress)) * 100).rounded()))%"
    }

    var accessibilityLabel: String {
        "\(title). \(subtitle). Reward \(reward). Progress \(progressText). \(ctaTitle)."
    }
}

struct PlayMenu: Equatable {
    let modes: [PlayMenuMode]

    var title: String { "Choose Your Run" }
    var subtitle: String { "Pick a fast XP burst, continue the world story, or charge a reward boss." }
    var accessibilityLabel: String {
        "\(title). \(subtitle). \(modes.count) playable modes."
    }
}

struct QuestEnergy: Equatable {
    let subject: Subject
    let xp: Int
    let gems: Int
    let streak: Int
    let reviewedToday: Int
    let correctToday: Int
    let nextUnlock: WorldRewardBadge?

    var title: String { "Quest Energy" }
    var energy: Int {
        let activity = reviewedToday * 8
        let accuracy = correctToday * 10
        let streakCharge = min(24, streak * 4)
        let gemCharge = min(18, gems * 3)
        let levelCharge = xp % 100
        return min(100, max(0, activity + accuracy + streakCharge + gemCharge + levelCharge / 2))
    }
    var progress: Double { Double(energy) / 100.0 }
    var progressText: String { "\(energy)% charged" }
    var gateText: String {
        guard let nextUnlock else { return "All current world gates are open." }
        return "\(nextUnlock.xpRemaining) XP to \(nextUnlock.world.name)"
    }
    var spendCost: Int { 3 }
    var boostXP: Int { 20 + min(10, max(0, streak * 2)) }
    var canSpend: Bool { gems >= spendCost }
    var ctaTitle: String { canSpend ? "Boost Gate" : "\(max(0, spendCost - gems)) gems short" }
    var rewardText: String { "+\(boostXP) XP · -\(spendCost) gems" }
    var subtitle: String {
        if let nextUnlock {
            return "Charge runs, then spend gems to push toward \(nextUnlock.world.name)."
        }
        return "Keep energy high for streaks, bosses, relics, and reward shop unlocks."
    }
    var accessibilityLabel: String {
        "\(title). \(progressText). \(gateText). \(rewardText). \(ctaTitle)."
    }
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

struct QuestMapNode: Identifiable, Equatable {
    let id: String
    let step: Int
    let card: TrainingPlanCard
    let milestone: String
    let pathText: String
    let isCurrent: Bool

    var title: String { card.title }
    var subtitle: String { card.subtitle }
    var reward: String { card.reward }
    var subject: Subject { card.subject }
    var systemImage: String { card.systemImage }
    var progress: Double { card.progress }
    var progressText: String { card.progressText }

    var accessibilityLabel: String {
        "Step \(step). \(card.eyebrow). \(title). \(subtitle). \(pathText). Reward \(reward). Progress \(progressText)."
    }
}

struct DailyQuestMap: Equatable {
    let nodes: [QuestMapNode]
    let headline: String

    var title: String { "Daily Quest Map" }
    var subtitle: String {
        "A playable path through today: continue, cross-train, then chase a bigger world gate."
    }
    var progressText: String {
        guard !nodes.isEmpty else { return "0 nodes" }
        return "\(nodes.count) map nodes"
    }
    var accessibilityLabel: String {
        "\(title). \(headline). \(subtitle). \(progressText)."
    }
}

enum AdventureTrailAction: String, Equatable {
    case recommendedRun
    case worldTour
    case dailyFinale
}

struct AdventureTrailStop: Identifiable, Equatable {
    let id: String
    let action: AdventureTrailAction
    let step: Int
    let title: String
    let subtitle: String
    let reward: String
    let systemImage: String
    let subject: Subject
    let progress: Double
    let isReady: Bool

    var progressText: String {
        "\(Int((min(1, max(0, progress)) * 100).rounded()))%"
    }

    var statusText: String {
        if progress >= 1 { return isReady ? "Ready" : "Done" }
        return "\(progressText) charged"
    }

    var accessibilityLabel: String {
        "Step \(step), \(title). \(subtitle). \(statusText). Reward \(reward)."
    }
}

struct DailyAdventureTrail: Equatable {
    let subject: Subject
    let stops: [AdventureTrailStop]

    var title: String { "Adventure Trail" }
    var subtitle: String {
        guard let next = stops.first(where: { $0.progress < 1 || $0.isReady }) else {
            return "Today's path is cleared. Spin a new world or push for bonus XP."
        }
        return "Next move: \(next.title)"
    }
    var completedCount: Int { stops.filter { $0.progress >= 1 }.count }
    var progress: Double {
        guard !stops.isEmpty else { return 0 }
        return stops.reduce(0) { $0 + min(1, max(0, $1.progress)) } / Double(stops.count)
    }
    var progressText: String { "\(completedCount)/\(stops.count) zones" }
    var rewardText: String {
        stops.last?.reward ?? "+XP"
    }
    var accessibilityLabel: String {
        "\(title). \(subtitle). \(progressText). Final reward \(rewardText)."
    }
}

struct SkillTreeNode: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let reward: String
    let systemImage: String
    let subject: Subject
    let worldId: String?
    let isUnlocked: Bool
    let isComplete: Bool
    let progress: Double

    var statusText: String {
        if isComplete { return "Mastered" }
        if isUnlocked { return "Open" }
        return "Locked"
    }

    var progressText: String {
        "\(Int((min(1, max(0, progress)) * 100).rounded()))%"
    }

    var accessibilityLabel: String {
        "\(title). \(subtitle). \(statusText). Progress \(progressText). Reward \(reward)."
    }
}

struct SkillTree: Equatable {
    let subject: Subject
    let nodes: [SkillTreeNode]

    var title: String { "Skill Tree" }
    var subtitle: String {
        guard let next = nodes.first(where: { $0.isUnlocked && !$0.isComplete }) else {
            return "All visible \(subject.displayName) nodes are mastered. Spin a new route."
        }
        return "Next node: \(next.title)"
    }
    var progress: Double {
        guard !nodes.isEmpty else { return 0 }
        return Double(nodes.filter(\.isComplete).count) / Double(nodes.count)
    }
    var progressText: String {
        "\(nodes.filter(\.isComplete).count)/\(nodes.count) mastered"
    }
    var accessibilityLabel: String {
        "\(title). \(subtitle). \(progressText)."
    }
}

struct DailyFinaleObjective: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let isComplete: Bool

    var systemImage: String {
        isComplete ? "checkmark.seal.fill" : "circle.dashed"
    }

    var accessibilityLabel: String {
        "\(title). \(subtitle). \(isComplete ? "Complete" : "Incomplete")."
    }
}

struct DailyFinale: Equatable {
    let subject: Subject
    let reviewedToday: Int
    let correctToday: Int
    let dailyQuest: DailyQuest
    let combo: DailyCombo
    let relic: DailyRelic
    let isClaimedToday: Bool

    var objectives: [DailyFinaleObjective] {
        [
            DailyFinaleObjective(
                id: "quest",
                title: "Finish Daily Quest",
                subtitle: dailyQuest.progressText,
                isComplete: dailyQuest.progress >= 1
            ),
            DailyFinaleObjective(
                id: "combo",
                title: "Land a Focus Combo",
                subtitle: combo.progressText,
                isComplete: combo.completedCombos >= 1
            ),
            DailyFinaleObjective(
                id: "relic",
                title: "Reveal a Lesson Relic",
                subtitle: relic.progressText,
                isComplete: relic.isReady || relic.isClaimedToday
            )
        ]
    }

    var completedCount: Int { objectives.filter(\.isComplete).count }
    var totalCount: Int { objectives.count }
    var progress: Double { Double(completedCount) / Double(max(1, totalCount)) }
    var progressText: String { "\(completedCount)/\(totalCount) gates" }
    var isReady: Bool { completedCount == totalCount }
    var rewardXP: Int { 50 + min(25, max(0, dailyQuest.target - 4) * 5) }
    var rewardGems: Int { 5 }
    var title: String {
        if isClaimedToday { return "Finale Crown Claimed" }
        return isReady ? "Daily Finale Ready" : "Daily Finale"
    }
    var subtitle: String {
        if isClaimedToday { return "Today's \(subject.displayName) run is sealed. Spin a new route or keep leveling." }
        if isReady { return "Claim the crown reward for finishing the main study loop." }
        return "Finish the quest, combo, and relic gates to make today's run feel complete."
    }
    var rewardText: String { "+\(rewardXP) XP · +\(rewardGems) gems · Crown" }
    var ctaTitle: String {
        if isClaimedToday { return "Claimed" }
        return isReady ? "Claim Crown" : "\(max(0, totalCount - completedCount)) gates left"
    }
    var accessibilityLabel: String {
        "\(title). \(subtitle). Progress \(progressText). Reward \(rewardText)."
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

struct DailyWorldCompassPortal: Identifiable, Equatable {
    enum Role: Equatable {
        case activePath
        case nextUnlock
        case wildCard
    }

    let id: String
    let role: Role
    let subject: Subject
    let world: PlayableWorld?
    let eyebrow: String
    let title: String
    let subtitle: String
    let reward: String
    let ctaTitle: String
    let systemImage: String
    let progress: Double

    var progressText: String {
        "\(Int((progress * 100).rounded()))%"
    }

    var accessibilityLabel: String {
        "\(eyebrow). \(title). \(subtitle). Reward \(reward). \(progressText)."
    }
}

struct DailyWorldCompass: Equatable {
    let portals: [DailyWorldCompassPortal]

    var title: String { "World Compass" }
    var subtitle: String { "Pick the next doorway: continue, chase an unlock, or jump somewhere fresh." }
    var progressText: String { "\(portals.count) live portals" }

    var accessibilityLabel: String {
        "\(title). \(subtitle) \(portals.map(\.title).joined(separator: ", "))."
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

    func briefing(for world: PlayableWorld?, completed: Int, total: Int, xp: Int, streak: Int) -> WorldBriefing {
        let worldName = world?.name ?? mapTitle
        let remaining = max(0, total - completed)
        let progress = min(1, Double(completed) / Double(max(1, total)))
        let progressText = "\(min(completed, total))/\(max(1, total)) cleared"
        let reward = "+30 XP · \(DailyAdventure(subject: self, world: world, xp: xp, streak: streak).rewardName)"
        let cta = remaining == 0 ? "Pick Next" : "Enter Mission"

        switch self {
        case .languages:
            return WorldBriefing(
                subject: self,
                world: world,
                title: "Language Harbor Briefing",
                subtitle: "Speak, type, recall",
                scene: "A short deck is ready at the dock.",
                stakes: "Keep the streak alive with useful phrases.",
                skill: "Active recall",
                fact: "Retrieval practice strengthens memory more than rereading.",
                rewardText: reward,
                progress: progress,
                progressText: progressText,
                ctaTitle: cta,
                systemImage: "textformat.abc"
            )
        case .history:
            let scene: String
            let stakes: String
            let fact: String
            switch world?.id {
            case "ancient-rome":
                scene = "The Republic is under pressure from armies, patrons, assemblies, and ambitious commanders."
                stakes = "Every choice should connect power, law, public order, and source evidence."
                fact = "The Rubicon crisis in 49 BCE became a lasting shorthand for crossing a point of no return."
            case "medieval-europe":
                scene = "Courts, monasteries, towns, fields, and trade routes pull power in different directions."
                stakes = "Read who owns land, who controls labor, and who can enforce a promise."
                fact = "Medieval Europe was not static; towns, law, trade, and plague repeatedly changed political power."
            case "age-discovery":
                scene = "Ocean routes link empires, merchants, missionaries, and Indigenous societies with unequal power."
                stakes = "Track evidence, coercion, trade incentives, and whose perspective is missing."
                fact = "The Columbian Exchange moved crops, animals, diseases, people, and ideas across continents."
            case "renaissance-cities":
                scene = "Bankers, artists, printers, councils, and scholars compete inside wealthy city-states."
                stakes = "Notice how patronage, trade, books, and politics turn ideas into institutions."
                fact = "Printing after the mid-1400s helped knowledge travel faster and changed religious and political debate."
            case "nile-kingdoms":
                scene = "Flood cycles, temples, scribes, royal authority, and trade routes organize life along the Nile."
                stakes = "Connect environment, writing, religion, and state power before choosing."
                fact = "Nile agriculture depended on seasonal inundation, which shaped taxation, labor, and royal legitimacy."
            case "industrial-revolution":
                scene = "Factories, steam, railways, cities, labor movements, and public health collide."
                stakes = "Judge each decision by productivity, human cost, reform pressure, and evidence."
                fact = "Industrialization raised output while also forcing new laws around labor, sanitation, and urban life."
            default:
                scene = "You are entering a real era through choices, context, and historical consequences."
                stakes = "Ask what changed, who benefited, who paid the cost, and what sources can verify."
                fact = "History is strongest when choices are grounded in evidence, not trivia."
            }
            return WorldBriefing(
                subject: self,
                world: world,
                title: "\(worldName) Briefing",
                subtitle: world?.era ?? "Grounded history",
                scene: scene,
                stakes: stakes,
                skill: "Causal reasoning from real context",
                fact: fact,
                rewardText: reward,
                progress: progress,
                progressText: progressText,
                ctaTitle: cta,
                systemImage: mapSystemImage
            )
        case .science:
            return WorldBriefing(
                subject: self,
                world: world,
                title: "\(worldName) Briefing",
                subtitle: "Evidence before explanation",
                scene: "A mission asks you to match an observation with the mechanism that best explains it.",
                stakes: "Good science runs on testable claims, not confident guesses.",
                skill: "Evidence-based explanation",
                fact: "Scientific models are useful when they predict observations and survive better tests.",
                rewardText: reward,
                progress: progress,
                progressText: progressText,
                ctaTitle: cta,
                systemImage: mapSystemImage
            )
        case .geography:
            return WorldBriefing(
                subject: self,
                world: world,
                title: "\(worldName) Briefing",
                subtitle: "Map clues and place logic",
                scene: "Use borders, rivers, mountains, routes, and scale before picking the place.",
                stakes: "A good mental map helps you reason about trade, climate, conflict, and travel.",
                skill: "Spatial reasoning",
                fact: "Physical geography often shapes settlement, transport, economy, and political borders.",
                rewardText: reward,
                progress: progress,
                progressText: progressText,
                ctaTitle: cta,
                systemImage: mapSystemImage
            )
        case .math:
            return WorldBriefing(
                subject: self,
                world: world,
                title: "\(worldName) Briefing",
                subtitle: "Find the rule, then act",
                scene: "The next gate hides a pattern in numbers, shapes, chance, or data.",
                stakes: "Solving the rule matters more than memorizing one answer.",
                skill: "Reusable problem solving",
                fact: "Mathematical fluency grows when you can explain the rule behind a result.",
                rewardText: reward,
                progress: progress,
                progressText: progressText,
                ctaTitle: cta,
                systemImage: mapSystemImage
            )
        case .culture:
            return WorldBriefing(
                subject: self,
                world: world,
                title: "\(worldName) Briefing",
                subtitle: "Context before action",
                scene: "You will read a real social setting before choosing a respectful move.",
                stakes: "Culture learning should add context without flattening people into stereotypes.",
                skill: "Cultural interpretation",
                fact: "Practices such as food, music, ritual, and etiquette carry social meaning that changes by place and setting.",
                rewardText: reward,
                progress: progress,
                progressText: progressText,
                ctaTitle: cta,
                systemImage: mapSystemImage
            )
        case .business:
            return WorldBriefing(
                subject: self,
                world: world,
                title: "\(worldName) Briefing",
                subtitle: "Signals, incentives, tradeoffs",
                scene: "A decision is waiting with limited time, incomplete information, and real constraints.",
                stakes: "Durable operators separate customer value, cash, risk, and incentives from noise.",
                skill: "Practical decision making",
                fact: "Business decisions improve when assumptions are explicit and measured against feedback.",
                rewardText: reward,
                progress: progress,
                progressText: progressText,
                ctaTitle: cta,
                systemImage: mapSystemImage
            )
        case .health:
            return WorldBriefing(
                subject: self,
                world: world,
                title: "\(worldName) Briefing",
                subtitle: "Small useful habits",
                scene: "Pick a habit move that improves sleep, food, movement, hydration, recovery, or stress.",
                stakes: "The best health learning is practical, modest, repeatable, and not a fad.",
                skill: "Daily self-regulation",
                fact: "Consistent basics usually beat extreme short-term routines for long-term wellbeing.",
                rewardText: reward,
                progress: progress,
                progressText: progressText,
                ctaTitle: cta,
                systemImage: mapSystemImage
            )
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
    var lastDailyFinaleClaimDate: Date? = nil
    var lastDailyRewardTrackClaimDate: Date? = nil
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

    var questEnergy: QuestEnergy {
        QuestEnergy(
            subject: selectedSubject,
            xp: xp,
            gems: gems,
            streak: streak,
            reviewedToday: reviewedToday,
            correctToday: correctToday,
            nextUnlock: nextWorldUnlockBadge
        )
    }

    var playMenu: PlayMenu {
        let subject = selectedSubject
        let worldId = currentWorldId(for: subject)
        let world = subject.worlds.first { $0.id == worldId } ?? subject.worlds.first { $0.isUnlocked(withXP: xp) }
        let journal = worldJournal
        let boss = DailyBoss(subject: subject, correctToday: correctToday, target: 5, isDefeatedToday: lastBossDefeatDate.map { Calendar.current.isDateInToday($0) } ?? false)
        let sprintTitle: String
        let sprintSubtitle: String
        if subject == .languages {
            sprintTitle = "XP Sprint"
            sprintSubtitle = "Five mixed speak-and-type prompts."
        } else {
            sprintTitle = "\(subject.displayName) Sprint"
            sprintSubtitle = world.map { "Jump into \($0.name) for one fast mission." } ?? "Spin into the first open mission."
        }

        let modes = [
            PlayMenuMode(
                id: "sprint",
                kind: .sprint,
                title: sprintTitle,
                subtitle: sprintSubtitle,
                reward: "+12 XP · combo charge",
                ctaTitle: "Play",
                systemImage: "bolt.fill",
                subject: subject,
                worldId: world?.id,
                progress: min(1, Double(reviewedToday) / Double(max(1, dailyGoal))),
                tint: subject
            ),
            PlayMenuMode(
                id: "expedition",
                kind: .expedition,
                title: journal.title,
                subtitle: journal.sceneTitle,
                reward: journal.rewardText,
                ctaTitle: "Explore",
                systemImage: subject.mapSystemImage,
                subject: journal.subject,
                worldId: journal.world?.id,
                progress: journal.progress,
                tint: journal.subject
            ),
            PlayMenuMode(
                id: "boss",
                kind: .boss,
                title: boss.title,
                subtitle: boss.subtitle,
                reward: boss.rewardText,
                ctaTitle: boss.isReady && !boss.isDefeatedToday ? "Fight" : "Charge",
                systemImage: "flame.fill",
                subject: subject,
                worldId: world?.id,
                progress: boss.progress,
                tint: subject
            )
        ]

        return PlayMenu(modes: modes)
    }

    var worldBriefing: WorldBriefing {
        if selectedSubject == .languages {
            let total = max(dailyGoal, 1)
            let completed = min(reviewedToday, total)
            return WorldBriefing(
                subject: .languages,
                world: nil,
                title: "Language Harbor Briefing",
                subtitle: selectedLanguagePair.displayName,
                scene: "Your next route mixes recall, typing, and speech so phrases become usable outside the app.",
                stakes: "\(max(1, total - completed)) prompts left before today's fluency drop fills.",
                skill: "Active recall under light pressure",
                fact: "Spaced repetition works best when review is effortful enough to require retrieval.",
                rewardText: "+30 XP · Fluency Drop",
                progress: min(1, Double(completed) / Double(total)),
                progressText: "\(completed)/\(total) prompts",
                ctaTitle: "Start Review",
                systemImage: "textformat.abc"
            )
        }

        let progress = subjectProgress[selectedSubject.rawValue] ?? SubjectProgress()
        let world = selectedSubject.worlds.first { $0.id == (progress.currentWorldId ?? "") }
            ?? selectedSubject.worlds.first { $0.isUnlocked(withXP: xp) }
            ?? selectedSubject.worlds.first
        let challengeIds = world.map { selectedSubject.challengeIds(for: $0.id) } ?? []
        let completed = progress.completedChallengeIds.filter { challengeIds.contains($0) }.count
        let total = max(challengeIds.count, 1)

        return selectedSubject.briefing(
            for: world,
            completed: completed,
            total: total,
            xp: xp,
            streak: streak
        )
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

    var skillTree: SkillTree {
        let subject = selectedSubject
        if subject == .languages {
            let total = max(dailyGoal, 1)
            let reviewedProgress = min(1, Double(reviewedToday) / Double(total))
            let accuracyProgress = min(1, accuracyToday)
            let streakProgress = min(1, Double(streak) / 7.0)
            return SkillTree(
                subject: .languages,
                nodes: [
                    SkillTreeNode(
                        id: "language-recall",
                        title: "Recall Dock",
                        subtitle: "Clear today's mixed prompts",
                        reward: "+12 XP · Fluency Drop",
                        systemImage: "textformat.abc",
                        subject: .languages,
                        worldId: nil,
                        isUnlocked: true,
                        isComplete: reviewedProgress >= 1,
                        progress: reviewedProgress
                    ),
                    SkillTreeNode(
                        id: "language-accuracy",
                        title: "Accuracy Lantern",
                        subtitle: "Keep answers clean under pressure",
                        reward: "+1 gem · combo spark",
                        systemImage: "checkmark.seal.fill",
                        subject: .languages,
                        worldId: nil,
                        isUnlocked: reviewedToday > 0,
                        isComplete: reviewedToday >= 4 && accuracyToday >= 0.8,
                        progress: reviewedToday == 0 ? 0 : accuracyProgress
                    ),
                    SkillTreeNode(
                        id: "language-streak",
                        title: "Streak Lighthouse",
                        subtitle: "Build a seven-day practice chain",
                        reward: "Harbor Glow Aura",
                        systemImage: "flame.fill",
                        subject: .languages,
                        worldId: nil,
                        isUnlocked: reviewedToday >= 1 || streak > 0,
                        isComplete: streak >= 7,
                        progress: streakProgress
                    )
                ]
            )
        }

        let progress = subjectProgress[subject.rawValue] ?? SubjectProgress()
        let nodes = subject.worlds.map { world in
            let challengeIds = subject.challengeIds(for: world.id)
            let completed = progress.completedChallengeIds.filter { challengeIds.contains($0) }.count
            let total = max(challengeIds.count, 1)
            let isUnlocked = world.isUnlocked(withXP: xp)
            let isComplete = isUnlocked && !challengeIds.isEmpty && completed >= challengeIds.count
            return SkillTreeNode(
                id: "\(subject.rawValue)-\(world.id)",
                title: world.name,
                subtitle: isUnlocked ? world.era : "\(world.xpRemaining(withXP: xp)) XP to unlock",
                reward: world.rewardName,
                systemImage: subject.mapSystemImage,
                subject: subject,
                worldId: world.id,
                isUnlocked: isUnlocked,
                isComplete: isComplete,
                progress: isUnlocked ? min(1, Double(completed) / Double(total)) : world.unlockProgress(withXP: xp)
            )
        }
        return SkillTree(subject: subject, nodes: nodes)
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

    var dailyWorldCompass: DailyWorldCompass {
        let activeWorld: PlayableWorld? = {
            guard selectedSubject != .languages else { return nil }
            return selectedSubject.worlds.first { $0.id == currentWorldId(for: selectedSubject) }
                ?? selectedSubject.worlds.first { $0.isUnlocked(withXP: xp) }
        }()
        let activePortal = DailyWorldCompassPortal(
            id: "active-\(selectedSubject.rawValue)-\(activeWorld?.id ?? "harbor")",
            role: .activePath,
            subject: selectedSubject,
            world: activeWorld,
            eyebrow: "Continue",
            title: activeWorld?.name ?? "Language Harbor",
            subtitle: selectedSubject == .languages ? "\(selectedLanguagePair.displayName) review gate" : "\(selectedSubject.displayName) · \(activeWorld?.era ?? selectedSubject.mapTitle)",
            reward: selectedSubject == .languages ? "+20 XP · Fluency Drop" : "+25 XP · \(activeWorld?.rewardName ?? "World Badge")",
            ctaTitle: "Enter",
            systemImage: selectedSubject == .languages ? "textformat.abc" : selectedSubject.mapSystemImage,
            progress: compassProgress(for: selectedSubject, world: activeWorld)
        )

        let unlockBadge = nextWorldUnlockBadge
        let unlockPortal = DailyWorldCompassPortal(
            id: "unlock-\(unlockBadge?.subject.rawValue ?? selectedSubject.rawValue)-\(unlockBadge?.world.id ?? "next")",
            role: .nextUnlock,
            subject: unlockBadge?.subject ?? selectedSubject,
            world: unlockBadge?.world,
            eyebrow: "Unlock",
            title: unlockBadge.map { "Chase \($0.world.name)" } ?? "All Gates Open",
            subtitle: unlockBadge.map { "\($0.xpRemaining) XP left in \($0.subject.displayName)" } ?? "Every current world is open. Spin into mastery.",
            reward: unlockBadge?.world.rewardName ?? "+30 XP · Mastery route",
            ctaTitle: "Focus",
            systemImage: unlockBadge?.subject.mapSystemImage ?? "lock.open.fill",
            progress: unlockBadge.map { $0.world.unlockProgress(withXP: xp) } ?? 1
        )

        let openWorlds = Subject.allCases.flatMap { subject -> [DailyWorldCompassPortal] in
            if subject == .languages {
                return [
                    DailyWorldCompassPortal(
                        id: "wild-languages-harbor",
                        role: .wildCard,
                        subject: .languages,
                        world: nil,
                        eyebrow: "Wild Card",
                        title: "Language Harbor",
                        subtitle: "\(selectedLanguagePair.displayName) mixed recall sprint",
                        reward: "+20 XP · Fluency Drop",
                        ctaTitle: "Jump",
                        systemImage: "shuffle.circle.fill",
                        progress: min(1, Double(reviewedToday) / Double(max(1, dailyGoal)))
                    )
                ]
            }

            return subject.worlds.filter { $0.isUnlocked(withXP: xp) }.map { world in
                DailyWorldCompassPortal(
                    id: "wild-\(subject.rawValue)-\(world.id)",
                    role: .wildCard,
                    subject: subject,
                    world: world,
                    eyebrow: "Wild Card",
                    title: world.name,
                    subtitle: "\(subject.displayName) · \(world.era)",
                    reward: "+30 XP · \(world.rewardName)",
                    ctaTitle: "Jump",
                    systemImage: subject.mapSystemImage,
                    progress: compassProgress(for: subject, world: world)
                )
            }
        }

        let filteredWildcards = openWorlds.filter { $0.id != activePortal.id && $0.world?.id != unlockPortal.world?.id }
        let offset = abs(xp + reviewedToday * 3 + correctToday * 5 + streak * 7)
        let wildPortal = Self.rotated(filteredWildcards.isEmpty ? openWorlds : filteredWildcards, by: offset).first
        let portals = [activePortal, unlockPortal] + (wildPortal.map { [$0] } ?? [])
        return DailyWorldCompass(portals: Array(portals.prefix(3)))
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

    private func compassProgress(for subject: Subject, world: PlayableWorld?) -> Double {
        if subject == .languages {
            return min(1, Double(reviewedToday) / Double(max(1, dailyGoal)))
        }

        guard let world else { return 0 }
        let progress = subjectProgress[subject.rawValue] ?? SubjectProgress()
        let challengeIds = subject.challengeIds(for: world.id)
        guard !challengeIds.isEmpty else { return 0 }
        let completed = progress.completedChallengeIds.filter { challengeIds.contains($0) }.count
        return min(1, Double(completed) / Double(challengeIds.count))
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
