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
                .fixedSize(horizontal: false, vertical: true) // Zeilenumbruch aktivieren
                .frame(maxWidth: .infinity) // Maximale Breite erlauben
                .padding(.horizontal, 40)

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
                    .fixedSize(horizontal: false, vertical: true) // Zeilenumbruch erlauben
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)

                Spacer()

                // Ladeindikator oder Fehlermeldung
                if isLoading {
                    ProgressView("Überprüfung...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .fixedSize(horizontal: false, vertical: true)
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

    // MARK: - API-Logik

    private func checkVerificationStatus() {
        isLoading = true
        errorMessage = nil

        // Überprüft Email-Status
        checkEmailVerification { emailVerified in
            if emailVerified {
                // Wenn Email verifiziert, dann Benutzeraufnahme prüfen
                checkUserAcceptedStatus { userAccepted in
                    DispatchQueue.main.async {
                        self.isEmailVerified = emailVerified
                        self.isUserAccepted = userAccepted
                        self.isLoading = false

                        if !userAccepted {
                            self.errorMessage = "Warte auf die Bestätigung durch den Organisator."
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isEmailVerified = false
                    self.isLoading = false
                    self.errorMessage = "Bitte überprüfe deine Email und klicke auf den Bestätigungslink."
                }
            }
        }
    }

    private func checkEmailVerification(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/users/email/status") else {
            DispatchQueue.main.async {
                self.errorMessage = "Ungültige URL."
                self.isLoading = false
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fehler beim Überprüfen der Email: \(error)")
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data,
                  let json = try? JSONDecoder().decode([String: Bool].self, from: data),
                  let emailVerified = json["emailVerified"]
            else {
                completion(false)
                return
            }

            completion(emailVerified)
        }.resume()
    }

    private func checkUserAcceptedStatus(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/users/profile") else {
            DispatchQueue.main.async {
                self.errorMessage = "Ungültige URL."
                self.isLoading = false
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fehler beim Überprüfen des Benutzers: \(error)")
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data,
                  let profile = try? JSONDecoder().decode(UserProfileDTO.self, from: data)
            else {
                completion(false)
                return
            }

            completion(profile.isAdmin ?? false)
        }.resume()
    }
}

struct Onboarding_Wait_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_Wait()
    }
}
