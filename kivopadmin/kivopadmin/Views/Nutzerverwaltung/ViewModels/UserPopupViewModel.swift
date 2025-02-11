// This file is licensed under the MIT-0 License.
import SwiftUI
import AuthServiceDTOs

class UserPopupViewModel: ObservableObject {
    @Published var user: UserProfileDTO
    @Published var editedName: String
    @Published var tempIsAdmin: Bool
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String? // ✅ Fehler als String speichern
    @Published var isEditing = false
    @Published var isDeletingAccount = false
    @Published var profileImageData: Data?

    var onSave: () -> Void
    var onDelete: () -> Void

    init(user: UserProfileDTO, onSave: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.user = user
        self.editedName = user.name
        self.tempIsAdmin = user.isAdmin
        self.profileImageData = user.profileImage
        self.onSave = onSave
        self.onDelete = onDelete
    }

    // MARK: - Speichern von Änderungen
    func saveChanges(completion: (() -> Void)? = nil) {
        guard !user.uid.uuidString.isEmpty else {
            errorMessage = "Fehler: Benutzer-ID ungültig."
            showError = true
            return
        }

        isLoading = true
        showError = false

        let dispatchGroup = DispatchGroup()

        if editedName != user.name || profileImageData != user.profileImage {
            dispatchGroup.enter()
            
            // 🔹 Konvertiere `Data?` in `String?`
            let updatedProfileImageString = profileImageData?.base64EncodedString()

            MainPageAPI.updateUserProfile(userId: user.uid.uuidString, name: editedName, profileImage: updatedProfileImageString) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.onSave()
                    case .failure(let error):
                        self.errorMessage = "Fehler beim Aktualisieren: \(error.localizedDescription)"
                        self.showError = true
                    }
                    dispatchGroup.leave()
                }
            }
        }


        if tempIsAdmin != user.isAdmin {
            dispatchGroup.enter()
            MainPageAPI.updateAdminStatus(userId: user.uid.uuidString, isAdmin: tempIsAdmin, isActive: user.isActive) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.onSave()
                    case .failure(let error):
                        self.errorMessage = "Fehler beim Aktualisieren des Admin-Status: \(error.localizedDescription)"
                        self.showError = true
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
            if !self.showError {
                completion?() // ✅ Schließt das Popup nach erfolgreicher Speicherung
            }
        }
    }

    // MARK: - Konto löschen
    func deleteAccount(completion: (() -> Void)? = nil) {
        isLoading = true
        showError = false

        MainPageAPI.deleteUser(userId: user.uid.uuidString) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.onDelete()
                    completion?() // ✅ Popup nach erfolgreichem Löschen schließen
                case .failure(let error):
                    self.errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
                    self.showError = true
                }
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func deleteProfilePicture() {
        profileImageData = nil // UI sofort aktualisieren

        MainPageAPI.deleteProfilePicture(userId: user.uid.uuidString) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    debugPrint("✅ Profilbild erfolgreich gelöscht.")
                    self.onSave()
                    self.user.profileImage = nil
                case .failure(let error):
                    debugPrint("❌ Fehler beim Löschen des Profilbilds: \(error.localizedDescription)")
                    self.showError = true
                    self.profileImageData = self.user.profileImage // Rollback
                }
            }
        }
    }
    
    func formattedCreationDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .medium
        return formatter.string(from: user.createdAt)
    }
}
