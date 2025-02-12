// This file is licensed under the MIT-0 License.
import SwiftUI
import MeetingServiceDTOs

@MainActor
class AttendanceCurrentViewModel: ObservableObject {
    @Published var statusMessage: String?
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var participationCode: String = ""
    @Published var attendances: [GetAttendanceDTO] = []
    @Published var attendance: GetAttendanceDTO?
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
                // Meine Anwesenheit wird festgehalten (Um Status zu setzen etc.)
                attendance = attendances.first { $0.itsame }
                isLoading = false
            } catch {
                // Fehlerbehandlung
                print("Fehler beim Abrufen der Attendances: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
    
    // Aufruf der join-Funktion im AttendanceManager
    func joinMeeting() {
        Task {
            isLoading = true
            await statusMessage = attendanceManager.joinMeeting(meetingId: meeting.id, participationCode: participationCode)
            fetchAttendances()
            isLoading = false
        }
    }
    
    // Zählt alle zugesagten
    var presentCount: Int {
        attendances.filter { $0.status == .present }.count
    }
    
    // Zählt alle die gesagt haben sie haben Zeit, aber noch nicht da sind
    var acceptedCount: Int {
        attendances.filter { $0.status == .accepted }.count
    }
}
