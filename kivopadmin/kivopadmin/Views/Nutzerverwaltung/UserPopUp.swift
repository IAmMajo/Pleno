import SwiftUI
import AuthServiceDTOs

struct UserPopupView: View {
    @Binding var user: UserProfileDTO
    @Binding var isPresented: Bool
    var onSave: () -> Void // Callback für die NutzerverwaltungsView

    @State private var tempIsAdmin: Bool = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var editedName = ""
    @State private var isDeletingAccount = false
    
    // Lokale Kopie des Profilbilds, um direkte UI-Aktualisierungen zu steuern
    @State private var profileImageData: Data?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Profilbild
                VStack {
                    if let imageData = profileImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(
                                Button(action: deleteProfilePicture) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .padding(8)
                                        .background(Circle().fill(Color.white))
                                }
                                .offset(x: 40, y: 40)
                            )
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 110, height: 110)
                            .overlay(
                                Text(MainPageAPI.calculateInitials(from: user.name))
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            )
                    }
                }

                // Benutzername bearbeiten
                VStack {
                    HStack {
                        Text("Benutzername:")
                        Spacer()
                    }
                    TextField("Neuen Namen eingeben", text: $editedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                Divider()

                // E-Mail-Adresse
                HStack {
                    Text("E-Mail:")
                    Spacer()
                    Text(user.email ?? "Keine E-Mail").foregroundColor(.gray)
                }
                Divider()

                // Admin-Status Toggle
                HStack {
                    Text("Admin:")
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Toggle("", isOn: $tempIsAdmin)
                            .labelsHidden()
                    }
                }
                Divider()

                Spacer()

                // Fehleranzeige
                if showError {
                    Text("Fehler beim Speichern der Änderungen.")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                // Speichern-Button
                Button(action: saveChanges) {
                    Text("Speichern")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(isLoading)

                // Konto löschen Button
                Button("Konto löschen") {
                    isDeletingAccount = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                .alert("Konto löschen", isPresented: $isDeletingAccount) {
                    Button("Abbrechen", role: .cancel) {}
                    Button("Löschen", role: .destructive) {
                        deleteAccount()
                    }
                } message: {
                    Text("Möchten Sie dieses Konto wirklich löschen?")
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        isPresented = false
                    }
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                debugPrint("🟢 Popup geöffnet")
                loadInitialData()
            }
            .alert("Fehler", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut.")
            }
        }
    }

    // MARK: - Funktionen

    private func loadInitialData() {
        debugPrint("🔄 Benutzerprofil wird geladen...")
        editedName = user.name ?? ""
        tempIsAdmin = user.isAdmin ?? false
        profileImageData = user.profileImage // Lokale Kopie des Profilbilds
    }

    private func saveChanges() {
        guard let userId = user.uid?.uuidString else {
            debugPrint("❌ Fehler: Benutzer-ID ungültig.")
            showError = true
            return
        }

        isLoading = true
        showError = false

        let dispatchGroup = DispatchGroup()

        // Benutzername und Profilbild aktualisieren
        if editedName != user.name || profileImageData == nil {
            dispatchGroup.enter()
            MainPageAPI.updateUserProfile(userId: userId, name: editedName, profileImage: profileImageData == nil ? nil : String(data: profileImageData!, encoding: .utf8)) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        debugPrint("✅ Benutzerprofil erfolgreich aktualisiert.")
                        onSave() // Callback aufrufen, um die Nutzerliste neu zu laden
                    case .failure(let error):
                        debugPrint("❌ Fehler beim Aktualisieren des Profils: \(error.localizedDescription)")
                        self.showError = true
                    }
                    dispatchGroup.leave()
                }
            }
        }

        // Admin-Status aktualisieren
        if tempIsAdmin != (user.isAdmin ?? false) {
            dispatchGroup.enter()
            MainPageAPI.updateAdminStatus(userId: userId, isAdmin: tempIsAdmin, isActive: user.isActive ?? true) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        debugPrint("✅ Admin-Status erfolgreich aktualisiert.")
                    case .failure(let error):
                        debugPrint("❌ Fehler beim Aktualisieren des Admin-Status: \(error.localizedDescription)")
                        self.showError = true
                    }
                    dispatchGroup.leave()
                }
            }
        }

        // Alle Änderungen speichern und Popup schließen
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
            if !self.showError {
                debugPrint("✅ Alle Änderungen erfolgreich gespeichert. Popup wird geschlossen.")
                self.isPresented = false
            }
        }
    }

    private func deleteAccount() {
        guard let userId = user.uid?.uuidString else {
            debugPrint("❌ Fehler: Benutzer-ID ungültig.")
            showError = true
            return
        }

        debugPrint("➡️ Sende Löschanfrage für Benutzer: \(userId)")
        MainPageAPI.deleteUser(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    debugPrint("✅ Benutzer erfolgreich gelöscht.")
                    isPresented = false
                case .failure(let error):
                    debugPrint("❌ Fehler beim Löschen des Kontos: \(error.localizedDescription)")
                    showError = true
                }
            }
        }
    }

    private func deleteProfilePicture() {
        guard let userId = user.uid?.uuidString else {
            debugPrint("❌ Fehler: Benutzer-ID ungültig.")
            showError = true
            return
        }

        profileImageData = nil // Sofortiges UI-Update

        MainPageAPI.deleteProfilePicture(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    debugPrint("✅ Profilbild erfolgreich gelöscht.")
                    user.profileImage = nil
                case .failure(let error):
                    debugPrint("❌ Fehler beim Löschen des Profilbilds: \(error.localizedDescription)")
                    showError = true
                    profileImageData = user.profileImage // Rollback bei Fehler
                }
            }
        }
    }
}
