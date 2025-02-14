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
import MeetingServiceDTOs

@MainActor
class AttendanceCurrentViewModel: ObservableObject {
    @Published var statusMessage: String?
    @Published var errorMessage: String? = nil
    @Published var searchText: String = "" {
        didSet { filterAttendances() } // Live-Update bei Texteingabe
    }
    @Published var participationCode: String = ""
    @Published var attendances: [GetAttendanceDTO] = [] {
        didSet { filterAttendances() } // Aktualisiert gefilterte Liste, wenn neue Daten geladen werden
    }
    @Published var filteredAttendances: [GetAttendanceDTO] = []
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
