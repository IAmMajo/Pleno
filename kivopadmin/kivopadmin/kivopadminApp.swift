import SwiftUI

@main
struct KIVoP_iosApp: App {
    @State private var isLoggedIn: Bool = false // Login-Status nur für die aktuelle Sitzung
    
    var body: some Scene {
        WindowGroup {
            // Überprüfe den Login-Status und zeige die entsprechende Ansicht
            if isLoggedIn {
                MainPage() // Zeigt die Hauptansicht, wenn der Benutzer eingeloggt ist
            } else {
                Onboarding_Login(isLoggedIn: $isLoggedIn) // Zeigt die Login-Ansicht, wenn der Benutzer nicht eingeloggt ist
            }
        }
    }
}
