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
    @Published var isLoading: Bool = false
    @Published var isShowingAlert = false
    @Published var alertMessage = ""
    
    // Hier werden alle API-Aufrufe ausgeführt
    @Published var attendanceManager = AttendanceManager.shared
    
    private let eventStore = EKEventStore()
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
    
    // Aufruf der Funktion um einem Meeting zuzusagen im Manager
    func markAttendanceAsAccepted() {
        Task {
            isLoading = true
            attendanceManager.markAttendanceAsAccepted(meetingId: meeting.id)
            // eigenen Status ändern, damit es in der View aktualisiert wird
            if let index = attendances.firstIndex(where: { $0.itsame }) { attendances[index].status = .accepted }
            isLoading = false
        }
    }

    // Aufruf der Funktion um einem Meeting abzusagen im Manager
    func markAttendanceAsAbsent() {
        Task {
            isLoading = true
            attendanceManager.markAttendanceAsAbsent(meetingId: meeting.id)
            // eigenen Status ändern, damit es in der View aktualisiert wird
            if let index = attendances.firstIndex(where: { $0.itsame }) { attendances[index].status = .absent }
            isLoading = false
        }
        // entfernen aus Kalender
        removeEvent(eventTitle: meeting.name, eventDate: meeting.start)
    }

    // Zählen wie viele Personen noch nicht abgestimmt haben
    var nilCount: Int {
        attendances.filter { $0.status == nil }.count
    }
    
    // Zählen wie viele Personen teilnehmen
    var acceptedCount: Int {
        attendances.filter { $0.status == .accepted }.count
    }
    
    // Zählen wie viele Personen nicht teilnehmen
    var absentCount: Int {
        attendances.filter { $0.status == .absent }.count
    }
    
    // Zugang zum Kalender anfragen
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
    
    // Termin zum Kalender hinzufügen
    func addEventToCalendar(eventTitle: String, eventDate: Date, duration: UInt16?) {
        requestCalendarAccess { granted in
            guard granted else {
                DispatchQueue.main.async {
                    self.alertMessage = "Kein Zugriff auf den Kalender. Bitte Berechtigung prüfen."
                    self.isShowingAlert = true
                }
                return
            }
            
            // Zeitraum definieren, um bestehende Events zu prüfen
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: eventDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? startOfDay.addingTimeInterval(60 * 60)
            let predicate = self.eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
            let existingEvents = self.eventStore.events(matching: predicate)


            // Prüfen, ob das Event mit Titel und Datum existiert
            if existingEvents.contains(where: { $0.title == eventTitle }) {
                DispatchQueue.main.async {
                    self.alertMessage = "Dieser Termin existiert bereits in deinem Kalender."
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
    
    // Termin aus Kalender entfernen
    func removeEvent(eventTitle: String, eventDate: Date) {
        requestCalendarAccess { granted in
            guard granted else {
                DispatchQueue.main.async {
                    self.alertMessage = "Kein Zugriff auf den Kalender. Bitte Berechtigung prüfen."
                    self.isShowingAlert = true
                }
                return
            }

            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: eventDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? startOfDay.addingTimeInterval(60 * 60)
            let predicate = self.eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
            let events = self.eventStore.events(matching: predicate)
            
            if let event = events.first(where: { $0.title == eventTitle }) {
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
                // Wenn kein Eintrag vorhanden ist, kommt keine Meldung.
            }
        }
    }

}
