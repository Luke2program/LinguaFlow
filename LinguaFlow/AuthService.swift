import Foundation
import CryptoKit
import AuthenticationServices
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

// MARK: - Auth Service
final class AuthService: NSObject, ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated = false
    @Published var user: User? = nil
    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var profileImageURL: URL? = nil
    @Published var authProvider: AuthProvider = .none
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showError = false
    
    private var currentNonce: String?
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    enum AuthProvider: String {
        case none, apple, google, email
    }
    
    private override init() {
        super.init()
        listenToAuthChanges()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    private func listenToAuthChanges() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.user = user
            self.isAuthenticated = user != nil
            
            if let user = user {
                self.displayName = user.displayName ?? user.email?.components(separatedBy: "@").first ?? "Learner"
                self.email = user.email ?? ""
                self.profileImageURL = user.photoURL
                self.authProvider = self.detectProvider(user: user)
            } else {
                self.displayName = ""
                self.email = ""
                self.profileImageURL = nil
                self.authProvider = .none
            }
        }
    }
    
    private func detectProvider(user: User) -> AuthProvider {
        for info in user.providerData {
            switch info.providerID {
            case "apple.com": return .apple
            case "google.com": return .google
            case "password": return .email
            default: continue
            }
        }
        return .none
    }
    
    // MARK: - Apple Sign-In
    func signInWithApple() {
        isLoading = true
        errorMessage = nil
        showError = false
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - Google Sign-In
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        showError = false
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            handleError(.signInFailed)
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError(.signInFailed)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.handleError(.noAuthData)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.handleFirebaseError(error)
                    return
                }
                
                self.isAuthenticated = true
                self.updateUserProfile(user: authResult?.user, displayName: user.profile?.name)
                CloudSyncService.shared.initialSync()
            }
        }
    }
    
    // MARK: - Email/Password Auth
    func signInWithEmail(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        showError = false
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.handleFirebaseError(error)
                return
            }
            
            self.isAuthenticated = true
            self.updateUserProfile(user: authResult?.user)
            CloudSyncService.shared.initialSync()
        }
    }
    
    func createAccountWithEmail(email: String, password: String, displayName: String) {
        isLoading = true
        errorMessage = nil
        showError = false
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.handleFirebaseError(error)
                return
            }
            
            self.isAuthenticated = true
            self.updateUserProfile(user: authResult?.user, displayName: displayName)
            CloudSyncService.shared.initialSync()
        }
    }
    
    func sendPasswordReset(email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error == nil)
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            isAuthenticated = false
            user = nil
        } catch {
            handleError(.unknown)
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        user?.delete { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                self.signOut()
                CloudSyncService.shared.deleteAllUserData()
            }
            completion(error == nil)
        }
    }
    
    // MARK: - Private Helpers
    private func updateUserProfile(user: User?, displayName: String? = nil) {
        if let user = user, let name = displayName {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { _ in }
        }
    }
    
    private func handleError(_ error: AuthError) {
        isLoading = false
        errorMessage = error.localizedDescription
        showError = true
    }
    
    private func handleFirebaseError(_ error: Error) {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.invalidCredential.rawValue: handleError(.invalidCredentials)
        case AuthErrorCode.emailAlreadyInUse.rawValue: handleError(.userAlreadyExists)
        case AuthErrorCode.weakPassword.rawValue: handleError(.weakPassword)
        case AuthErrorCode.networkError.rawValue: handleError(.networkError)
        case AuthErrorCode.userDisabled.rawValue: handleError(.invalidCredentials)
        default: handleError(.unknown)
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var nonce = ""
        for byte in randomBytes {
            nonce.append(charset[Int(byte) % charset.count])
        }
        return nonce
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                handleError(.signInFailed)
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                handleError(.noAuthData)
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                handleError(.noAuthData)
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                        idToken: idTokenString,
                                                        rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.handleFirebaseError(error)
                    return
                }
                
                self.isAuthenticated = true
                
                if let fullName = appleIDCredential.fullName,
                   let displayName = PersonNameComponentsFormatter().string(from: fullName) {
                    self.updateUserProfile(user: authResult?.user, displayName: displayName)
                }
                
                CloudSyncService.shared.initialSync()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isLoading = false
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled: handleError(.userCancelled)
            case .invalidResponse, .notHandled: handleError(.signInFailed)
            default: handleError(.unknown)
            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

// MARK: - Auth Error
enum AuthError: Error, LocalizedError {
    case signInFailed
    case noAuthData
    case credentialRevoked
    case userCancelled
    case invalidCredentials
    case userAlreadyExists
    case weakPassword
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .signInFailed: return "Sign-in failed"
        case .noAuthData: return "No authentication data received"
        case .credentialRevoked: return "Your credentials were revoked"
        case .userCancelled: return "Sign-in was cancelled"
        case .invalidCredentials: return "Invalid email or password"
        case .userAlreadyExists: return "An account with this email already exists"
        case .weakPassword: return "Password is too weak"
        case .networkError: return "Network error. Please check your connection"
        case .unknown: return "An unknown error occurred"
        }
    }
}
