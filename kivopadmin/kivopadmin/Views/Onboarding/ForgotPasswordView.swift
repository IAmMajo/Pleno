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

struct ForgotPasswordView: View {
    // Zustandsvariablen für die Benutzerinteraktion
    @State private var email: String = ""
    @State private var resetCode: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var successMessage: String? = nil
    @State private var errorMessage: String? = nil
    @State private var isCodeSent: Bool = false
    @State private var navigateToMainPage: Bool = false

    // Ermöglicht das Schließen der aktuellen Ansicht
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 40)

                // Titel des Bildschirms (abhängig davon, ob der Code bereits gesendet wurde)
                ZStack(alignment: .bottom) {
                    Text(isCodeSent ? "Passwort ändern" : "Passwort zurücksetzen")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)

                    Rectangle()
                        .frame(width: isCodeSent ? 150 : 200, height: 3)
                        .foregroundColor(.primary)
                        .offset(y: 5)
                }
                .padding(.bottom, 40)
                .padding(.top, 40)

                if !isCodeSent {
                    // Eingabefeld für die E-Mail-Adresse
                    inputField(title: "E-Mail", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    // Eingabefelder für den Reset-Code und das neue Passwort
                    inputField(title: "Reset-Code", text: $resetCode)
                        .textContentType(.oneTimeCode)
                        .keyboardType(.numberPad)
                        .onChange(of: resetCode) {
                            successMessage = nil // Erfolgsnachricht entfernen, wenn der Nutzer eine Eingabe macht
                        }

                    inputField(title: "Neues Passwort", text: $newPassword, isSecure: true)
                        .textContentType(.newPassword)
                        .onChange(of: newPassword) {
                            errorMessage = nil // Fehlermeldung entfernen, wenn das Passwort geändert wird
                        }

                    inputField(title: "Passwort bestätigen", text: $confirmPassword, isSecure: true)
                        .onChange(of: confirmPassword) {
                            errorMessage = nil // Fehlermeldung entfernen, wenn das Bestätigungspasswort geändert wird
                        }

                    // Prüft, ob das Passwort sicher genug ist
                    if !newPassword.isEmpty && confirmPassword.isEmpty {
                        if !isPasswordStrong(newPassword) {
                            Text("Das Passwort ist zu schwach. Bitte verwenden Sie mindestens 8 Zeichen, eine Zahl und ein Sonderzeichen.")
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.horizontal, 24)
                        }
                    } else if !confirmPassword.isEmpty {
                        if newPassword != confirmPassword {
                            Text("Die Passwörter stimmen nicht überein.")
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.horizontal, 24)
                        }
                    }
                }

                // Anzeige von Fehlermeldungen oder Erfolgsmeldungen
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal, 24)
                } else if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.footnote)
                        .padding(.horizontal, 24)
                }

                Spacer()

                // Button zum Absenden des Formulars (je nach Zustand wird entweder eine E-Mail gesendet oder das Passwort geändert)
                Button(action: {
                    if isCodeSent {
                        validateAndResetPassword()
                    } else {
                        OnboardingAPI.sendResetCode(email: email) { result in
                            handleAPIResponse(result) { _ in
                                isCodeSent = true
                                successMessage = "Ein Reset-Code wurde an Ihre E-Mail gesendet."
                            }
                        }
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text(isCodeSent ? "Passwort ändern" : "E-Mail senden")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .disabled(isLoading || (isCodeSent ? (resetCode.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || !isPasswordStrong(newPassword)) : email.isEmpty))

                // Button zum Zurückkehren zur vorherigen Ansicht
                Button(action: {
                    dismiss()
                }) {
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
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $navigateToMainPage) {
                MainPage()
            }
        }
    }

    // MARK: - Passwortänderung validieren und durchführen
    private func validateAndResetPassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "Die Passwörter stimmen nicht überein."
            return
        }

        isLoading = true
        OnboardingAPI.resetPassword(email: email, resetCode: resetCode, newPassword: newPassword) { result in
            handleAPIResponse(result) { _ in
                successMessage = "Ihr Passwort wurde erfolgreich geändert."
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    navigateToMainPage = true
                }
            }
        }
    }

    // MARK: - Prüft, ob das Passwort den Sicherheitsanforderungen entspricht
    private func isPasswordStrong(_ password: String) -> Bool {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

    // MARK: - Handhabt API-Antworten und setzt Erfolg- oder Fehlermeldungen
    private func handleAPIResponse<T>(_ result: Result<T, Error>, onSuccess: @escaping (T) -> Void) {
        DispatchQueue.main.async {
            isLoading = false
            switch result {
            case .success(let response):
                onSuccess(response)
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Eingabefeld für E-Mail, Code oder Passwort
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

// MARK: - Vorschau für verschiedene Farbmodi
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
            .environment(\.colorScheme, .light)
        ForgotPasswordView()
            .environment(\.colorScheme, .dark)
    }
}
