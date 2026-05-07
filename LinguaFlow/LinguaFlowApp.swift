import SwiftUI

@main
struct LinguaFlowApp: App {
    @StateObject private var store = AppStore()
    var body: some Scene {
        WindowGroup { RootView().environmentObject(store) }
    }
}
