import SwiftUI
import MeetingServiceDTOs

struct MeetingRecordsView: View {
    var meeting: GetMeetingDTO
    @StateObject private var recordManager = RecordManager() // RecordManager als StateObject
    
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
                    Text("No records available.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(recordManager.records, id: \.lang) { record in
                        NavigationLink(destination: MarkdownEditorView(meetingId: record.meetingId, lang: record.lang)) {
                            Text("Protokoll: \(record.lang)")
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
