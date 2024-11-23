import SwiftUI
import AuthServiceDTOs

struct MainPage_ProfilView_Password: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Lade...")
                    .padding()
            } else {
                // Aktuelles Passwort Abschnitt
                VStack(alignment: .leading, spacing: 5) {
                    Text("AKTUELLES PASSWORT")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                    SecureField("Aktuelles Passwort", text: $currentPassword)
                        .padding(10)
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                }
                
                // Neues Passwort Abschnitt mit grauer Linie dazwischen
                VStack(alignment: .leading, spacing: 5) {
                    Text("NEUES PASSWORT")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                    
                    VStack(spacing: 0) {
                        SecureField("Neues Passwort", text: $newPassword)
                            .padding(10)
                            .background(Color(UIColor.systemBackground).opacity(0.8))
                        Divider()
                            .frame(height: 0.5)
                            .background(Color.gray.opacity(0.6))
                            .padding(.horizontal, 10)
                        
                        SecureField("Passwort wiederholen", text: $confirmPassword)
                            .padding(10)
                            .background(Color(UIColor.systemBackground).opacity(0.8))
                    }
                    .cornerRadius(10)
                }
                
                // Fehlermeldung oder Erfolgsmeldung
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                // Speichern Button
                Button(action: {
                    validateAndSavePassword()
                }) {
                    Text("Speichern")
                        .frame(maxWidth: .infinity)
                        .padding(15)
                        .background(Color.accentColor) // Dynamische Farben für Dark/Light mode
                        .foregroundColor(Color(UIColor.systemBackground)) // Text contrast mit dem Hintergrund
                        .cornerRadius(10)
                }
                .padding(.top, 20)

            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("Passwort", displayMode: .inline)
        .navigationBarBackButtonHidden(true) // Standard-Zurück-Button ausblenden
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Zurück zur vorherigen Ansicht
                }) {
                    HStack {
                        Image(systemName: "chevron.backward") // Pfeil-Symbol für Zurück-Button
                        Text("Profil") // Gewünschter Text
                    }
                }
            }
        }
        .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Passwortvalidierung
    private func validateAndSavePassword() {
        errorMessage = nil
        successMessage = nil

        // Einfache Validation
        guard !currentPassword.isEmpty else {
            errorMessage = "Bitte aktuelles Passwort eingeben."
            return
        }

        guard !newPassword.isEmpty else {
            errorMessage = "Bitte neues Passwort eingeben."
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "Passwörter stimmen nicht überein."
            return
        }

        guard validatePasswordStrength(newPassword) else {
            errorMessage = "Passwort muss mindestens 8 Zeichen lang sein, eine Zahl, ein Sonderzeichen und einen Großbuchstaben enthalten."
            return
        }

        // API um aktuelles Passwort zu validieren und neues zu speichern
        saveNewPassword()
    }

    private func validatePasswordStrength(_ password: String) -> Bool {
        // Minimum 8 Zeichen, 1 Großbuchstabe, 1 Kleinbuchstabe, 1 Zahl, 1 Sonderzeichen
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }

    // MARK: - API-Aufruf zum Speichern des Passworts
    private func saveNewPassword() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        guard let url = URL(string: "https://kivop.ipv64.net/users/password/reset") else {
            errorMessage = "Ungültige URL."
            isLoading = false
            return
        }

        let passwordUpdateDTO = UserPasswordUpdateDTO(
            currentPassword: currentPassword,
            newPassword: newPassword
        )

        guard let jsonData = try? JSONEncoder().encode(passwordUpdateDTO) else {
            errorMessage = "Fehler beim Kodieren der Passwortdaten."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Fehler: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Keine Antwort vom Server."
                    return
                }

                if httpResponse.statusCode == 200 {
                    successMessage = "Passwort wurde erfolgreich geändert."
                } else {
                    if let data = data,
                       let serverError = try? JSONDecoder().decode(ServerErrorDTO.self, from: data) {
                        errorMessage = serverError.message
                    } else {
                        errorMessage = "Unbekannter Fehler beim Ändern des Passworts."
                    }
                }
            }
        }.resume()
    }
}

// MARK: - DTO für Passwortänderung
public struct UserPasswordUpdateDTO: Codable {
    public var currentPassword: String
    public var newPassword: String

    public init(currentPassword: String, newPassword: String) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}

// MARK: - ServerErrorDTO für Fehlermeldungen
public struct ServerErrorDTO: Codable {
    public var message: String
}

struct MainPage_ProfilView_Password_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainPage_ProfilView_Password()
        }
    }
}
