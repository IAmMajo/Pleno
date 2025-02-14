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

