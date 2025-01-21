import SwiftUI
import MeetingServiceDTOs
import AuthServiceDTOs
import Foundation

struct RecorderSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss

    var users: [GetIdentityDTO]
    var recordLang: String
    var meetingId: UUID

    @Binding var selectedUser: UUID? // Speichert die Benutzer-ID
    @Binding var selectedUserName: String? // Speichert den Benutzernamen
    @Binding var localRecordsRecord: GetRecordDTO

    @State private var searchText: String = ""
    @State private var filteredUsers: [GetIdentityDTO] = []

    @StateObject private var recordManager = RecordManager()

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    userSelectionSection
                    informationSection
                }
                .navigationTitle("Benutzer auswählen")
                .searchable(text: $searchText)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Speichern") {
                            saveRecord()
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            initializeFilteredUsers()
        }
    }

    private var userSelectionSection: some View {
        Section(header: Text("Benutzer auswählen")) {
            ForEach(filteredUsers, id: \.id) { user in
                userRow(for: user)
            }
        }
    }

    private func userRow(for user: GetIdentityDTO) -> some View {
        HStack {
            Text(user.name)
            Spacer()
            if user.id == localRecordsRecord.identity.id {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                selectUser(user)
            }
        }
    }

    private var informationSection: some View {
        Section {
            Text("Nutzer werden hier angezeigt, wenn sie an der Sitzung teilnehmen")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.vertical, 10)
        }
        .textCase(nil)
    }

    private func saveRecord() {
        Task {
            let patchDTO = PatchRecordDTO(identityId: selectedUser)
            await recordManager.patchRecordMeetingLang(patchRecordDTO: patchDTO, meetingId: meetingId, lang: recordLang)
        }
    }

    private func initializeFilteredUsers() {
        filteredUsers = users
        let selectedUserId = localRecordsRecord.identity.id
        if let preselectedUser = users.first(where: { $0.id == selectedUserId }) {
            selectedUser = selectedUserId
            selectedUserName = preselectedUser.name
        }
    }



    private func updateFilteredUsers() {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func selectUser(_ user: GetIdentityDTO) {
        selectedUser = user.id
        selectedUserName = user.name
        localRecordsRecord.identity = user
    }
}

struct RecorderSelectionPreSheet: View {
    @Environment(\.dismiss) private var dismiss

    var users: [GetIdentityDTO]
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
                            NavigationLink(destination: RecorderSelectionSheet(
                                users: attendanceManager.allParticipants(),
                                recordLang: record.lang,
                                meetingId: meetingId,
                                selectedUser: $selectedUser,
                                selectedUserName: $selectedUserName,
                                localRecordsRecord: $record
                            )) {
                                HStack {
                                    Text("Sprache:")
                                    Text(record.lang).bold()
                                    Spacer()
                                    Text(record.identity.name ?? "Keiner")
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
