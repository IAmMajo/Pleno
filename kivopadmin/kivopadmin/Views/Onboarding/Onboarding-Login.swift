import SwiftUI

struct Onboarding_Login: View {
    @Environment(\.colorScheme) var colorScheme // Zugriff auf Light/Dark Mode
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
                VStack(spacing: 0) {
                    TextField("", text: $email,prompt: Text("E-Mail-Adresse")
                        .foregroundColor(dynamicPlaceholderColor()))
                        .padding()
                        .background(Color(UIColor.systemBackground)) // Dynamische Anpassung an den Modus
                        .foregroundColor(Color.primary) // Passt die Textfarbe an den Modus an
                        .frame(width: 615)
                    
                    Divider()
                        .frame(height: 0.5)
                        .background(Color.gray.opacity(0.6))
                        .padding(.horizontal, 10)
                        .frame(width: 615)
                    
                    SecureField("", text: $password, prompt: Text("Passwort")
                        .foregroundColor(dynamicPlaceholderColor()))
                        .padding()
                        .background(Color(UIColor.systemBackground)) // Dynamische Anpassung an den Modus
                        .foregroundColor(Color.primary) // Passt die Textfarbe an den Modus an
                        .frame(width: 615)
                }
                .cornerRadius(10)

                
               
                
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
                .frame(width: 570)
                .padding(.horizontal, 24)
                .padding(.bottom, 35)
                
                // Login-Button
                NavigationLink(destination: MainPage()) {
                    Text("Einloggen")
                        .foregroundColor(.white)
                        .frame(width: 450, height: 44)
                        .background(Color.blue)
                        .cornerRadius(10)
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
    func dynamicPlaceholderColor() -> Color {
           return colorScheme == .dark ? .white : .black
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
