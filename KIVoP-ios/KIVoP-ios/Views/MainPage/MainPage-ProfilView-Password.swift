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
                                .padding(.top, 5)
                        }
                    }

                    // Neues Passwort Abschnitt
                    VStack(alignment: .leading, spacing: 5) {
                        Text("NEUES PASSWORT")
                            .font(.caption)
                            .foregroundColor(Color.secondary)

                        VStack(spacing: 0) {
                            SecureField("Neues Passwort", text: $newPassword)
                                                       .onChange(of: newPassword) {
                                                           newPasswordError = validatePasswordStrength(newPassword) ? nil : "Passwort muss mindestens 8 Zeichen, eine Zahl und ein Sonderzeichen enthalten."
                                                       }
                                                       .textContentType(.newPassword)

                                .padding(10)
                                .background(Color(UIColor.systemBackground).opacity(0.8))

                            Divider()
                                .frame(height: 0.5)
                                .background(Color.gray.opacity(0.6))

                            SecureField("Passwort wiederholen", text: $confirmPassword)
                                                        .onChange(of: confirmPassword) {
                                                            confirmPasswordError = confirmPassword == newPassword ? nil : "Passwörter stimmen nicht überein."
                                                        }

                                .padding(10)
                                .background(Color(UIColor.systemBackground).opacity(0.8))
                        }
                        .cornerRadius(10)

                        if let error = newPasswordError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
                        }

                        if let error = confirmPasswordError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
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
            return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
        }

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

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    case .failure(let error):
                        if let apiError = error as? APIError {
                            switch apiError {
                            case .unauthorized:
                                currentPasswordError = "Falsches aktuelles Passwort."
                            case .badRequest:
                                newPasswordError = "Ungültige Eingabe. Bitte überprüfe die Daten."
                            default:
                                currentPasswordError = "Ein unbekannter Fehler ist aufgetreten."
                            }
                        } else {
                            currentPasswordError = error.localizedDescription
                        }
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

    enum APIError: Error {
        case invalidURL
        case invalidRequest
        case invalidResponse
        case unauthorized
        case badRequest
        case unknown
    }
