import SwiftUI
import AuthServiceDTOs

struct Onboarding_Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @State private var loginSuccessful: Bool = false
    @State private var isBiometricPromptShown: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 40)
                
                // Titel "Login"
                ZStack(alignment: .bottom) {
                    Text("Login")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)

                    Rectangle()
                        .frame(width: 103, height: 3)
                        .foregroundColor(.primary)
                        .offset(y: 5)
                }
                .padding(.bottom, 40)
                .padding(.top, 40)
                
                // Eingabefeld für die E-Mail
                inputField(title: "E-Mail", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                // Eingabefeld für das Passwort
                inputField(title: "Passwort", text: $password, isSecure: true)
                
                Spacer()
                
                // Login-Button
                Button(action: {
                    loginUser()
                }) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                // Fehlermeldung anzeigen
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal, 24)
                }
                
                // Registrieren-Button
                NavigationLink(destination: Onboarding_Register()) {
                    Text("Registrieren")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color(UIColor.systemGray5))
                        .fontWeight(.bold)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)
                
                // Zurück-Button
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
            .navigationDestination(isPresented: $loginSuccessful) {
                MainPage()
            }
            .onAppear {
                attemptBiometricLogin()
            }
        }
    }
    
    // Funktion für den Login
    private func loginUser() {
        isLoading = true
        errorMessage = nil
        
        let loginDTO = UserLoginDTO(email: email, password: password)
        OnboardingAPI.loginUser(with: loginDTO) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let token):
                    // Token speichern und zur Hauptseite navigieren
                    UserDefaults.standard.set(token, forKey: "jwtToken")
                    loginSuccessful = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Funktion zur biometrischen Anmeldung
    private func attemptBiometricLogin() {
        // Überprüfen, ob Zugangsdaten im Schlüsselbund gespeichert sind
        if let storedEmail = KeychainHelper.load(key: "userEmail"),
           let storedPassword = KeychainHelper.load(key: "userPassword"),
           !isBiometricPromptShown {
            
            // Biometrische Authentifizierung auslösen
            isBiometricPromptShown = true
            Task {
                let isAuthenticated = await BiometricAuth.authenticate()
                DispatchQueue.main.async {
                    if isAuthenticated {
                        email = storedEmail
                        password = storedPassword
                        loginUser()
                    }
                }
            }
        }
    }
    
    // Eingabefeld-Komponente
    private func inputField(title: String, text: Binding<String>, isSecure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 5)
                .padding(.horizontal, 5)
            
            if isSecure {
                SecureField(title, text: text)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
            } else {
                TextField(title, text: text)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }
}

struct Onboarding_Login_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_Login()
            .environment(\.colorScheme, .light) // Vorschau im hellen Modus
        Onboarding_Login()
            .environment(\.colorScheme, .dark) // Vorschau im dunklen Modus
    }
}
