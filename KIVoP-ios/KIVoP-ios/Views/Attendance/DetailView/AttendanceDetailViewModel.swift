// This file is licensed under the MIT-0 License.
import Foundation
import MeetingServiceDTOs

@MainActor
class AttendanceDetailViewModel: ObservableObject {
    @Published var searchText: String = "" {
        didSet { filterAttendances() } // Live-Update bei Texteingabe
    }
    @Published var attendances: [GetAttendanceDTO] = [] {
        didSet { filterAttendances() } // Aktualisiert gefilterte Liste, wenn neue Daten geladen werden
    }
    @Published var filteredAttendances: [GetAttendanceDTO] = []
    @Published var isLoading: Bool = true
    
    // Hier werden alle API-Aufrufe ausgeführt
    @Published var attendanceManager = AttendanceManager.shared
    
    private let baseURL = "https://kivop.ipv64.net"
    var meeting: GetMeetingDTO
    
    init(meeting: GetMeetingDTO) {
        self.meeting = meeting
    }
    
    // Aufruf von fetchAttendances im Manager
    func fetchAttendances() {
        Task {
            do {
                isLoading = true
                // Versuche, attendances zu laden
                attendances = try await attendanceManager.fetchAttendances2(meetingId: meeting.id)
                isLoading = false
            } catch {
                // Fehlerbehandlung
                print("Fehler beim Abrufen der Attendances: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
    
    // Filter für die Suche
    private func filterAttendances() {
        if searchText.isEmpty {
            filteredAttendances = attendances
        } else {
            filteredAttendances = attendances.filter { attendance in
                attendance.identity.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Zählen von allen anwesenden
    var presentCount: Int {
        attendances.filter { $0.status == .present }.count
    }
    
    // Zählen von allen die nicht anwesend waren
    var absentCount: Int {
        attendances.filter { $0.status != .present }.count
    }
}
