import SwiftUI
import MeetingServiceDTOs

// Auswahl View auf welches Protokoll der User geleitet werden möchte
struct MeetingRecordsView: View {
    // Sitzung wird mitgeliefert
    var meeting: GetMeetingDTO
    
    // RecordManager als ViewModel
    @StateObject private var recordManager = RecordManager()
    
    var body: some View {
        NavigationStack {
            List {
                if recordManager.isLoading {
                    ProgressView("Lade Protokolle...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = recordManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if recordManager.records.isEmpty {
                    Text("Keine Protokolle verfügbar.")
                        .foregroundColor(.secondary)
                // Wenn viewmodel geladen hat
                } else {
                    ForEach(recordManager.records, id: \.lang) { record in
                        // Link zum Markdown Editor wo das Protokoll ggf. angeschaut werden kann
                        NavigationLink(destination: MarkdownEditorView(meetingId: record.meetingId, lang: record.lang)) {
                            Text("Protokoll: \(LanguageManager.getLanguage(langCode: record.lang))")
                        }
                    }
                }
            }
            .navigationTitle("Protokolle zu \(meeting.name)")
        }
        .onAppear(){
            recordManager.getRecordsMeeting(meetingId: meeting.id)
        }
    }
}
