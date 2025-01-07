import SwiftUI
import AuthServiceDTOs

struct UserPopupView: View {
    @Binding var user: UserProfileDTO
    @Binding var isPresented: Bool
    
    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var isDeletingProfilePicture = false
    @State private var isDeletingAccount = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Profilbild anzeigen oder bearbeiten
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
                
                // Benutzerinformationen anzeigen
                if isEditingName {
                    TextField("Name eingeben", text: $editedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Speichern") {
                        updateUserName()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    HStack {
                        Text("Name:")
                        Spacer()
                        Text(user.name ?? "Unbekannt").foregroundColor(.gray)
                        Button("Bearbeiten") {
                            editedName = user.name ?? ""
                            isEditingName = true
                        }
                        .foregroundColor(.blue)
                    }
                    Divider()
                }
                
                HStack {
                    Text("E-Mail:")
                    Spacer()
                    Text(user.email ?? "Keine E-Mail").foregroundColor(.gray)
                }
                Divider()
                HStack {
                    Text("Admin:")
                    Spacer()
                    Toggle("", isOn: Binding<Bool>(
                        get: { user.isAdmin ?? false },
                        set: { isAdmin in
                            updateAdminStatus(isAdmin: isAdmin)
                        }
                    ))
                    .labelsHidden()
                }
                Divider()
                HStack {
                    Text("Aktiv:")
                    Spacer()
                    Text(user.isActive == true ? "Ja" : "Nein").foregroundColor(.gray)
                }

                Spacer()

                // Profil löschen
                Button("Profil löschen") {
                    isDeletingAccount = true
                }
                .foregroundColor(.red)

                Button("Schließen") {
                    isPresented = false
                }
                .foregroundColor(.blue)
            }
            .padding()
            .alert("Profil löschen", isPresented: $isDeletingAccount) {
                Button("Abbrechen", role: .cancel) { }
                Button("Löschen", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Möchtest du dieses Profil wirklich löschen?")
            }
        }
    }
    
    // MARK: - Funktionen

    private func updateUserName() {
        MainPageAPI.updateUserName(name: editedName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    user.name = editedName
                    isEditingName = false
                case .failure(let error):
                    print("❌ Fehler beim Aktualisieren des Namens: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateAdminStatus(isAdmin: Bool) {
        guard let userId = user.uid?.uuidString else {
            print("❌ Fehler: Benutzer-ID ist ungültig.")
            return
        }

        MainPageAPI.updateAdminStatus(userId: userId, isAdmin: isAdmin) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    user.isAdmin = isAdmin
                case .failure(let error):
                    print("❌ Fehler beim Aktualisieren des Admin-Status: \(error.localizedDescription)")
                }
            }
        }
    }

    private func deleteAccount() {
        guard let userId = user.uid?.uuidString else {
            print("❌ Fehler: Benutzer-ID ist ungültig.")
            return
        }

        MainPageAPI.deleteUser(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    isPresented = false
                case .failure(let error):
                    print("❌ Fehler beim Löschen des Kontos: \(error.localizedDescription)")
                }
            }
        }
    }


    private func deleteProfilePicture() {
        MainPageAPI.deleteProfilePicture { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    user.profileImage = nil
                case .failure(let error):
                    print("❌ Fehler beim Löschen des Profilbilds: \(error.localizedDescription)")
                }
            }
        }
    }
}
