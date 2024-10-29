import SwiftUI

struct MainPage_ProfilView: View {
    @State private var name: String = "Max Mustermann"
    @State private var ShortName: String = "MM"
    @State private var clubName: String = "Name des Vereins der manchmal auch sehr lange werden kann e.V."
    @State private var clubShortName: String = "VL"
    @State private var showSignOutConfirmation = false
    @State private var showDeleteAccountAlert = false
    @State private var navigateToLogin = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 10)
                
                // Vereinslogo und Vereinsname
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

                // Profilbild und Bearbeiten-Option
                VStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(Text(ShortName).font(.title).foregroundColor(.white))

                    NavigationLink(destination: MainPage_ProfilView_ProfilPicture()) {
                        Text("Bearbeiten")
                            .font(.footnote)
                            .foregroundColor(.accentColor) // Dynamische Farbe für Dark Mode
                    }
                }

                // Benutzerinformationen
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        NavigationLink(destination: MainPage_ProfilView_Name()) {
                            Text("Name")
                            Spacer()
                            Text(name)
                                .foregroundColor(Color.secondary) // Dynamische Farbe
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.8)) // Passt sich dem Modus an
                    .cornerRadius(10)

                    // Überschrift für Passwort
                    Text("PASSWORT")
                        .font(.footnote)
                        .foregroundColor(Color.secondary) // Dynamische Farbe
                        .padding(.top, 10)

                    NavigationLink(destination: MainPage_ProfilView_Password()) {
                        HStack {
                            Text("Passwort ändern")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.secondary) // Dynamische Farbe
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground).opacity(0.8)) // Passt sich dem Modus an
                        .cornerRadius(10)
                    }

                    // Überschrift für Aktionen
                    Text("AKTIONEN")
                        .font(.footnote)
                        .foregroundColor(Color.secondary) // Dynamische Farbe
                        .padding(.top, 20)

                    // Abmelden-Button mit Bestätigungsdialog
                    Button(action: {
                        showSignOutConfirmation = true
                    }) {
                        Text("Abmelden")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(15)
                            .background(Color(UIColor.systemBackground).opacity(0.8)) // Passt sich dem Modus an
                            .cornerRadius(10)
                    }
                    .confirmationDialog("Wirklich abmelden?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
                        Button("Abmelden", role: .destructive) {
                            navigateToLogin = true
                        }
                        Button("Abbrechen", role: .cancel) {
                            // Aktion für "Abbrechen"
                        }
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
                        Button("Abbrechen", role: .cancel) { }
                        Button("Löschen", role: .destructive) {
                            // Aktion für "Löschen"
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
            .background(Color(UIColor.systemGroupedBackground)) // Passt sich dem Modus an
            .navigationBarTitle(name, displayMode: .inline)
            .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(isPresented: $navigateToLogin) {
                Onboarding_Login()
            }
        }
    }
}

struct MainPage_ProfilView_Previews: PreviewProvider {
    static var previews: some View {
        MainPage_ProfilView()
    }
}
