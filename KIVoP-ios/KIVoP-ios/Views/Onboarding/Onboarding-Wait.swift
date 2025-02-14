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

struct Onboarding_Wait: View {
    @Binding var email: String // Email wird übergeben
    @State private var clubName: String = "Name des Vereins der manchmal auch sehr lange werden kann e.V."
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var navigateToMainPage: Bool = false
    @State private var resendTimer: Int = 30 // Countdown-Timer
    @State private var canResendEmail: Bool = false // Steuerung des Buttons

    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(spacing: 20) {
                    // Title
                    ZStack(alignment: .bottom) {
                        Text("Fast Fertig")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                        
                        Rectangle()
                            .frame(width: 103, height: 3)
                            .foregroundColor(.primary)
                            .offset(y: 5)
                    }
                    
                    // Vereinslogo Placeholder
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .overlay(
                            Text("Vereinslogo")
                                .foregroundColor(.gray)
                        )
                        .padding(.vertical, 20)
                    
                    // Vereinsname
                    Text(clubName)
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Beschreibung
                    descriptionText
                    
                    // Fehlermeldung
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // Ladeindikator
                    if isLoading {
                        ProgressView("Anmeldung wird überprüft...")
                            .padding()
                    }
                    
                    Spacer(minLength: 150)
                    
                    // Button für E-Mail erneut senden
                    if !canResendEmail {
                        Text("E-Mail erneut senden (\(resendTimer)s)")
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .padding(.top, 10)
                    } else {
                        Button(action: resendVerificationEmail) {
                            Text("E-Mail erneut senden")
                                .foregroundColor(.blue)
                                .font(.footnote)
                                .underline()
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .refreshable {
                    loginAttempt()
                }
                .navigationBarBackButtonHidden()
                .onAppear {
                    startResendTimer()
                }
                .navigationDestination(isPresented: $navigateToMainPage) {
                    MainPage()
                }
            }
            .background(Color(UIColor.systemGray6))
            .refreshable {
                loginAttempt()
            }

        }
    }

    private var descriptionText: some View {
        VStack(alignment: .center, spacing: 24) {
            Text("Bitte klicke nun auf den ")
                .font(.system(size: 24))
                .fontWeight(.semibold)
            + Text("Link")
                .foregroundColor(.blue)
                .font(.system(size: 24))
                .fontWeight(.semibold)
            + Text(" in der Bestätigungs-Mail.")
                .fontWeight(.semibold)
                .font(.system(size: 24))

            Text("Anschließend kann der ")
                .font(.system(size: 24))
                .fontWeight(.semibold)
            + Text("Organisator")
                .foregroundColor(.blue)
                .font(.system(size: 24))
                .fontWeight(.semibold)
            + Text(" deines Vereins dich aufnehmen.")
                .fontWeight(.semibold)
                .font(.system(size: 24))

        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }

    private func loginAttempt() {
        isLoading = true
        errorMessage = nil

        guard let password = KeychainHelper.load(key: "password") else {
            errorMessage = "Passwort nicht gefunden. Bitte erneut einloggen."
            isLoading = false
            return
        }

        let loginDTO = UserLoginDTO(email: email, password: password)
        OnboardingAPI.loginUser(with: loginDTO) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let token):
                    // Token speichern
                    UserDefaults.standard.set(token, forKey: "jwtToken")
                    print("JWT-Token gespeichert: \(token)")
                    navigateToMainPage = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }


    private func resendVerificationEmail() {
        isLoading = true

        OnboardingAPI.resendVerificationEmail(email: email) { result in
            DispatchQueue.main.async {
                isLoading = false
                if case .success = result {
                    startResendTimer()
                } else if case .failure(let error) = result {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func startResendTimer() {
        resendTimer = 30
        canResendEmail = false
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if resendTimer > 0 {
                resendTimer -= 1
            } else {
                timer.invalidate()
                canResendEmail = true
            }
        }
    }
}

struct Onboarding_Wait_Previews: PreviewProvider {
    @State static var testEmail: String = "test@example.com"

    static var previews: some View {
        Onboarding_Wait(email: $testEmail)
    }
}
