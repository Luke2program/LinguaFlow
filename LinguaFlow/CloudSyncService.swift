import Foundation

// MARK: - Cloud Sync Service (Stub version - replace with Firebase later)
final class CloudSyncService {
    static let shared = CloudSyncService()
    
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date? = nil
    
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
    
    private init() {}
    
    func initialSync() {
        syncStatus = .syncing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.syncStatus = .success(Date())
            self.lastSyncDate = Date()
        }
    }
    
    func forceSync(completion: ((Bool) -> Void)? = nil) {
        syncStatus = .syncing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.syncStatus = .success(Date())
            self.lastSyncDate = Date()
            completion?(true)
        }
    }
    
    func deleteAllUserData() {}
}

extension Date {
    func relativeTime() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

import Combine

@propertyWrapper
struct Published<T> {
    var wrappedValue: T
    var projectedValue: CurrentValueSubject<T, Never> {
        CurrentValueSubject(wrappedValue)
    }
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}
