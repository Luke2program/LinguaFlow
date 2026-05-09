import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct LinguaFlowApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var authService = AuthService.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(authService)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
