import SwiftUI
import MeetingServiceDTOs

struct RecordsMainView: View {
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    
    @State private var searchText: String = ""
    @State private var showCreateMeeting = false
    @StateObject private var recordManager = RecordManager()

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
                    
                    // Liste der Meetings mit den Sprachen der zugehörigen Records
                    List {
                        ForEach(filteredMeetingsWithRecords, id: \.meeting.id) { meetingWithRecords in
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    // Name des Meetings
                                    Text(meetingWithRecords.meeting.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    // Sprachen der zugehörigen Records
                                    HStack(spacing: 8) {
                                        ForEach(meetingWithRecords.records, id: \.lang) { record in
                                            //NavigationLink(destination: MarkdownEditorView(meetingId: meetingWithRecords.meeting.id, lang: record.lang)) {
                                                Text(record.lang)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                    .padding(4)
                                                    .background(Color.blue.opacity(0.2))
                                                    .cornerRadius(4)
                                                    .overlay {
                                                        NavigationLink(destination: MarkdownEditorView(meetingId: meetingWithRecords.meeting.id, lang: record.lang)) {}
                                                            .opacity(0)
                                                    }
                                            //}
                                        }
                                    }

                                }
                                
                                // Optional: Zeige das Startdatum des Meetings
                                Text("Start: \(meetingWithRecords.meeting.start.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                            }
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                        }
                    }
                    .listStyle(PlainListStyle()) // Optionale Listensytle
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

#Preview {
    RecordsMainView()
}
