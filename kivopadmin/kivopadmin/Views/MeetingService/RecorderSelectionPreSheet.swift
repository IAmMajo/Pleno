// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



import SwiftUI
import MeetingServiceDTOs

struct RecorderSelectionPreSheet: View {
    @Environment(\.dismiss) private var dismiss

    // alle User
    var users: [GetIdentityDTO]
    
    // Sitzungs-ID
    var meetingId: UUID

    
    @State private var selectedUser: UUID? = nil
    @State private var selectedUserName: String? = nil
    @Binding var localRecords: [GetRecordDTO]

    @StateObject private var recordManager = RecordManager()
    var attendanceManager: AttendanceManager

    var body: some View {
        if recordManager.isLoading {
            ProgressView("Lade Protokolle...")
                .progressViewStyle(CircularProgressViewStyle())
        } else if let errorMessage = recordManager.errorMessage {
            Text("Error: \(errorMessage)")
                .foregroundColor(.red)
        } else if localRecords.isEmpty {
            Text("Keine Protokolle verfügbar.")
                .foregroundColor(.secondary)
        } else {
            NavigationStack {
                List {
                    Section(header: Text("Protokoll auswählen")) {
                        ForEach($localRecords, id: \.lang) { $record in
                            // Link zur Auswahl des Protokollanten
                            NavigationLink(destination: RecorderSelectionSheet(
                                users: attendanceManager.allParticipants(),
                                recordLang: record.lang,
                                meetingId: meetingId,
                                selectedUser: $selectedUser,
                                selectedUserName: $selectedUserName,
                                localRecordsRecord: $record
                            )) {
                                // Protokoll wird mit Sprache und eingetragenem Protokollanten angezeigt.
                                HStack {
                                    Text("Sprache:")
                                    Text(record.lang).bold()
                                    Spacer()
                                    Text(record.identity.name)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Protokollantenauswahl")
            }
        }
    }
}
