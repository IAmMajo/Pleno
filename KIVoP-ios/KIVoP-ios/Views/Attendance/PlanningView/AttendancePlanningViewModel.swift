import Foundation
import EventKit
import EventKitUI
import MeetingServiceDTOs

@MainActor
class AttendancePlanningViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var errorMessage: String? = nil
    @Published var attendances: [GetAttendanceDTO] = []
    @Published var attendance: GetAttendanceDTO?
    @Published var isLoading: Bool = true
    @Published var isShowingAlert = false
    @Published var alertMessage = ""
    
    private let eventStore = EKEventStore()
    private let baseURL = "https://kivop.ipv64.net"
    var meeting: GetMeetingDTO
    
    init(meeting: GetMeetingDTO) {
        self.meeting = meeting
    }
    
    public func fetchAttendances() {
        isLoading = true
        Task {
            do {
                // URL und Request erstellen
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/attendances") else {
                    print("Ungültige URL.")
                    isLoading = false
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    errorMessage = "Unauthorized: Token not found."
                    isLoading = false
                    return
                }
                
                // API-Aufruf und Antwort verarbeiten
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Fehlerhafte Antwort vom Server.")
                    isLoading = false
                    return
                }
                
                // JSON dekodieren
                self.attendances = try JSONDecoder().decode([GetAttendanceDTO].self, from: data)
                self.attendance = attendances.first(where: { $0.itsame })
                
            } catch {
                print("Fehler: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    public func markAttendanceAsAccepted() {
        isLoading = true
        Task {
            do {
                // URL für die Anfrage erstellen
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/plan-attendance/present") else {
                    isLoading = false
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    isLoading = false
                    return
                }
                
                // API-Aufruf starten
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    isLoading = false
                    return
                }
                fetchAttendances()
            }
        }
    }

    public func markAttendanceAsAbsent() {
        isLoading = true
        Task {
            do {
                // URL für die Anfrage erstellen
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/plan-attendance/absent") else {
                    isLoading = false
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    isLoading = false
                    return
                }
                
                // API-Aufruf starten
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    isLoading = false
                    return
                }
                fetchAttendances()
                removeEvent(eventTitle: meeting.name, eventDate: meeting.start)
            }
        }
    }

    var nilCount: Int {
        attendances.filter { $0.status == nil }.count
    }
    
    var acceptedCount: Int {
        attendances.filter { $0.status == .accepted }.count
    }
    
    var absentCount: Int {
        attendances.filter { $0.status == .absent }.count
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm 'Uhr'"
        return formatter.string(from: date)
    }
    
    // Termin zum Kalender hinzufügen
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestFullAccessToEvents { granted, error in
            if let error = error {
                print("Fehler bei der Berechtigungsanfrage: \(error.localizedDescription)")
                completion(false) // Zugriff verweigert
                return
            }
            if granted {
                completion(true) // Zugriff gewährt
            } else {
                completion(false) // Zugriff verweigert
            }
        }
    }
    
    func addEventToCalendar(eventTitle: String, eventDate: Date, duration: UInt16?) {
        requestCalendarAccess { granted in
            guard granted else {
                DispatchQueue.main.async {
                    self.alertMessage = "Kein Zugriff auf den Kalender. Bitte Berechtigung prüfen."
                    self.isShowingAlert = true
                }
                return
            }

            let event = EKEvent(eventStore: self.eventStore)
            event.title = eventTitle
            event.startDate = eventDate
            event.endDate = eventDate.addingTimeInterval(Double((duration ?? 60) * 60))
            event.calendar = self.eventStore.defaultCalendarForNewEvents

            do {
                try self.eventStore.save(event, span: .thisEvent)
                DispatchQueue.main.async {
                    self.alertMessage = "Der Termin \"\(eventTitle)\" wurde hinzugefügt."
                    self.isShowingAlert = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Der Termin \"\(eventTitle)\" konnte nicht hinzugefügt werden."
                    self.isShowingAlert = true
                }
            }
        }
    }
    
    func removeEvent(eventTitle: String, eventDate: Date) {
        requestCalendarAccess { granted in
            guard granted else {
                DispatchQueue.main.async {
                    self.alertMessage = "Kein Zugriff auf den Kalender. Bitte Berechtigung prüfen."
                    self.isShowingAlert = true
                }
                return
            }

            // Zeitspanne definieren (z. B. +/- 1 Tag um das Datum)
            let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: eventDate)!
            let oneDayAfter = Calendar.current.date(byAdding: .day, value: 1, to: eventDate)!
            
            // Ereignisse im definierten Zeitraum abrufen
            let predicate = self.eventStore.predicateForEvents(withStart: oneDayBefore, end: oneDayAfter, calendars: nil)
            let events = self.eventStore.events(matching: predicate)

            // Event mit Titel und Datum filtern
            if let event = events.first(where: { $0.title == eventTitle && $0.startDate == eventDate }) {
                do {
                    try self.eventStore.remove(event, span: .thisEvent)
                    DispatchQueue.main.async {
                        self.alertMessage = "Der Termin \"\(eventTitle)\" wurde aus dem Kalender entfernt."
                        self.isShowingAlert = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.alertMessage = "Der Termin \"\(eventTitle)\" konnte nicht entfernt werden."
                        self.isShowingAlert = true
                    }
                }
            } else {
                // Es gab keinen Termin zum entfernen.
            }
        }
    }
}
