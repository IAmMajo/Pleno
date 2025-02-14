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
