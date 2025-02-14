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
import AuthServiceDTOs

class MainPageProfilPasswordViewModel: ObservableObject {
    // Passwort-Felder
    @Published var currentPassword: String = ""
    @Published var newPassword: String = "" {
        didSet { validateNewPassword() }
    }
    @Published var confirmPassword: String = "" {
        didSet {
            if !confirmPassword.isEmpty { validateConfirmPassword() }
        }
    }

    // UI-Zustände
    @Published var isLoading: Bool = false
    @Published var currentPasswordError: String? = nil
    @Published var newPasswordError: String? = nil
    @Published var confirmPasswordError: String? = nil
    @Published var successMessage: String? = nil
    @Published var shouldDismiss: Bool = false

    // NICHT mehr private, damit die View sie aufrufen kann
    func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            confirmPasswordError = nil // Fehlermeldung nur setzen, wenn etwas eingegeben wurde
        } else {
            confirmPasswordError = (confirmPassword == newPassword) ? nil : "Passwörter stimmen nicht überein."
        }
    }

    // Live-Validierung der Passwörter
    func validateNewPassword() {
        if newPassword.isEmpty {
            newPasswordError = nil
        } else if !validatePasswordStrength(newPassword) {
            newPasswordError = "Passwort muss mindestens 8 Zeichen, eine Zahl, ein Sonderzeichen und einen Großbuchstaben enthalten."
        } else {
            newPasswordError = nil
        }
        validateConfirmPassword() // Falls beide Felder gefüllt sind, erneut prüfen
    }

    // MARK: - Passwortvalidierung beim Speichern
    func validateAndSavePassword() {
        currentPasswordError = nil
        successMessage = nil

        var hasError = false

        if currentPassword.isEmpty {
            currentPasswordError = "Bitte aktuelles Passwort eingeben."
            hasError = true
        }

        validateNewPassword()
        validateConfirmPassword()

        if newPasswordError != nil || confirmPasswordError != nil {
            hasError = true
        }

        if hasError { return }

        // API-Aufruf zur Passwortänderung
        saveNewPassword()
    }

    // Überprüft, ob das Passwort stark genug ist
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

        MainPageAPI.updatePassword(currentPassword: currentPassword, newPassword: newPassword) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.successMessage = "Passwort wurde erfolgreich geändert."

                    // Neues Passwort in Keychain speichern
                    KeychainHelper.save(key: "password", value: self.newPassword)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.shouldDismiss = true
                    }
                case .failure(let error):
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .unauthorized:
                            self.currentPasswordError = "Falsches aktuelles Passwort."
                        case .badRequest:
                            self.newPasswordError = "Ungültige Eingabe. Bitte überprüfe die Daten."
                        default:
                            self.currentPasswordError = "Ein unbekannter Fehler ist aufgetreten."
                        }
                    } else {
                        self.currentPasswordError = error.localizedDescription
                    }
                }
            }
        }
    }
}

// API-Fehlertypen definieren
enum APIError: Error {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case unauthorized
    case badRequest
    case unknown
}
