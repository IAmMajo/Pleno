import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var resetCode: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var successMessage: String? = nil
    @State private var errorMessage: String? = nil
    @State private var isCodeSent: Bool = false
    @State private var navigateToMainPage: Bool = false


    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 40)

                // Title
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
                    // Email TextField
                    inputField(title: "E-Mail", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    // Reset Code TextField
                    inputField(title: "Reset-Code", text: $resetCode)
                                    .keyboardType(.numberPad)
                                    .onChange(of: resetCode) {
                                        successMessage = nil // Entferne die grüne Nachricht, sobald ein Code eingegeben wird
                                    }

                                // Neues Passwort TextField
                                inputField(title: "Neues Passwort", text: $newPassword, isSecure: true)
                                    .onChange(of: newPassword) {
                                        errorMessage = nil // Entferne Fehlernachrichten bei Passwortänderung
                                    }

                                // Passwort bestätigen TextField
                                inputField(title: "Passwort bestätigen", text: $confirmPassword, isSecure: true)
                                    .onChange(of: confirmPassword) {
                                        errorMessage = nil // Entferne Fehlernachrichten bei Bestätigung
                                    }
                    // Password Strength Check
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

                // Error or Success Message
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

                // Submit Button
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

                // Back Button
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

    private func isPasswordStrong(_ password: String) -> Bool {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

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



struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
            .environment(\.colorScheme, .light)
        ForgotPasswordView()
            .environment(\.colorScheme, .dark)
    }
}
