import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Cloud Sync Models
struct CloudUserData: Codable {
    let userId: String
    let displayName: String?
    let email: String?
    let lastSync: Date
    let stats: UserStats
    let schedules: [ReviewSchedule]
    let pet: PetData
    let studySessions: [StudySession]
    let achievements: [String]
    let createdAt: Date
    let appVersion: String
    
    var dictionary: [String: Any] {
        [
            "userId": userId,
            "displayName": displayName ?? "",
            "email": email ?? "",
            "lastSync": Timestamp(date: lastSync),
            "stats": try? JSONEncoder().encode(stats).toFirestoreValue(),
            "schedules": schedules.map { try? JSONEncoder().encode($0).toFirestoreValue() }.compactMap { $0 },
            "pet": try? JSONEncoder().encode(pet).toFirestoreValue(),
            "studySessions": studySessions.map { try? JSONEncoder().encode($0).toFirestoreValue() }.compactMap { $0 },
            "achievements": achievements,
            "createdAt": Timestamp(date: createdAt),
            "appVersion": appVersion
        ]
    }
}

struct StudySession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let cardsStudied: Int
    let correctAnswers: Int
    let level: CEFRLevel
    let languagePair: LanguagePair
    
    var dictionary: [String: Any] {
        [
            "id": id.uuidString,
            "date": Timestamp(date: date),
            "duration": duration,
            "cardsStudied": cardsStudied,
            "correctAnswers": correctAnswers,
            "level": level.rawValue,
            "languagePair": languagePair.id
        ]
    }
}

// MARK: - Cloud Sync Service
final class CloudSyncService {
    static let shared = CloudSyncService()
    
    private let db = Firestore.firestore()
    private let syncQueue = DispatchQueue(label: "com.linguaflow.sync", qos: .background)
    private var syncTimer: Timer?
    private var lastLocalSync: Date?
    private var isSyncing = false
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date? = nil
    @Published var pendingUploads = 0
    
    enum SyncStatus: Equatable {
        case idle
        case syncing
        case success(Date)
        case failed(String)
        case offline
        
        var description: String {
            switch self {
            case .idle: return "Ready to sync"
            case .syncing: return "Syncing..."
            case .success(let date): return "Synced \(date.relativeTime())"
            case .failed(let error): return "Sync failed: \(error)"
            case .offline: return "Offline — will sync when online"
            }
        }
    }
    
    private init() {
        startAutoSync()
        observeNetworkChanges()
    }
    
    deinit {
        syncTimer?.invalidate()
    }
    
