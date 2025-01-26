import SwiftUI
import MeetingServiceDTOs

struct MeetingAnwesenheitenView: View {
    var meeting: GetMeetingDTO
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    @StateObject private var recordManager = RecordManager() // RecordManager als StateObject
    @StateObject private var votingManager = VotingManager() // RecordManager als StateObject
    @StateObject private var attendanceManager = AttendanceManager() // RecordManager als StateObject
    
    var body: some View {
        NavigationStack {
            List{
                VStack (alignment: .leading){
                    // Protokolle

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
            }
            .navigationTitle("Protokolle zu \(meeting.name)")
        }
        .onAppear(){
            recordManager.getRecordsMeeting(meetingId: meeting.id)
            votingManager.getVotingsMeeting(meetingId: meeting.id)
            attendanceManager.fetchAttendances(meetingId: meeting.id)
        }
    }

    
}
