import SwiftUI
import AuthServiceDTOs

struct MainPage_ProfilView_Password: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var currentPasswordError: String? = nil
    @State private var newPasswordError: String? = nil
    @State private var confirmPasswordError: String? = nil
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
                    if let error = currentPasswordError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // Neues Passwort Abschnitt mit grauer Linie dazwischen
                VStack(alignment: .leading, spacing: 5) {
                    Text("NEUES PASSWORT")
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                    
                    SecureField("Neues Passwort", text: $newPassword)
                        .onChange(of: newPassword) { newValue in
                            print("[DEBUG] Neues Passwort eingegeben: \(newValue)")
                            newPasswordError = validatePasswordStrength(newValue) ? nil : "Passwort ist zu schwach."
                        }
                        .padding(10)
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                    if let error = newPasswordError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Divider()
                        .frame(height: 0.5)
                        .background(Color.gray.opacity(0.6))
                        .padding(.horizontal, 10)
                    
                    SecureField("Passwort wiederholen", text: $confirmPassword)
                        .onChange(of: confirmPassword) { newValue in
                            confirmPasswordError = newValue == newPassword ? nil : "Passwörter stimmen nicht überein."
                        }
                        .padding(10)
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                    if let error = confirmPasswordError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // Erfolgsmeldung
                if let successMessage = successMessage {
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
                        .background(isLoading ? Color.gray : Color.accentColor)
                        .foregroundColor(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .disabled(isLoading)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("Passwort", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Profil")
                    }
                }
            }
        }
        .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    // MARK: - Passwortvalidierung
    private func validateAndSavePassword() {
        currentPasswordError = nil
        newPasswordError = nil
        confirmPasswordError = nil
        successMessage = nil
        
        print("[DEBUG] Passwortvalidierung gestartet.")
        
        var hasError = false
        
        if currentPassword.isEmpty {
            currentPasswordError = "Bitte aktuelles Passwort eingeben."
            print("[DEBUG] Aktuelles Passwort fehlt.")
            hasError = true
        }
        
        if newPassword.isEmpty {
            newPasswordError = "Bitte neues Passwort eingeben."
            print("[DEBUG] Neues Passwort fehlt.")
            hasError = true
        } else if !validatePasswordStrength(newPassword) {
            newPasswordError = "Passwort muss mindestens 8 Zeichen lang sein, eine Zahl, ein Sonderzeichen und einen Großbuchstaben enthalten."
            print("[DEBUG] Passwort erfüllt nicht die Sicherheitsanforderungen.")
            hasError = true
        }
        
        if confirmPassword != newPassword {
            confirmPasswordError = "Passwörter stimmen nicht überein."
            print("[DEBUG] Passwörter stimmen nicht überein.")
            hasError = true
        }
        
        if hasError {
            return
        }
        
        // API um aktuelles Passwort zu validieren und neues zu speichern
        saveNewPassword()
    }
    
    private func validatePasswordStrength(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,}$"
        let isValid = NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
        print("[DEBUG] Passwortstärke überprüft: \(isValid)")
        return isValid
    }
    
    // MARK: - Passwort speichern
    // MARK: - Passwort speichern
    private func saveNewPassword() {
        isLoading = true
        currentPasswordError = nil
        newPasswordError = nil
        confirmPasswordError = nil
        successMessage = nil

        print("[DEBUG] API-Aufruf zur Passwortänderung gestartet.")

        MainPageAPI.updatePassword(currentPassword: currentPassword, newPassword: newPassword) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    successMessage = "Passwort wurde erfolgreich geändert."
                    print("[DEBUG] Passwort erfolgreich geändert.")

                    // Neues Passwort in Keychain speichern
                    KeychainHelper.save(key: "password", value: newPassword)

                    // Überprüfen, ob das Passwort korrekt gespeichert wurde
                    if let savedPassword = KeychainHelper.load(key: "password") {
                        if savedPassword == newPassword {
                            print("[DEBUG] Neues Passwort erfolgreich in der Keychain aktualisiert: \(savedPassword)")
                        } else {
                            print("[DEBUG] Fehler: Gespeichertes Passwort stimmt nicht mit dem neuen überein.")
                        }
                    } else {
                        print("[DEBUG] Fehler: Passwort konnte nicht aus der Keychain geladen werden.")
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        presentationMode.wrappedValue.dismiss()
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .unauthorized:
                            currentPasswordError = "Falsches aktuelles Passwort."
                            print("[DEBUG] API-Fehler: Falsches Passwort.")
                        case .badRequest:
                            newPasswordError = "Ungültige Eingabe. Bitte überprüfe die Daten."
                            print("[DEBUG] API-Fehler: Ungültige Eingabe.")
                        default:
                            currentPasswordError = "Ein unbekannter Fehler ist aufgetreten."
                            print("[DEBUG] API-Fehler: Unbekannt.")
                        }
                    } else {
                        currentPasswordError = error.localizedDescription
                        print("[DEBUG] Fehler: \(error.localizedDescription)")
                    }
                }
            }
        }
    }


    struct MainPage_ProfilView_Password_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                MainPage_ProfilView_Password()
            }
        }
    }
}

enum APIError: Error {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case unauthorized
    case badRequest
    case unknown
}