    // MARK: - Initial Sync
    func initialSync() {
        guard let user = Auth.auth().currentUser else { return }
        
        syncStatus = .syncing
        
        // Check if user has cloud data
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let snapshot = snapshot, snapshot.exists {
                // User has cloud data — download and merge
                self.downloadAndMerge(userId: user.uid) { success in
                    if success {
                        self.syncStatus = .success(Date())
                        self.lastSyncDate = Date()
                    } else {
                        self.syncStatus = .failed("Download failed")
                    }
                }
            } else {
                // New user — upload local data
                self.uploadUserData(userId: user.uid) { success in
                    if success {
                        self.syncStatus = .success(Date())
                        self.lastSyncDate = Date()
                    } else {
                        self.syncStatus = .failed("Upload failed")
                    }
                }
            }
        }
    }
    
    // MARK: - Upload
    func uploadUserData(userId: String? = nil, completion: ((Bool) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {
            completion?(false)
            return
        }
        
        let uid = userId ?? user.uid
        
        syncQueue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async { self.syncStatus = .syncing }
            
            let store = AppStore.shared
            let data = CloudUserData(
                userId: uid,
                displayName: user.displayName,
                email: user.email,
                lastSync: Date(),
                stats: store.stats,
                schedules: Array(store.schedules.values),
                pet: store.stats.pet,
                studySessions: self.loadLocalStudySessions(),
                achievements: Array(store.achievements),
                createdAt: Date(),
                appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            )
            
            self.db.collection("users").document(uid).setData(data.dictionary, merge: true) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.syncStatus = .failed(error.localizedDescription)
                        completion?(false)
                    } else {
                        self.lastSyncDate = Date()
                        self.syncStatus = .success(Date())
                        self.lastLocalSync = Date()
                        completion?(true)
                    }
                }
            }
        }
    }
    
    // MARK: - Download & Merge
    func downloadAndMerge(userId: String, completion: ((Bool) -> Void)? = nil) {
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.syncStatus = .failed(error.localizedDescription)
                    completion?(false)
                }
                return
            }
            
            guard let data = snapshot?.data() else {
                completion?(true)
                return
            }
            
            self.mergeCloudData(data) { success in
                DispatchQueue.main.async {
                    completion?(success)
                }
            }
        }
    }
    
    private func mergeCloudData(_ data: [String: Any], completion: ((Bool) -> Void)? = nil) {
        syncQueue.async {
            do {
                // Decode cloud stats
                if let statsData = data["stats"] as? [String: Any] {
                    let jsonData = try JSONSerialization.data(withJSONObject: statsData)
                    let cloudStats = try JSONDecoder().decode(UserStats.self, from: jsonData)
                    
                    // Merge: keep the more recent or more complete data
                    DispatchQueue.main.async {
                        let store = AppStore.shared
                        store.stats = self.mergeStats(local: store.stats, cloud: cloudStats)
                        store.save()
                        completion?(true)
                    }
                } else {
                    DispatchQueue.main.async { completion?(true) }
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(false)
                }
            }
        }
    }
    
    private func mergeStats(local: UserStats, cloud: UserStats) -> UserStats {
        var merged = local
        
        // Keep the higher XP/streak
        if cloud.totalXP > local.totalXP {
            merged.totalXP = cloud.totalXP
        }
        if cloud.streak > local.streak {
            merged.streak = cloud.streak
        }
        if cloud.longestStreak > local.longestStreak {
            merged.longestStreak = cloud.longestStreak
        }
        
        // Merge session counts
        merged.sessionsCompleted += cloud.sessionsCompleted
        merged.totalCardsReviewed += cloud.totalCardsReviewed
        
        // Keep the more recent last study date
        if cloud.lastStudyDate > local.lastStudyDate {
            merged.lastStudyDate = cloud.lastStudyDate
        }
        
        // Merge deck progress (keep higher mastery for each card)
        for (cardId, cloudMastery) in cloud.deckMastery {
            if let localMastery = local.deckMastery[cardId] {
                merged.deckMastery[cardId] = max(localMastery, cloudMastery)
            } else {
                merged.deckMastery[cardId] = cloudMastery
            }
        }
        
        // Merge achievements
        var mergedAchievements = Set(local.achievements)
        mergedAchievements.formUnion(cloud.achievements)
        merged.achievements = Array(mergedAchievements)
        
        return merged
    }
    
    // MARK: - Auto Sync
    private func startAutoSync() {
        syncTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.triggerAutoSync()
        }
    }
    
    private func triggerAutoSync() {
        guard Auth.auth().currentUser != nil else { return }
        guard !isSyncing else { return }
        
        // Only sync if local data changed
        if let lastSync = lastLocalSync,
           let lastLocalChange = getLastLocalChangeDate(),
           lastLocalChange <= lastSync {
            return
        }
        
        isSyncing = true
        uploadUserData { [weak self] _ in
            self?.isSyncing = false
        }
    }
    
    // MARK: - Force Sync
    func forceSync(completion: ((Bool) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {
            completion?(false)
            return
        }
        
        syncStatus = .syncing
        
        // Download first, then upload merged data
        downloadAndMerge(userId: user.uid) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                self.uploadUserData { uploadSuccess in
                    completion?(uploadSuccess)
                }
            } else {
                completion?(false)
            }
        }
    }
    
    // MARK: - Delete All Data
    func deleteAllUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        db.collection("users").document(user.uid).delete { error in
            if let error = error {
                print("Failed to delete cloud data: \(error)")
            }
        }
    }
    
    // MARK: - Private Helpers
    private func getLastLocalChangeDate() -> Date? {
        // This would track last local modification
        // For now, return current date to always sync
        return Date()
    }
    
    private func loadLocalStudySessions() -> [StudySession] {
        // Load from UserDefaults or local storage
        return []
    }
    
    private func observeNetworkChanges() {
        // Monitor network reachability
        // Implementation depends on Reachability or NWPathMonitor
    }
    
    // MARK: - Conflict Resolution
    func resolveConflict(local: UserStats, cloud: UserStats, completion: @escaping (UserStats) -> Void) {
        // Default: merge both
        let merged = mergeStats(local: local, cloud: cloud)
        completion(merged)
    }
}

// MARK: - Helper Extensions
extension Data {
    func toFirestoreValue() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: [])
    }
}

extension Date {
    func relativeTime() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - AppStore Singleton Access
extension AppStore {
    static weak var sharedInstance: AppStore?
    static var shared: AppStore {
        guard let instance = sharedInstance else {
            fatalError("AppStore.sharedInstance must be set during app initialization")
        }
        return instance
    }
}
