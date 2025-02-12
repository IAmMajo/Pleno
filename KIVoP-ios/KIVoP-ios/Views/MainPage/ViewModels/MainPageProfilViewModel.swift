// This file is licensed under the MIT-0 License.

import SwiftUI
import AuthServiceDTOs

class MainPageProfilViewModel: ObservableObject {
    // Benutzerinformationen
    @Published var name: String = ""
    @Published var shortName: String = "??"
    @Published var profileImage: UIImage? = nil
    
    // UI-Zustände
    @Published var showSignOutConfirmation = false
    @Published var showDeleteAccountAlert = false
    @Published var navigateToLogin = false
    @Published var isLoading = true
    @Published var errorMessage: String? = nil

    // Vereinsinformationen (gecacht)
    let clubName: String = "Name des Vereins der manchmal auch sehr lange werden kann e.V."
    let clubShortName: String = "VL"

    init() {
        loadUserProfile()
    }

    // Holt die Profildaten des Benutzers
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

    // Benutzer abmelden
    func signOut() {
        MainPageAPI.logoutUser()
        navigateToLogin = true
    }

    // Benutzerkonto löschen
    func deleteAccount() {
        MainPageAPI.deleteUserAccount { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    KeychainHelper.delete(key: "username")
                    KeychainHelper.delete(key: "password")
                    self.signOut()
                case .failure(let error):
                    self.errorMessage = "Fehler: \(error.localizedDescription)"
                }
            }
        }
    }
}
