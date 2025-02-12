// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

struct CurrentMeetingBottomView: View {
    // Variable für die Sitzung, die gerade angezeigt wird
    @State private var activeMeetingID: UUID?
    
    // ViewModel für alle Sitzungen; wird als EnvironmentObject mitgegeben
    @EnvironmentObject private var meetingManager : MeetingManager
    
    // ViewModel für die Anwesenheiten
    @StateObject private var attendanceManager = AttendanceManager()
    
    // Array für alle Anwesenheiten
    @State private var attendanceData: [UUID: [GetAttendanceDTO]] = [:]
    
    // Variablen für die API für jede Sitzung
    @State private var loadingStates: [UUID: Bool] = [:]
    @State private var errorMessages: [UUID: String] = [:]
    
    var body: some View {
        Group {
            if let currentMeeting = meetingManager.currentMeeting {
                VStack {
                    // Wenn mehr als eine Sitzung läuft, wird "paging Control" angezeigt (die Punkte unter den aktiven Sitzungen)
                    if meetingManager.meetings.filter { $0.status == .inSession }.count > 1 {
                        ScrollView(.horizontal) {
                            HStack {
                                filteredMeetingsView
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .scrollPosition(id: $activeMeetingID) // Verwende nur die ID für die Scroll-Position
                        .scrollIndicators(.never)
                        pagingControl
                    } else {
                        // Zeige das einzelne Meeting ohne ScrollView an
                        filteredMeetingsView
                    }
                }
                .onAppear {
                    // Setze die erste Sitzung mit Status 'inSession' als aktive Sitzung
                    activeMeetingID = meetingManager.meetings.filter { $0.status == .inSession }.first?.id
                }
            } else {
                Text("Keine Sitzung verfügbar")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .italic()
                    .padding()
            }
        }
        .onAppear {
            // Wenn die View aufgerufen wird, werden alle Sitzungen geladen
            meetingManager.fetchAllMeetings()
        }
    }
    
    // Es werden nur die Sitzungen berücksichtigt, die gerade laufen
    private var filteredMeetingsView: some View {
        ForEach(meetingManager.meetings.filter { $0.status == .inSession }, id: \.id) { meeting in
            meetingView(for: meeting)
        }
        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)

    }

    // Ansicht einer "Sitzungs-Box"
    private func meetingView(for meeting: GetMeetingDTO) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(meeting.name)
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white)
                Text(DateTimeFormatter.formatDate(meeting.start)) // Beispiel: Datum
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 4) {
                    if loadingStates[meeting.id] == true {
                        Text("Lädt...")
                    } else if let errorMessage = errorMessages[meeting.id] {
                        Text("Fehler: \(errorMessage)")
                    // Teilnehmeranzahl wird aus dem ViewModel geladen
                    } else if let attendances = attendanceData[meeting.id] {
                        Text("\(attendances.filter { $0.status == .present }.count)")
                            .foregroundStyle(.white)
                    } else {
                        Text("No Data")
                            .foregroundStyle(.white)
                    }
                    Image(systemName: "person.3.fill").foregroundStyle(.white) // Symbol für eine Gruppe von Personen
                }
            }

            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.white)
                Text(DateTimeFormatter.formatTime(meeting.start)) // Beispiel: Uhrzeit
                    .foregroundColor(.white)

                Spacer()
            }


        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(15)
        .padding(.horizontal, 12)
        .padding(.bottom, 20)
        .onAppear {
            if attendanceData[meeting.id] == nil { // Nur laden, wenn noch keine Daten vorhanden sind
                fetchAttendances(for: meeting.id)
            }
        }
    }

    // Punkte unter der ScrollView
    private var pagingControl: some View {
        HStack {
            ForEach(meetingManager.meetings.filter { $0.status == .inSession }, id: \.id) { meeting in
                Button {
                    withAnimation {
                        // Wenn ein Punkt angeklickt wird, wird zu dieser Sitzung gesprungen
                        activeMeetingID = meeting.id // Setze die ID des aktiven Meetings
                    }
                } label: {
                    Image(systemName: activeMeetingID == meeting.id ? "circle.fill" : "circle")
                        .foregroundStyle(Color(uiColor: .systemGray3))
                }
            }
        }
    }
    
    // Funktion, die die Teilnehmeranzahl steuert
    private func fetchAttendances(for meetingId: UUID) {
        loadingStates[meetingId] = true
        errorMessages[meetingId] = nil

        Task {
            do {
                let attendances = try await attendanceManager.fetchAttendances2(meetingId: meetingId)
                DispatchQueue.main.async {
                    self.attendanceData[meetingId] = attendances
                    self.loadingStates[meetingId] = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessages[meetingId] = error.localizedDescription
                    self.loadingStates[meetingId] = false
                }
            }
        }
    }

}
