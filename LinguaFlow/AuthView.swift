import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var store: AppStore
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var showForgotPassword = false
    @State private var forgotEmail = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Logo area
                    logoSection
                    
                    // Title
                    VStack(spacing: 8) {
                        Text(isSignUp ? "Create Account" : "Welcome Back")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                        Text(isSignUp ? "Start your language learning journey" : "Sign in to continue learning")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Email/Password Form
                    formSection
                    
                    // Submit button
                    PrimaryButton(
                        title: isSignUp ? "Create Account" : "Sign In",
                        isLoading: authService.isLoading
                    ) {
                        handleEmailAuth()
                    }
                    
                    // Toggle sign in/up
                    Button(action: { withAnimation { isSignUp.toggle() } }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundStyle(.accentColor)
                    }
                    
                    // Divider
                    HStack {
                        Rectangle().fill(Color.primary.opacity(0.1)).frame(height: 1)
                        Text("or").font(.caption).foregroundStyle(.secondary)
                        Rectangle().fill(Color.primary.opacity(0.1)).frame(height: 1)
                    }
                    
                    // Social sign in
                    socialSignInSection
                    
                    // Skip button
                    Button("Continue without account") {
                        store.stats.hasSkippedAuth = true
                        store.save()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .alert("Error", isPresented: $authService.showError) {
                Button("OK") { authService.showError = false }
            } message: {
                Text(authService.errorMessage ?? "An error occurred")
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(email: $forgotEmail)
            }
        }
    }
    
    private var logoSection: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.1))
                .frame(width: 120, height: 120)
            
            Text("🦉")
                .font(.system(size: 60))
        }
        .padding(.top, 20)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            if isSignUp {
                AuthTextField(
                    icon: "person",
                    placeholder: "Display Name",
                    text: $displayName
                )
            }
            
            AuthTextField(
                icon: "envelope",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
            
            AuthTextField(
                icon: "lock",
                placeholder: "Password",
                text: $password,
                isSecure: true,
                textContentType: isSignUp ? .newPassword : .password
            )
            
            if !isSignUp {
                Button("Forgot Password?") {
                    forgotEmail = email
                    showForgotPassword = true
                }
                .font(.caption)
                .foregroundStyle(.accentColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    private var socialSignInSection: some View {
        VStack(spacing: 12) {
            // Apple Sign In
            SignInWithAppleButton(.signIn) { request in
                // Apple Sign In is handled by AuthService
            } onCompletion: { result in
                // Handled by AuthService delegate
            }
            .frame(height: 50)
            .cornerRadius(12)
            .onTapGesture {
                authService.signInWithApple()
            }
            
            // Google Sign In
            Button(action: { authService.signInWithGoogle() }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.title3)
                    Text("Continue with Google")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary.opacity(0.05))
                .cornerRadius(12)
            }
            .foregroundStyle(.primary)
            
            // Email Sign In (already shown above, but this is the button style reference)
        }
    }
    
    private func handleEmailAuth() {
        if isSignUp {
            guard !displayName.isEmpty else { return }
            authService.createAccountWithEmail(
                email: email,
                password: password,
                displayName: displayName
            )
        } else {
            authService.signInWithEmail(email: email, password: password)
        }
    }
}

// MARK: - Auth Text Field
struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(textContentType)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .padding()
        .background(Color.primary.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    @Binding var email: String
    @Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    @State private var message: String? = nil
    @State private var showMessage = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Reset Password")
                    .font(.title2.bold())
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                AuthTextField(
                    icon: "envelope",
                    placeholder: "Email",
                    text: $email,
                    keyboardType: .emailAddress,
                    textContentType: .emailAddress
                )
                
                PrimaryButton(title: "Send Reset Link", isLoading: isLoading) {
                    sendResetLink()
                }
                
                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Reset Password", isPresented: $showMessage) {
                Button("OK") {
                    if message?.contains("sent") == true {
                        dismiss()
                    }
                }
            } message: {
                Text(message ?? "")
            }
        }
    }
    
    private func sendResetLink() {
        isLoading = true
        AuthService.shared.sendPasswordReset(email: email) { success in
            isLoading = false
            message = success ? "Reset link sent! Check your email." : "Failed to send reset link."
            showMessage = true
        }
    }
}

// MARK: - Account Settings View
struct AccountSettingsView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showSignOutConfirmation = false
    @State private var syncStatus: CloudSyncService.SyncStatus = .idle
    
    var body: some View {
        NavigationStack {
            List {
                // User Profile Section
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.1))
                                .frame(width: 60, height: 60)
                            
                            if let url = authService.profileImageURL {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            } else {
                                Text("🦉")
                                    .font(.system(size: 30))
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authService.displayName)
                                .font(.headline)
                            Text(authService.email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Signed in with \(authService.authProvider.rawValue.capitalized)")
                                .font(.caption2)
                                .foregroundStyle(.accentColor)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Sync Section
                Section("Cloud Sync") {
                    HStack {
                        Label("Sync Status", systemImage: "arrow.clockwise.circle")
                        Spacer()
                        Text(syncStatus.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Button("Force Sync Now") {
                        CloudSyncService.shared.forceSync { success in
                            syncStatus = success ? .success(Date()) : .failed("Sync failed")
                        }
                    }
                    
                    Button("Sync Settings...") {
                        // Show sync settings
                    }
                }
                
                // Account Actions
                Section {
                    Button("Sign Out", role: .destructive) {
                        showSignOutConfirmation = true
                    }
                    
                    Button("Delete Account", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("Sign Out?", isPresented: $showSignOutConfirmation) {
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Your data will remain on this device. Sign in again to sync.")
            }
            .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    authService.deleteAccount { success in
                        if success {
                            dismiss()
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete your account and all associated data. This action cannot be undone.")
            }
            .onAppear {
                syncStatus = CloudSyncService.shared.syncStatus
            }
        }
    }
}



// MARK: - Preview
