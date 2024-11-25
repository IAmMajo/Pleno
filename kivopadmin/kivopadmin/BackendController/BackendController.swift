import Foundation
import Combine
import AuthServiceDTOs

class BackendController: ObservableObject {
    // Publisher für die Daten
    @Published var users: [String] = [] // Beispiel: Benutzer
    @Published var pendingRequestsCount: Int = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    // Funktion zum Abrufen der Nutzerdaten
    func fetchUsers() {
        // Hier sollte die Backend-Logik zum Abrufen der Nutzerdaten stehen
        // Zum Beispiel: API-Aufruf zum Server
        // Beispiel für Dummy-Daten:
        self.users = ["Max Mustermann", "Maxine Musterfrau", "Maximilian Musterkind"]
    }
    
    // Funktion zum Abrufen der ausstehenden Anfragen
    func fetchPendingRequests() {
        // Beispiel für einen API-Aufruf:
        // APIClient.getPendingRequests { result in
        //     switch result {
        //     case .success(let count):
        //         self.pendingRequestsCount = count
        //     case .failure(let error):
        //         print("Error fetching pending requests: \(error)")
        //     }
        // }
        
        // Hier Dummy-Wert
        self.pendingRequestsCount = 3
    }
    
    // Funktion zum Bestätigen einer Beitrittsanfrage
    func acceptRequest(for user: String) {
        // Beispiel für eine Anfrage an das Backend
        // APIClient.acceptRequest(user: user) { result in
        //     // Handle response
        // }
    }
    
    // Funktion zum Ablehnen einer Beitrittsanfrage
    func rejectRequest(for user: String) {
        // Beispiel für eine Anfrage an das Backend
        // APIClient.rejectRequest(user: user) { result in
        //     // Handle response
        // }
    }

    
    


}
