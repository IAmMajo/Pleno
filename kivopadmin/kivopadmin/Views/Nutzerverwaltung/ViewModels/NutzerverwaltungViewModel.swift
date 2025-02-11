// This file is licensed under the MIT-0 License.
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
