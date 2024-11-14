import SwiftUI

struct Onboarding_Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)
                
                // Titel für Login
                Text("Willkommen zurück!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 30)
                
                // Textfeld für E-Mail
                VStack(spacing: 5) {
                    TextField("E-Mail-Adresse", text: $email)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground)) // Anpassbarer Hintergrund für Dark/Light Mode
                        .cornerRadius(10)
                        .overlay( // Rahmen für bessere Sichtbarkeit
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(UIColor.separator), lineWidth: 1)
                        )
                        .frame(width: 450)
                }
                .padding(.horizontal, 24)
                
                // Textfeld für Passwort
                VStack(spacing: 5) {
                    SecureField("Passwort", text: $password)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground)) // Anpassbarer Hintergrund für Dark/Light Mode
                        .cornerRadius(10)
                        .overlay( // Rahmen für bessere Sichtbarkeit
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(UIColor.separator), lineWidth: 1)
                        )
                        .frame(width: 450)
                }
                .padding(.horizontal, 24)
                
                // Links für Registrierung und Passwort vergessen
                HStack {
                    NavigationLink(destination: Onboarding_Register()) {
                        Text("Registrieren")
                            .foregroundColor(.blue)
                            .font(.footnote)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: Text("Passwort vergessen?")) {
                        Text("Passwort vergessen?")
                            .foregroundColor(.blue)
                            .font(.footnote)
                    }
                }
                .frame(width: 450)
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                
                // Login-Button
                NavigationLink(destination: MainPage()) {
                    Text("Einloggen")
                        .foregroundColor(.white)
                        .frame(width: 450, height: 44)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 20)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGray6)) // Hintergrundfarbe für die gesamte Ansicht
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct Onboarding_Login_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_Login()
            .environment(\.colorScheme, .light) // Vorschau im Light Mode
        Onboarding_Login()
            .environment(\.colorScheme, .dark) // Vorschau im Dark Mode
    }
}
