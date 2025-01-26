import SwiftUI
import AuthServiceDTOs

struct MainPage_ProfilView: View {
    // Benutzerinformationen
    @State private var name: String = ""
    @State private var shortName: String = "??"
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
                Spacer().frame(height: 10)

                // Vereinslogo und Name
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
                    NavigationLink(destination: MainPage_ProfilView_Name()) {
                        HStack {
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
                            MainPageAPI.logoutUser()
                            navigateToLogin = true
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
                            MainPageAPI.deleteUserAccount { result in
                                DispatchQueue.main.async {
                                    if case .success = result {
                                        KeychainHelper.delete(key: "username")
                                        KeychainHelper.delete(key: "password")
                                        MainPageAPI.logoutUser()
                                        navigateToLogin = true
                                    } else if case .failure(let error) = result {
                                        errorMessage = "Fehler: \(error.localizedDescription)"
                                    }
                                }
                            }
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
                loadUserProfile()
            }
        }
    }

    // MARK: - Daten laden
    func loadUserProfile() {
        MainPageAPI.fetchUserProfile { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let profile):
                    self.name = profile.name
                    self.shortName = MainPageAPI.calculateShortName(from: profile.name)
                    if let imageData = profile.profileImage {
                        self.profileImage = UIImage(data: imageData)
                    } else {
                        self.profileImage = nil
                    }

                case .failure(let error):
                    self.errorMessage = "Fehler: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct MainPage_ProfilView_Previews: PreviewProvider {
    static var previews: some View {
        MainPage_ProfilView()
    }
}
