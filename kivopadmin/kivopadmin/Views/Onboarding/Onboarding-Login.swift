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
import LocalAuthentication
import AuthServiceDTOs

struct Onboarding_Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @State private var loginSuccessful: Bool = false
    @State private var faceIDTriggered = false
    @State private var isKeychainAvailable = false
    @State private var isActive = true

    
    @Binding var isLoggedIn: Bool
    @Environment(\.dismiss) private var dismiss // Für das Zurückgehen

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 40)

                // Login title
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

                // Email TextField
                inputField(title: "E-Mail", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                // Password TextField
                inputField(title: "Passwort", text: $password, isSecure: true)
                
                // "Passwort vergessen?" Link
                NavigationLink(destination: ForgotPasswordView()) {
                    Text("Passwort vergessen?")
                        .foregroundColor(.blue)
                        .font(.footnote)
                        .padding(.top, 5)
                    }


                Spacer()
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal, 24)
                }

                // Login Button
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


                // Register Button
                NavigationLink(destination: Onboarding_Register(isLoggedIn: $isLoggedIn)) {
                    Text("Registrieren")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color(UIColor.systemGray5))
                        .fontWeight(.bold)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 24)

                // Back Button
                NavigationLink(destination: Onboarding(isManualNavigation: true, isLoggedIn: $isLoggedIn)) { // Setze isManualNavigation auf true
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
//            .navigationDestination(isPresented: $loginSuccessful) {
//                MainPage()
//            }
            .onAppear {
                isActive = true
                checkKeychainAvailability()
            }
            .onDisappear {
                isActive = false
            }
        }
    }

    private func loginUser() {
        isLoading = true
        errorMessage = nil

        let loginDTO = UserLoginDTO(email: email, password: password)
        OnboardingAPI.loginUser(with: loginDTO) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let token):
                    UserDefaults.standard.set(token, forKey: "jwtToken")
                    saveCredentialsToKeychain()
                    loginSuccessful = true
                    isLoggedIn = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    // Speichert die Anmeldedaten sicher in der Keychain.
    private func saveCredentialsToKeychain() {
        KeychainHelper.save(key: "email", value: email)
        KeychainHelper.save(key: "password", value: password)
    }

    // Versucht automatisch eine Anmeldung mit gespeicherten Keychain-Daten.
    private func attemptLoginWithKeychain() {
        if let savedEmail = KeychainHelper.load(key: "email"),
           let savedPassword = KeychainHelper.load(key: "password") {
            email = savedEmail
            password = savedPassword
            loginUser()
        }
    }

    // Startet FaceID / TouchID zur Authentifizierung, falls aktiviert.
    private func triggerFaceID() {
        guard isKeychainAvailable, !faceIDTriggered, isActive else { return }
        faceIDTriggered = true

        Task {
            let isAuthenticated = await BiometricAuth.authenticate()
            if isAuthenticated {
                attemptLoginWithKeychain()
            }
        }
    }

    // Überprüft, ob Anmeldedaten in der Keychain gespeichert sind.
    private func checkKeychainAvailability() {
        isKeychainAvailable = KeychainHelper.load(key: "email") != nil && KeychainHelper.load(key: "password") != nil
        if isKeychainAvailable {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                triggerFaceID()
            }
        }
    }

    // Erstellt ein wiederverwendbares Eingabefeld für Text und sichere Eingaben.
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

//struct Onboarding_Login_Previews: PreviewProvider {
//    static var previews: some View {
//        Onboarding_Login()
//            .environment(\.colorScheme, .light)
//        Onboarding_Login()
//            .environment(\.colorScheme, .dark)
//    }
//}
