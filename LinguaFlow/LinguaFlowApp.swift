import SwiftUI

@main
struct LinguaFlowApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(authService)
        }
    }
}
