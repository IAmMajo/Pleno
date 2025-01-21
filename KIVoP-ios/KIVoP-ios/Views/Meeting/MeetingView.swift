import SwiftUI
import MeetingServiceDTOs

struct MeetingView: View {
    @State private var selectedSegment = "Anstehend" // Auswahl für den Picker
    @State private var searchText = ""
    
    var meetings: [GetMeetingDTO] // Array von Meetings als Eingabe
    
    
    var currentMeetings: [GetMeetingDTO] {
        meetings.filter { $0.status == .inSession }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Erste Sektion für die "Aktuelle Sitzung", immer sichtbar
                List {
                    if !currentMeetings.isEmpty {
                        Section(header: Text("Aktuelle Sitzungen")) {
                            ForEach(currentMeetings, id: \.id) { meeting in
                                //NavigationLink(destination: CurrentMeetingView(meeting: meeting)) {
                                NavigationLink(destination: MeetingDetailView(meeting: meeting)) {
                                    HStack {
                                        Image(systemName: "play.circle")
                                            .foregroundColor(.red)
                                        VStack(alignment: .leading) {
                                            Text(meeting.name)
                                                .foregroundStyle(.red)
                                            Text(meeting.start, style: .date)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }                    // Sektion mit dem Picker
                    Picker("Auswahl", selection: $selectedSegment) {
                        Text("Anstehend").tag("Anstehend")
                        Text("Vergangen").tag("Vergangen")
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear) // Hintergrund der Zeile entfernen
                    .padding(-20)
                    
                    // Inhalt basierend auf dem ausgewählten Segment
                    if selectedSegment == "Anstehend" {
                        UpcomingMeetingsView(meetings: meetings.filter { $0.status == .scheduled })
                    } else {
                        PastMeetingsView(meetings: meetings.filter { $0.status == .completed })
                    }

                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Sitzungen")
        }
        .searchable(text: $searchText)
    }
}

// Unteransicht für anstehende Sitzungen
struct UpcomingMeetingsView: View {
    var meetings: [GetMeetingDTO]
    
    var body: some View {
        
        Section(header: Text("Anstehende Sitzungen")) {
            if meetings.isEmpty {
                Text("Keine anstehenden Sitzungen.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(meetings, id: \.id) { meeting in
                    NavigationLink(destination: MeetingDetailView(meeting: meeting)) {
                        VStack(alignment: .leading) {
                            Text(meeting.name)
                            Text(meeting.start, style: .date) // Zeigt das Datum im richtigen Format an
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// Unteransicht für vergangene Sitzungen
struct PastMeetingsView: View {
    var meetings: [GetMeetingDTO]
    
    var body: some View {
        
        Section(header: Text("Vergangene Sitzungen")) {
            if meetings.isEmpty {
                Text("Keine vergangenen Sitzungen.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(meetings, id: \.id) { meeting in
                    NavigationLink(destination: MeetingDetailView(meeting: meeting)) {
                        VStack(alignment: .leading) {
                            Text(meeting.name)
                            Text(meeting.start, style: .date) // Zeigt das Datum im passenden Format
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}


#Preview {
    let exampleLocation = GetLocationDTO(
        id: UUID(),
        name: "Alte Turnhalle",
        street: "Altes Grab",
        number: "5",
        letter: "b",
        postalCode: "42069",
        place: "Hölle"
    )

    let exampleChair = GetIdentityDTO(
        id: UUID(),
        name: "Heinz-Peters"
    )

    // Beispielmeetings erstellen
    let exampleMeetings = [
        GetMeetingDTO(
            id: UUID(),
            name: "Vorstandsitzung Januar",
            description: "Eröffnung des Jahres.",
            status: .scheduled,
            start: Date().addingTimeInterval(86400 * 30), // In 30 Tagen
            duration: 120,
            location: exampleLocation,
            chair: exampleChair,
            code: "MTG001"
        ),
        GetMeetingDTO(
            id: UUID(),
            name: "Strategiemeeting",
            description: "Langfristige Planung.",
            status: .scheduled,
            start: Date().addingTimeInterval(86400 * 60), // In 60 Tagen
            duration: 90,
            location: exampleLocation,
            chair: exampleChair,
            code: "MTG002"
        ),
        GetMeetingDTO(
            id: UUID(),
            name: "Finanzreview",
            description: "Rückblick auf das Budget.",
            status: .completed,
            start: Date().addingTimeInterval(-86400 * 10), // Vor 10 Tagen
            duration: 90,
            location: exampleLocation,
            chair: exampleChair,
            code: "MTG003"
        ),
        GetMeetingDTO(
            id: UUID(),
            name: "Abschlussmeeting Q4",
            description: "Evaluation des Quartals.",
            status: .completed,
            start: Date().addingTimeInterval(-86400 * 20), // Vor 20 Tagen
            duration: 120,
            location: exampleLocation,
            chair: exampleChair,
            code: "MTG004"
        ),
        GetMeetingDTO(
            id: UUID(),
            name: "Jahreshauptversammlung",
            description: "Alle Mitglieder treffen sich.",
            status: .inSession,
            start: Date(), // Heute
            duration: 240,
            location: exampleLocation,
            chair: exampleChair,
            code: "MTG005"
        ),
        GetMeetingDTO(
            id: UUID(),
            name: "Kickoff 2024",
            description: "Start ins neue Jahr.",
            status: .scheduled,
            start: Date().addingTimeInterval(86400 * 5), // In 5 Tagen
            duration: 180,
            location: exampleLocation,
            chair: exampleChair,
            code: "MTG006"
        ),
        GetMeetingDTO(
            id: UUID(),
            name: "Marketingmeeting",
            description: "Planung der Kampagnen.",
            status: .completed,
            start: Date().addingTimeInterval(-86400 * 40), // Vor 40 Tagen
            duration: 150,
            location: exampleLocation,
            chair: exampleChair,
            code: "MTG007"
        ),
        GetMeetingDTO(
            id: UUID(),
            name: "Krisenbesprechung",
            description: "Schnelle Reaktion erforderlich.",
            status: .inSession,
            start: Date(), // Heute
            duration: 60,
            location: exampleLocation,
            chair: exampleChair,
            code: "MTG008"
        ),
        GetMeetingDTO(
            id: UUID(),
            name: "Treffen mit Partnern",
            description: "Austausch und Networking.",
            status: .scheduled,
            start: Date().addingTimeInterval(86400 * 15), // In 15 Tagen
            duration: 180,
            location: exampleLocation,
            chair: exampleChair,
            code: "MTG009"
        ),
        GetMeetingDTO(
            id: UUID(),
            name: "Jubiläumssitzung",
            description: "Feier des 10-jährigen Bestehens.",
            status: .completed,
            start: Date().addingTimeInterval(-86400 * 70), // Vor 70 Tagen
            duration: 200,
            location: exampleLocation,
            chair: exampleChair,
            code: "MTG010"
        )
    ]

    return MeetingView(meetings: exampleMeetings)
}
