import SwiftUI
import AuthServiceDTOs

struct Onboarding_Wait: View {
    @State private var clubName: String = "Name des Vereins der manchmal auch sehr lange werden kann e.V."
    @State private var isEmailVerified: Bool = false
    @State private var isUserAccepted: Bool = false
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @State private var navigateToMainPage: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)

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
                .padding(.bottom, 40)
                .padding(.top, 40)

                // Description Text
                descriptionText

                Spacer()

                // Vereinslogo Placeholder
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
                    .overlay(
                        Text("Vereinslogo")
                            .foregroundColor(.gray)
                    )
                    .padding(.bottom, 20)
                    .padding(.top, 60)

                // Vereinsname
                Text(clubName)
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)

                // Fehlermeldung
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                }

                Spacer()

                // Ladeindikator
                if isLoading {
                    ProgressView("Überprüfung...")
                        .padding()
                } else if isEmailVerified && isUserAccepted {
                    // Navigation zu MainPage bei Erfolg
                    EmptyView()
                        .onAppear {
                            navigateToMainPage = true
                        }
                }
            }
            .background(Color(UIColor.systemGray6))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                checkVerificationStatus()
            }
            // Navigation zu MainPage
            .navigationDestination(isPresented: $navigateToMainPage) {
                MainPage()
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
            
            Text("Sobald dies geschehen ist, erhältst du eine ")
                .font(.system(size: 24))
                .fontWeight(.semibold)
            + Text(" Mitteilung.")
                .foregroundColor(.blue)
                .font(.system(size: 24))
                .fontWeight(.semibold)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }

    private func checkVerificationStatus() {
        isLoading = true
        errorMessage = nil

        OnboardingAPI.checkEmailVerification { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let emailVerified):
                    self.isEmailVerified = emailVerified
                    if emailVerified {
                        OnboardingAPI.checkUserAcceptedStatus { userResult in
                            DispatchQueue.main.async {
                                self.isLoading = false
                                switch userResult {
                                case .success(let userAccepted):
                                    self.isUserAccepted = userAccepted
                                    if !userAccepted {
                                        self.errorMessage = "Warte auf die Bestätigung durch den Organisator."
                                    }
                                case .failure(let error):
                                    self.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    } else {
                        self.isLoading = false
                        self.errorMessage = "Bitte überprüfe deine Email und klicke auf den Bestätigungslink."
                    }
                case .failure(let error):
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}


struct Onboarding_Wait_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_Wait()
    }
}
