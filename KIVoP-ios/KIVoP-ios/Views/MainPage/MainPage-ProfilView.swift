// This file is licensed under the MIT-0 License.

import SwiftUI

struct MainPage_ProfilView: View {
    @StateObject private var viewModel = MainPageProfilViewModel() // ViewModel zur Verwaltung der Profildaten

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer().frame(height: 10)

                clubInfoSection // Zeigt Vereinsinformationen an
                profileImageSection // Zeigt Profilbild oder Initialen an
                userInfoSection // Zeigt Benutzerinformationen (Name, Passwort ändern) an
                actionButtons // Enthält Buttons zum Abmelden und Account-Löschen

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitle(viewModel.name.isEmpty ? "Profil" : viewModel.name, displayMode: .inline)
            .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(isPresented: $viewModel.navigateToLogin) {
                Onboarding_Login() // Navigiert nach dem Logout zum Login-Bildschirm
            }
            .onAppear {
                viewModel.loadUserProfile() // Lädt das Benutzerprofil beim Öffnen der Seite
            }
        }
    }

    // MARK: - Vereinsinformationen anzeigen
    private var clubInfoSection: some View {
        VStack {
            // Kreis für das Vereinslogo oder Kürzel
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(Text(viewModel.clubShortName).font(.title).foregroundColor(.white))

            // Vereinsname
            Text(viewModel.clubName)
                .font(.subheadline)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top, 5)

            Divider()
                .padding(.vertical, 10)
        }
        .padding(.horizontal)
    }

    // MARK: - Profilbild oder Initialen anzeigen
    private var profileImageSection: some View {
        VStack {
            // Zeigt entweder das Profilbild oder einen Platzhalter mit Initialen
            if let profileImage = viewModel.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(Text(viewModel.shortName).font(.title).foregroundColor(.white))
            }

            // Button zur Bearbeitung des Profilbildes
            NavigationLink(destination: MainPage_ProfilView_ProfilPicture()) {
                Text("Bearbeiten")
                    .font(.footnote)
                    .foregroundColor(.accentColor)
            }
        }
    }

    // MARK: - Benutzerinformationen anzeigen
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Navigation zur Namensänderung
            NavigationLink(destination: MainPage_ProfilView_Name()) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(viewModel.name.isEmpty ? "Lade Benutzername..." : viewModel.name)
                        .foregroundColor(Color.secondary)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground).opacity(0.8))
            .cornerRadius(10)

            // Passwort ändern Abschnitt
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
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }

    // MARK: - Aktionen für Abmelden und Account löschen
    private var actionButtons: some View {
        VStack {
            // Abmelden-Button mit Bestätigungsdialog
            Button(action: {
                viewModel.showSignOutConfirmation = true
            }) {
                Text("Abmelden")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(10)
            }
            .confirmationDialog("Wirklich abmelden?", isPresented: $viewModel.showSignOutConfirmation, titleVisibility: .visible) {
                Button("Abmelden", role: .destructive) {
                    viewModel.signOut()
                }
                Button("Abbrechen", role: .cancel) {}
            }

            Spacer().frame(height: 10)

            // Account löschen-Button mit Warnmeldung
            Button(action: {
                viewModel.showDeleteAccountAlert = true
            }) {
                Text("Account löschen")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .alert("Möchtest du deinen Account wirklich löschen?", isPresented: $viewModel.showDeleteAccountAlert) {
                Button("Abbrechen", role: .cancel) {}
                Button("Löschen", role: .destructive) {
                    viewModel.deleteAccount()
                }
            } message: {
                Text("Du kannst deine Wahl danach nicht mehr ändern!")
            }
        }
        .padding(.horizontal)
    }
}
