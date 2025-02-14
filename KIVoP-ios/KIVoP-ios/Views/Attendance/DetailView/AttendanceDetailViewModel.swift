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
