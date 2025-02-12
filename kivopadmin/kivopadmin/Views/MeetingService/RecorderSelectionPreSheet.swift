// This file is licensed under the MIT-0 License.

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
