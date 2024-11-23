import SwiftUI
import AuthServiceDTOs

struct MainPage_ProfilView: View {
    // Benutzerinformationen (dynamisch geladen)
    @State private var name: String = ""
    @State private var shortName: String = "MM"
    @State private var profileImage: UIImage? = nil
    
    // Vereinsinformationen (gehardcoded)
    private let clubName: String = "Name des Vereins der manchmal auch sehr lange werden kann e.V."
    private let clubShortName: String = "VL"
    
    // UI-Zustände
    @State private var showSignOutConfirmation = false
    @State private var showDeleteAccountAlert = false
    @State private var navigateToLogin = false
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 10)

                // Vereinslogo und Vereinsname (festgelegt)
                VStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(Text(clubShortName).font(.title).foregroundColor(.white))

                    Text(clubName)
                        .font(.subheadline)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)

                    Divider()
                        .padding(.vertical, 10)
                }
                .padding(.horizontal)

                // Profilbild oder ShortName anzeigen
                VStack {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(Text(shortName).font(.title).foregroundColor(.white))
                    }

                    NavigationLink(destination: MainPage_ProfilView_ProfilPicture()) {
                        Text("Bearbeiten")
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    }
                }

                // Benutzerinformationen
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        NavigationLink(destination: MainPage_ProfilView_Name()) {
                            Text("Name")
                            Spacer()
                            Text(name.isEmpty ? "Lade Benutzername..." : name)
                                .foregroundColor(Color.secondary)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(10)

                    Text("PASSWORT")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                        .padding(.top, 10)

                    NavigationLink(destination: MainPage_ProfilView_Password()) {
                        HStack {
                            Text("Passwort ändern")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.secondary)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                    }

                    Text("AKTIONEN")
                        .font(.footnote)
                        .foregroundColor(Color.secondary)
                        .padding(.top, 20)

                    // Abmelden-Button
                    Button(action: {
                        showSignOutConfirmation = true
                    }) {
                        Text("Abmelden")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(15)
                            .background(Color(UIColor.systemBackground).opacity(0.8))
                            .cornerRadius(10)
                    }
                    .confirmationDialog("Wirklich abmelden?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
                        Button("Abmelden", role: .destructive) {
                            logoutUser()
                        }
                        Button("Abbrechen", role: .cancel) {}
                    }

                    Spacer().frame(height: 10)

                    // Account löschen-Button
                    Button(action: {
                        showDeleteAccountAlert = true
                    }) {
                        Text("Account löschen")
                            .frame(maxWidth: .infinity)
                            .padding(15)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .alert("Möchtest du deinen Account wirklich löschen?", isPresented: $showDeleteAccountAlert) {
                        Button("Abbrechen", role: .cancel) {}
                        Button("Löschen", role: .destructive) {
                            deleteAccount()
                        }
                    } message: {
                        Text("Du kannst deine Wahl danach nicht mehr ändern!")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitle(name.isEmpty ? "Profil" : name, displayMode: .inline)
            .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(isPresented: $navigateToLogin) {
                Onboarding_Login()
            }
            .onAppear {
                fetchUserProfile()
            }
        }
    }

    // MARK: - API-Logik

    private func fetchUserProfile() {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "https://kivop.ipv64.net/users/profile") else {
            errorMessage = "Ungültige URL."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "Fehler: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                      let data = data else {
                    errorMessage = "Profil konnte nicht geladen werden."
                    return
                }

                do {
                    let profile = try JSONDecoder().decode(UserProfileDTO.self, from: data)
                    self.name = profile.name ?? ""
                    self.shortName = calculateShortName(from: profile.name ?? "")
                } catch {
                    errorMessage = "Fehler beim Verarbeiten der Daten."
                }
            }
        }.resume()
    }

    private func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "jwtToken")
        navigateToLogin = true
    }

    private func deleteAccount() {
        guard let url = URL(string: "https://kivop.ipv64.net/users") else {
            errorMessage = "Ungültige URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Fehler beim Löschen des Kontos: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    errorMessage = "Konto konnte nicht gelöscht werden."
                    return
                }

                logoutUser()
            }
        }.resume()
    }

    // MARK: - Hilfsfunktionen

    private func calculateShortName(from fullName: String) -> String {
        let nameParts = fullName.split(separator: " ")
        guard let firstInitial = nameParts.first?.prefix(1),
              let lastInitial = nameParts.last?.prefix(1) else {
            return "??"
        }
        return "\(firstInitial)\(lastInitial)".uppercased()
    }
}

struct MainPage_ProfilView_Previews: PreviewProvider {
    static var previews: some View {
        MainPage_ProfilView()
    }
}
