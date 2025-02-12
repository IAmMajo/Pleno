import SwiftUI
import MeetingServiceDTOs

struct RecordsMainView: View {
    // ViewMode für die Sitzungen
    @StateObject private var meetingManager = MeetingManager()
    
    // Variable, die angibt, welche Sitzung ausgeklappt ist
    @State private var expandedMeetingID: UUID?
    
    // Suchtext
    @State private var searchText: String = ""
    
    // ViewModel für die Protokolle
    @StateObject private var recordManager = RecordManager()
    
    // Animationsvariable: falls noch kein Protokoll angezeigt wird, kommt sie zum Einsatz
    @State private var isAnimating = false

    // Sitzungsnamen filtern
    var filteredMeetingsWithRecords: [MeetingWithRecords] {
        guard !searchText.isEmpty else {
            return sortedMeetings
        }
        return sortedMeetings.filter { meetingWithRecords in
            meetingWithRecords.meeting.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    // Es werden nur Protokolle angezeigt, die tatsächlich veröffentlicht wurden
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
    
    // Nach Datum in absteigender Reihenfolge sortieren
    var sortedMeetings: [MeetingWithRecords] {
        onlySubmitted.sorted { meeting1, meeting2 in
            meeting2.meeting.start < meeting1.meeting.start // Absteigende Reihenfolge
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if recordManager.isLoading {
                    ProgressView("Lade Protokolle...") // Ladeanzeige
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = recordManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if recordManager.meetingsWithRecords.isEmpty {
                    Text("Keine Sitzungen und Protokolle verfügbar.")
                        .foregroundColor(.secondary)
                } else {
                    // Liste der Meetings mit den Sprachen der zugehörigen Records
                    if filteredMeetingsWithRecords.isEmpty {
                        // Wenn noch keine Protokolle veröffentlicht wurden
                        noRecordsAvailableView
                    } else {
                        // Searchbar
                        searchbar
                        
                        // Liste über alle Protokolle
                        listRecords
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
}

extension RecordsMainView {
    // Ladebildschirm, falls keine Protokolle verfügbar sind
    private var noRecordsAvailableView: some View {
        Group {
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
        }
    }
    
    // Searchbar
    private var searchbar: some View {
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
    }
    
    // Liste über alle Protokolle mit Sitzungsnamen
    private var listRecords: some View {
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
                            languagesScrollView(meetingWithRecords: meetingWithRecords)
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
                            expandedView(meetingWithRecords: meetingWithRecords)
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
    
    // Dropdown Anzeige
    private func expandedView(meetingWithRecords: MeetingWithRecords) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(meetingWithRecords.records, id: \.lang) { record in
                    // Link zum MarkdownEditorView, wo das Protokoll angezeigt werden kann
                    NavigationLink(destination: MarkdownEditorView(meetingId: meetingWithRecords.meeting.id, lang: record.lang)) {
                        HStack {
                            Text("Protokoll öffnen in")
                            // Anzeige der Sprache
                            Text("\(LanguageManager.getLanguage(langCode: record.lang))")
                                .padding(4)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(.top, 5)
        .frame(maxHeight: 200) // Maximalhöhe für den Dropdown festlegen
    }

    // Horizontale ScrollView, die anzeigt, in welchen Sprachen ein Protokoll verfügbar ist
    private func languagesScrollView(meetingWithRecords: MeetingWithRecords) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(meetingWithRecords.records, id: \.lang) { record in
                    Text(LanguageManager.getLanguage(langCode: record.lang))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal) // Optionales Padding für mehr Abstand an den Seiten
        }
    }
}
