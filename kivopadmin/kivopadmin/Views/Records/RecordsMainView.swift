// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

struct RecordsMainView: View {
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    
    // Suchtext für die Suchfunktion
    @State private var searchText: String = ""

    // ViewModel für die Protokolle
    @StateObject private var recordManager = RecordManager()
    
    // ID der Sitzung, die in der Ansicht ausgeklappt ist
    @State private var expandedMeetingID: UUID?

    // Gibt die Sitzung mit Protokollen basierend auf dem Suchtext zurück
    var filteredMeetingsWithRecords: [MeetingWithRecords] {
        guard !searchText.isEmpty else {
            return sortedMeetings
        }
        return sortedMeetings.filter { meetingWithRecords in
            meetingWithRecords.meeting.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    // Sortiert die Sitzungen nach Datum in absteigender Reihenfolge
    var sortedMeetings: [MeetingWithRecords] {
        recordManager.meetingsWithRecords.sorted { meeting1, meeting2 in
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
                    Text("Fehler: \(errorMessage)")
                        .foregroundColor(.red)
                } else if recordManager.meetingsWithRecords.isEmpty {
                    Text("Keine Protokolle verfügbar")
                        .foregroundColor(.secondary)
                } else {
                    // Searchbar
                    searchbar
                    
                    // Legende
                    legende
                    
                    // Liste aller Sitzungen mit Protokollen
                    List {
                        ForEach(filteredMeetingsWithRecords, id: \.meeting.id) { meetingWithRecords in
                            MeetingRow(
                                meetingWithRecords: meetingWithRecords,
                                expandedMeetingID: $expandedMeetingID
                            )
                        }
                    }
                    .listStyle(PlainListStyle())

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
    // Searchbar
    private var searchbar: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Nach Sitzung suchen", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    // Legende, die die Farben der unterschiedlichen Status anzeigt
    // Mit Übersicht über den Status aller Protokolle
    private var legende: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThickMaterial)
                .frame(maxWidth: .infinity, maxHeight: 40) // Passt sich an

            HStack {
                Text("Übersicht")
                
                Spacer()

                HStack {
                    Text("In Bearbeitung: \(recordManager.recordsNotApproved)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(4)
                    Text("Eingereicht: \(recordManager.recordsNotSubmitted)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    Text("Veröffentlicht: \(recordManager.recordsApproved)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding(10) // Abstand innerhalb des Rechtecks
        }
        .frame(maxWidth: .infinity) // ZStack soll sich über die volle Breite erstrecken
        .padding(.horizontal) // Abstand zur Bildschirmkante

    }
}


// Anzeige eines Listenzeile
struct MeetingRow: View {
    let meetingWithRecords: MeetingWithRecords
    @Binding var expandedMeetingID: UUID?

    var body: some View {
        Button(action: toggleExpansion) {
            VStack(alignment: .leading, spacing: 5) {
                HeaderView
                if expandedMeetingID == meetingWithRecords.meeting.id {
                    DropdownView
                }
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // Header der Zeile: -> Aufbau: Name der Sitzung + verfügbare Sprachen
    private var HeaderView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(meetingWithRecords.meeting.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(meetingWithRecords.records, id: \.lang) { record in
                            Text(LanguageManager.getLanguage(langCode: record.lang))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(4)
                                .background(
                                    (record.status == .underway) ? Color.orange.opacity(0.2) :
                                    (record.status == .submitted) ? Color.blue.opacity(0.2) :
                                    (record.status == .approved) ? Color.green.opacity(0.2) :
                                    Color.gray.opacity(0.2)
                                )
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal)
                }.fixedSize(horizontal: true, vertical: false)

                
                Image(systemName: expandedMeetingID == meetingWithRecords.meeting.id ? "chevron.up" : "chevron.down")
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 4)
            
            // Startdatum der Sitzung
            Text("Datum: \(DateTimeFormatter.formatDate(meetingWithRecords.meeting.start))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }

    }

    // Dropdown Menu
    private var DropdownView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                // Schleife über alle verfügbaren Sprachen
                ForEach(meetingWithRecords.records, id: \.lang) { record in
                    NavigationLink(destination: MarkdownEditorView(meetingId: meetingWithRecords.meeting.id, lang: record.lang)) {
                        HStack {
                            Text("Protokoll öffnen in")
                            Text(LanguageManager.getLanguage(langCode: record.lang))
                                .padding(4)
                                .foregroundColor(.secondary)
                                .background(
                                    // In Abhängigkeit des Status hat die Sprache eine andere Hintergrundfarbe
                                    (record.status == .underway) ? Color.orange.opacity(0.2) :
                                    (record.status == .submitted) ? Color.blue.opacity(0.2) :
                                    (record.status == .approved) ? Color.green.opacity(0.2) :
                                    Color.gray.opacity(0.2)
                                )
                                .cornerRadius(4)


                        }
                    }
                }
            }
        }
        .padding(.top, 5)
        .frame(maxHeight: 200)
    }

    // Funktion die die ausgeklappte Sitzung verwaltet
    private func toggleExpansion() {
        if expandedMeetingID == meetingWithRecords.meeting.id {
            expandedMeetingID = nil
        } else {
            expandedMeetingID = meetingWithRecords.meeting.id
        }
    }
}

