import SwiftUI
import MeetingServiceDTOs

struct RecordsMainView: View {
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    
    @State private var searchText: String = ""
    @State private var showCreateMeeting = false
    @StateObject private var recordManager = RecordManager()
    @State private var expandedMeetingID: UUID?

    // Berechnete Eigenschaft für die gefilterten Meetings basierend auf dem Suchtext
    var filteredMeetingsWithRecords: [MeetingWithRecords] {
        guard !searchText.isEmpty else {
            return sortedMeetings
        }
        return sortedMeetings.filter { meetingWithRecords in
            meetingWithRecords.meeting.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var sortedMeetings: [MeetingWithRecords] {
        recordManager.meetingsWithRecords.sorted { meeting1, meeting2 in
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
    
    private var legende: some View {
        HStack{
            Text("In Bearbeitung")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(4)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(4)
            Text("Eingereicht")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(4)
            Text("Veröffentlicht")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(4)
        }
    }
}



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
            
            Text("Datum: \(DateTimeFormatter.formatDate(meetingWithRecords.meeting.start))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }

    }

    private var DropdownView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(meetingWithRecords.records, id: \.lang) { record in
                    NavigationLink(destination: MarkdownEditorView(meetingId: meetingWithRecords.meeting.id, lang: record.lang)) {
                        HStack {
                            Text("Protokoll öffnen in")
                            Text(LanguageManager.getLanguage(langCode: record.lang))
                                .padding(4)
                                .foregroundColor(.secondary)
                                .background(
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

    private func toggleExpansion() {
        if expandedMeetingID == meetingWithRecords.meeting.id {
            expandedMeetingID = nil
        } else {
            expandedMeetingID = meetingWithRecords.meeting.id
        }
    }
}

