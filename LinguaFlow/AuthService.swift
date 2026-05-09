import Foundation
import AuthenticationServices
import CryptoKit

// MARK: - Stub Auth Service (Firebase-free for now)
// Replace with full Firebase version once packages are added
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
    
    enum AuthProvider: String {
        case none, apple, google, email
    }
    
    private override init() {
        super.init()
    }
    
    func signInWithApple() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isAuthenticated = true
            self.displayName = "Apple User"
            self.email = "user@icloud.com"
            self.authProvider = .apple
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
        }
    }
    
    func sendPasswordReset(email: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func signOut() {
        isAuthenticated = false
        displayName = ""
        email = ""
        authProvider = .none
    }
    
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        signOut()
        completion(true)
    }
}

enum AuthError: Error, LocalizedError {
    case signInFailed, noAuthData, userCancelled, invalidCredentials, unknown
    var errorDescription: String? {
        switch self {
        case .signInFailed: return "Sign-in failed"
        case .noAuthData: return "No authentication data"
        case .userCancelled: return "Cancelled"
        case .invalidCredentials: return "Invalid credentials"
        case .unknown: return "Unknown error"
        }
    }
}
