import SwiftUI

struct Onboarding_Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 40)
                
                // Login title
                ZStack(alignment: .bottom) {
                    Text("Login")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 5) // Abstand zur Linie

                    Rectangle()
                        .frame(width: 103, height: 3) // Breite des Rechtecks anpassen
                        .foregroundColor(.primary) // Farbe der Linie
                        .offset(y: 5) // Abstand nach unten justieren
                }
                .padding(.bottom, 40)
                .padding(.top, 40)

                
                // Email TextField
                VStack(alignment: .leading, spacing: 5) {
                    Text("E-MAIL")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                        .padding(.horizontal, 5)
                    
                    TextField("E-Mail", text: $email)
                        .padding()
                        .background(Color(UIColor.systemBackground)) // Adapts to Light and Dark mode
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                
                // Password TextField
                VStack(alignment: .leading, spacing: 5) {
                    Text("PASSWORT")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                        .padding(.horizontal, 5)
                    
                    SecureField("Passwort", text: $password)
                        .padding()
                        .background(Color(UIColor.systemBackground)) // Adapts to Light and Dark mode
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                
                Spacer()
                
                // Login Button
                NavigationLink(destination: MainPage()) {
                    Text("Login")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                
                // Register Button
                NavigationLink(destination: Onboarding_Register()) {
                    Text("Registrieren")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color(UIColor.systemGray5)) // Light gray background in both modes
                        .fontWeight(.bold)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                
                // Back Button
                NavigationLink(destination: Onboarding()) {
                    Text("Zurück")
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .underline()
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                Spacer().frame(height: 20)
            }
            .background(Color(UIColor.systemGray6))
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct Onboarding_Login_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_Login()
            .environment(\.colorScheme, .light) // Preview in Light Mode
        Onboarding_Login()
            .environment(\.colorScheme, .dark) // Preview in Dark Mode
    }
}
