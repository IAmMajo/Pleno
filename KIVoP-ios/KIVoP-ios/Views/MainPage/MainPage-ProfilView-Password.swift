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
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }

    // MARK: - Passwort speichern
    private func saveNewPassword() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        MainPageAPI.updatePassword(currentPassword: currentPassword, newPassword: newPassword) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    successMessage = "Passwort wurde erfolgreich geändert."
                case .failure(let error):
                    errorMessage = error.localizedDescription
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
