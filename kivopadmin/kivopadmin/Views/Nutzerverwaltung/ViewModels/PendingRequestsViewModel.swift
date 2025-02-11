// This file is licensed under the MIT-0 License.

import SwiftUI
import AuthServiceDTOs

class PendingRequestsViewModel: ObservableObject {
    @Published var requests: [UserProfileDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    var onListUpdate: (() -> Void)?

    init(onListUpdate: (() -> Void)? = nil) {
        self.onListUpdate = onListUpdate
        fetchPendingRequests()
    }

    // MARK: - Offene Beitrittsanfragen abrufen
    func fetchPendingRequests() {
        isLoading = true
        errorMessage = nil

        MainPageAPI.fetchPendingUsers { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let users):
                    self.requests = users.filter { !$0.isActive } // Nur inaktive Nutzer anzeigen
                case .failure(let error):
                    self.errorMessage = "Fehler beim Laden der Anfragen: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Nutzer akzeptieren oder ablehnen
    func handleUserAction(userId: String, activate: Bool) {
        isLoading = true
        errorMessage = nil

        let apiCall: (_ userId: String, @escaping (Result<Void, Error>) -> Void) -> Void = activate
            ? MainPageAPI.activateUser
            : MainPageAPI.deleteUser

        apiCall(userId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    print("Benutzer erfolgreich \(activate ? "aktiviert" : "abgelehnt"): \(userId)")
                    self.requests.removeAll { $0.uid.uuidString == userId } // Entferne den Nutzer aus der Liste
                    self.onListUpdate?() // UI-Update anstoßen
                case .failure(let error):
                    self.errorMessage = "Fehler beim \(activate ? "Aktivieren" : "Ablehnen"): \(error.localizedDescription)"
                }
            }
        }
    }
}
