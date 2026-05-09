import SwiftUI

struct EmailConfigView: View {
    @State private var apiKey = ""
    @State private var testEmail = ""
    @State private var isTesting = false
    @State private var testResult: String? = nil
    @State private var showTestResult = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Resend API Key") {
                    SecureField("Enter API Key (re_...)", text: $apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                    
                    Button("Save API Key") {
                        EmailService.shared.saveAPIKey(apiKey)
                        testResult = "API Key saved!"
                        showTestResult = true
                    }
                    .disabled(apiKey.isEmpty)
                }
                
                Section("Current Status") {
                    HStack {
                        Text("API Key configured")
                        Spacer()
                        Image(systemName: EmailService.shared.hasAPIKey ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(EmailService.shared.hasAPIKey ? .green : .red)
                    }
                    
                    if let domain = EmailService.shared.verifiedDomain {
                        HStack {
                            Text("Domain")
                            Spacer()
                            Text(domain)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Test Email") {
                    TextField("Your email address", text: $testEmail)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                    
                    Button("Send Welcome Email") {
                        sendTestEmail(type: .welcome)
                    }
                    .disabled(testEmail.isEmpty || !EmailService.shared.hasAPIKey || isTesting)
                    
                    Button("Send Password Reset") {
                        sendTestEmail(type: .reset)
                    }
                    .disabled(testEmail.isEmpty || !EmailService.shared.hasAPIKey || isTesting)
                }
                
                Section("Setup Guide") {
                    Link("1. Create Resend Account", destination: URL(string: "https://resend.com/signup")!)
                    Link("2. Add Domain lukaskoprolin.com", destination: URL(string: "https://resend.com/domains")!)
                    Link("3. Get API Key", destination: URL(string: "https://resend.com/api-keys")!)
                }
            }
            .navigationTitle("Email Setup")
            .alert("Test Result", isPresented: $showTestResult) {
                Button("OK") { }
            } message: {
                Text(testResult ?? "")
            }
        }
    }
    
    private func sendTestEmail(type: TestType) {
        isTesting = true
        testResult = nil
        
        switch type {
        case .welcome:
            EmailService.shared.sendWelcome(to: testEmail, name: "Test User") { success in
                isTesting = false
                testResult = success ? "Welcome email sent!" : "Failed to send"
                showTestResult = true
            }
        case .reset:
            EmailService.shared.sendPasswordReset(to: testEmail, resetToken: "test-token-123") { success in
                isTesting = false
                testResult = success ? "Password reset email sent!" : "Failed to send"
                showTestResult = true
            }
        }
    }
    
    enum TestType {
        case welcome, reset
    }
}

#Preview {
    EmailConfigView()
}
