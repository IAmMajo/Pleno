import SwiftUI
import AuthServiceDTOs

struct UserPopupView: View {
    @Binding var user: UserProfileDTO
    @Binding var isPresented: Bool

    @State private var tempIsAdmin: Bool = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var isDeletingProfilePicture = false
    @State private var isDeletingAccount = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Profilbild
                VStack {
                    if let imageData = user.profileImage, let uiImage = UIImage(data: imageData) {
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
                if isEditingName {
                    VStack(spacing: 10) {
                        TextField("Neuen Namen eingeben", text: $editedName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        HStack {
                            Button("Abbrechen") {
                                isEditingName = false
                            }
                            .foregroundColor(.red)

                            Spacer()

                            Button("Speichern") {
                                updateUserName()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    HStack {
                        Text("Benutzername:")
                        Spacer()
                        Text(user.name ?? "Unbekannt").foregroundColor(.gray)
                        Button(action: {
                            editedName = user.name ?? ""
                            isEditingName = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    Divider()
                }

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
        MainPageAPI.fetchUserByID(userID: user.uid ?? UUID()) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUser):
                    self.user = fetchedUser
                    self.tempIsAdmin = fetchedUser.isAdmin ?? false
                    debugPrint("✅ Benutzerprofil geladen: \(fetchedUser)")
                case .failure(let error):
                    debugPrint("❌ Fehler beim Laden des Benutzerprofils: \(error.localizedDescription)")
                    self.showError = true
                }
            }
        }
    }

    private func saveChanges() {
        guard let userId = user.uid?.uuidString else {
            debugPrint("❌ Fehler: Benutzer-ID ungültig.")
            showError = true
            return
        }

        isLoading = true
        showError = false

        MainPageAPI.updateAdminStatus(userId: userId, isAdmin: tempIsAdmin, isActive: user.isActive ?? true) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    debugPrint("✅ Admin-Status erfolgreich aktualisiert auf \(self.tempIsAdmin).")
                    self.loadUserAndClosePopup(userId: userId)
                case .failure(let error):
                    debugPrint("❌ Fehler beim Aktualisieren: \(error.localizedDescription)")
                    self.showError = true
                    self.tempIsAdmin = self.user.isAdmin ?? false
                }
            }
        }
    }

    private func loadUserAndClosePopup(userId: String) {
        MainPageAPI.fetchUserByID(userID: UUID(uuidString: userId) ?? UUID()) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUser):
                    self.user = fetchedUser
                    debugPrint("✅ Profil erfolgreich neu geladen. Popup wird geschlossen.")
                    self.isPresented = false
                case .failure(let error):
                    debugPrint("❌ Fehler beim Neuladen des Profils: \(error.localizedDescription)")
                    self.showError = true
                }
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
        MainPageAPI.deleteProfilePicture { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    debugPrint("✅ Profilbild erfolgreich gelöscht.")
                    user.profileImage = nil
                case .failure(let error):
                    debugPrint("❌ Fehler beim Löschen des Profilbilds: \(error.localizedDescription)")
                    showError = true
                }
            }
        }
    }

    private func updateUserName() {
        MainPageAPI.updateUserName(name: editedName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    debugPrint("✅ Benutzername erfolgreich aktualisiert auf \(editedName).")
                    user.name = editedName
                    isEditingName = false
                case .failure(let error):
                    debugPrint("❌ Fehler beim Aktualisieren des Benutzernamens: \(error.localizedDescription)")
                    showError = true
                }
            }
        }
    }
}
