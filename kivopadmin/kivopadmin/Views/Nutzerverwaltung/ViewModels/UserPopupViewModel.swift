// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


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
            
            // Konvertiere `Data?` in `String?`
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
