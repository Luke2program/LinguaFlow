import Foundation
import AuthenticationServices
import CryptoKit

// MARK: - Auth Service (Stub version - replace with Firebase later)
final class AuthService: NSObject, ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated = false
    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var profileImageURL: URL? = nil
    @Published var authProvider: AuthProvider = .none
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showError = false
    
    enum AuthProvider: String, Codable {
        case none, apple, google, email
    }
    
    private let authKey = "linguaflow.auth.v1"
    
    private override init() {
        super.init()
        if ProcessInfo.processInfo.arguments.contains("--reset-ui-state") {
            UserDefaults.standard.removeObject(forKey: authKey)
        }
        load()
    }
    
    private func load() {
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
        if let data = UserDefaults.standard.data(forKey: authKey),
           let decoded = try? decoder.decode(AuthState.self, from: data) {
            self.isAuthenticated = decoded.isAuthenticated
            self.displayName = decoded.displayName
            self.email = decoded.email
            self.authProvider = decoded.authProvider
        }
    }
    
    private func save() {
        let state = AuthState(
            isAuthenticated: isAuthenticated,
            displayName: displayName,
            email: email,
            authProvider: authProvider
        )
        let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601
        UserDefaults.standard.set(try? encoder.encode(state), forKey: authKey)
    }
    
    private struct AuthState: Codable {
        var isAuthenticated: Bool
        var displayName: String
        var email: String
        var authProvider: AuthProvider
    }
    
    func signInWithApple() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isAuthenticated = true
            self.displayName = "Apple User"
            self.email = "user@icloud.com"
            self.authProvider = .apple
            self.save()
        }
    }
    
    func signInWithGoogle() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isAuthenticated = true
            self.displayName = "Google User"
            self.email = "user@gmail.com"
            self.authProvider = .google
            self.save()
        }
    }
    
    func signInWithEmail(email: String, password: String) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isAuthenticated = true
            self.displayName = email.components(separatedBy: "@").first ?? "User"
            self.email = email
            self.authProvider = .email
            self.save()
        }
    }
    
    func createAccountWithEmail(email: String, password: String, displayName: String) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isAuthenticated = true
            self.displayName = displayName
            self.email = email
            self.authProvider = .email
            self.save()
        }
    }
    
    func sendPasswordReset(email: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func updateLogin(email: String, password: String, displayName: String, completion: @escaping (Bool) -> Void) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Email cannot be empty."
            showError = true
            completion(false)
            return
        }
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.isLoading = false
            self.email = trimmedEmail
            self.displayName = trimmedName.isEmpty ? (trimmedEmail.components(separatedBy: "@").first ?? "User") : trimmedName
            if self.authProvider == .none { self.authProvider = .email }
            self.isAuthenticated = true
            self.save()
            completion(true)
        }
    }
    
    func signOut() {
        isAuthenticated = false
        displayName = ""
        email = ""
        authProvider = .none
        save()
    }
    
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        signOut()
        completion(true)
    }
}
