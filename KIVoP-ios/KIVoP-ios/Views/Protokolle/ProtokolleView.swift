import SwiftUI
import MeetingServiceDTOs

struct RecordsMainView: View {
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    @State private var expandedMeetingID: UUID?
    @State private var searchText: String = ""
    @State private var showCreateMeeting = false
    @StateObject private var recordManager = RecordManager()
    @State private var isAnimating = false

    // Berechnete Eigenschaft für die gefilterten Meetings basierend auf dem Suchtext
    var filteredMeetingsWithRecords: [MeetingWithRecords] {
        guard !searchText.isEmpty else {
            return sortedMeetings
        }
        return sortedMeetings.filter { meetingWithRecords in
            meetingWithRecords.meeting.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var onlySubmitted: [MeetingWithRecords] {
        recordManager.meetingsWithRecords.filter { meeting in
            // Behalte Meetings, die mindestens einen approved Record haben
            meeting.records.contains { record in
                record.status == .approved
            }
        }
        .map { meeting in
            // Erzeuge neue MeetingWithRecords, die nur approved Records enthalten
            MeetingWithRecords(
                meeting: meeting.meeting,
                records: meeting.records.filter { record in
                    record.status == .approved
                }
            )
        }
    }
    
    var sortedMeetings: [MeetingWithRecords] {
        onlySubmitted.sorted { meeting1, meeting2 in
            meeting2.meeting.start < meeting1.meeting.start // Absteigende Reihenfolge
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if recordManager.isLoading {
                    ProgressView("Loading meetings...") // Ladeanzeige
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = recordManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if recordManager.meetingsWithRecords.isEmpty {
                    Text("No meetings available.")
                        .foregroundColor(.secondary)
                } else {
                    // Liste der Meetings mit den Sprachen der zugehörigen Records
                    if filteredMeetingsWithRecords.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            // Animiertes Symbol (z. B. ein sich drehender Kreis)
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 20) // Größe des Kreises
                                .scaleEffect(isAnimating ? 1.2 : 0.8) // Skalierung der Animation
                                .animation(
                                    Animation.easeInOut(duration: 1.5)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                            
                            // Text
                            Text("Es wurden noch keine Protokolle veröffentlicht.")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }       .onAppear {
                            isAnimating = true // Animation starten, wenn die View erscheint
                        }
                        Spacer()
                    } else {
                        // Searchbar
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Nach Meeting suchen", text: $searchText)
                                    .textFieldStyle(PlainTextFieldStyle())
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        

                        
                        List {
                            ForEach(filteredMeetingsWithRecords, id: \.meeting.id) { meetingWithRecords in
                                Button(action: {
                                    // Toggle des Dropdowns
                                    if expandedMeetingID == meetingWithRecords.meeting.id {
                                        expandedMeetingID = nil
                                    } else {
                                        expandedMeetingID = meetingWithRecords.meeting.id
                                    }
                                }) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            // Name des Meetings
                                            Text(meetingWithRecords.meeting.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)

                                            Spacer()
                                            // Sprachen der zugehörigen Records
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 8) {
                                                    ForEach(meetingWithRecords.records, id: \.lang) { record in
                                                        Text(getLanguage(langCode: record.lang))
                                                            .font(.subheadline)
                                                            .foregroundColor(.secondary)
                                                            .padding(4)
                                                            .background(Color.blue.opacity(0.2))
                                                            .cornerRadius(4)
                                                    }
                                                }
                                                .padding(.horizontal) // Optionales Padding für mehr Abstand an den Seiten
                                            }
                                            // Pfeilsymbol (Optional: Sichtbar, um Interaktion zu zeigen)
                                            Image(systemName: expandedMeetingID == meetingWithRecords.meeting.id ? "chevron.up" : "chevron.down")
                                                .foregroundColor(.blue)
                                        }

                                        // Optional: Zeige das Startdatum des Meetings
                                        Text("Start: \(meetingWithRecords.meeting.start.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        // Dropdown: Zeige Sprachen, wenn das aktuelle Meeting erweitert ist
                                        if expandedMeetingID == meetingWithRecords.meeting.id {
                                            ScrollView {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    ForEach(meetingWithRecords.records, id: \.lang) { record in
                                                        NavigationLink(destination: MarkdownEditorView(meetingId: meetingWithRecords.meeting.id, lang: record.lang)) {
                                                            Text("Protokoll öffnen in")
                                                            Text("\(getLanguage(langCode: record.lang))")
                                                                .padding(4)
                                                                .background(Color.blue.opacity(0.2))
                                                                .cornerRadius(4)
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.top, 5)
                                            .frame(maxHeight: 200) // Maximalhöhe für den Dropdown festlegen
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle()) // Entfernt Klick-Hervorhebungseffekt
                            }
                        }
                        .listStyle(PlainListStyle())
                    }


                }
            }
            .navigationTitle("Protokolle")
            .onAppear {
                meetingManager.fetchAllMeetings() // Meetings laden, wenn die View erscheint
                recordManager.getAllMeetingsWithRecords()
            }
        }
    }
    private func getLanguage(langCode: String) -> String {
        let languages: [(name: String, code: String)] = [
            ("Arabisch", "ar"),
            ("Chinesisch", "zh"),
            ("Dänisch", "da"),
            ("Deutsch", "de"),
            ("Englisch", "en"),
            ("Französisch", "fr"),
            ("Griechisch", "el"),
            ("Hindi", "hi"),
            ("Italienisch", "it"),
            ("Japanisch", "ja"),
            ("Koreanisch", "ko"),
            ("Niederländisch", "nl"),
            ("Norwegisch", "no"),
            ("Polnisch", "pl"),
            ("Portugiesisch", "pt"),
            ("Rumänisch", "ro"), // Hinzugefügt
            ("Russisch", "ru"),
            ("Schwedisch", "sv"),
            ("Spanisch", "es"),
            ("Thai", "th"), // Hinzugefügt
            ("Türkisch", "tr"),
            ("Ungarisch", "hu")
        ]


        // Suche nach dem Kürzel und gib den Namen zurück
        if let language = languages.first(where: { $0.code == langCode }) {
            return language.name
        }

        // Standardwert, falls das Kürzel nicht gefunden wird
        return langCode
    }

}

#Preview {
    RecordsMainView()
}
