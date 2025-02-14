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

class NutzerverwaltungViewModel: ObservableObject {
    @Published var users: [UserProfileDTO] = []
    @Published var pendingRequestsCount: Int = 0
    @Published var selectedUser: UserProfileDTO? = nil
    @Published var isLoading: Bool = false
    @Published var isUserPopupPresented = false
    @Published var isPendingRequestPopupPresented = false
    @Published var loadingUserID: UUID? = nil

    init() {
        fetchAllData()
    }

    // MARK: - Daten abrufen
    func fetchAllData() {
        print("🔄 Nutzerverwaltung gestartet. Daten werden geladen...")
        fetchAllUsers()
        fetchPendingRequestsCount()
    }

    // MARK: - Nutzerliste abrufen
    func fetchAllUsers() {
        print("🔄 Benutzer werden geladen...")
        isLoading = true
        MainPageAPI.fetchAllUsers { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let fetchedUsers):
                    self.users = fetchedUsers.filter { $0.isActive == true }
                    print("✅ Benutzerliste aktualisiert. Anzahl: \(self.users.count)")
                case .failure(let error):
                    print("❌ Fehler beim Laden der Benutzer: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Anzahl ausstehender Anfragen abrufen
    func fetchPendingRequestsCount() {
        print("🔄 Beitrittsanfragen werden geladen...")
        MainPageAPI.fetchPendingUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.pendingRequestsCount = users.filter { !$0.isActive }.count
                    print("✅ Anzahl ausstehender Anfragen: \(self.pendingRequestsCount)")
                case .failure(let error):
                    print("❌ Fehler beim Abrufen der Anfragen: \(error.localizedDescription)")
                    self.pendingRequestsCount = 0
                }
            }
        }
    }

    // MARK: - Benutzer auswählen
    func selectUser(_ user: UserProfileDTO) {
        print("🔍 Benutzer ausgewählt: \(user.name)")
        guard loadingUserID != user.uid else {
            print("🔄 Benutzer wird bereits geladen...")
            return
        }

        loadingUserID = user.uid
        selectedUser = nil
        isUserPopupPresented = false

        MainPageAPI.fetchUserByID(userID: user.uid) { result in
            DispatchQueue.main.async {
                self.loadingUserID = nil
                switch result {
                case .success(let fetchedUser):
                    self.selectedUser = fetchedUser
                    print("✅ Benutzer erfolgreich geladen: \(fetchedUser.name)")
                    self.isUserPopupPresented = true
                case .failure(let error):
                    print("❌ Fehler beim Laden des Benutzers: \(error.localizedDescription)")
                }
            }
        }
    }
}

