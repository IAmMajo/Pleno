import SwiftUI

@main
struct KIVoP_iosApp: App {
    var body: some Scene {
        WindowGroup {
            Onboarding()
                .environmentObject(AuthController.shared)
        }
    }
}
