// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



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
                Onboarding(isLoggedIn: $isLoggedIn) // Zeigt die Login-Ansicht, wenn der Benutzer nicht eingeloggt ist
            }
        }
    }
}
