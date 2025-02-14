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
import AuthServiceDTOs
import Foundation

struct RecorderSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss

    // Liste aller Benutzer
    var users: [GetIdentityDTO]
    
    // Sprache des Protokolls
    var recordLang: String
    
    // ID der Sitzung
    var meetingId: UUID

    // ausgewählter Benutzer für dieses Protokoll
    @Binding var selectedUser: UUID? // Speichert die Benutzer-ID
    @Binding var selectedUserName: String? // Speichert den Benutzernamen
    
    // ein lokale Kopie eines Protokolls um es mit Binding bearbeiten zu können
    @Binding var localRecordsRecord: GetRecordDTO

    @State private var searchText: String = "" // Das Suchfeld für die Benutzerliste
    @State private var filteredUsers: [GetIdentityDTO] = [] // Gefilterte Benutzer

    // ViewModel für Protokolle
    @StateObject private var recordManager = RecordManager()

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    userSelectionSection
                    informationSection
                }
                .navigationTitle("Benutzer auswählen")
                .searchable(text: $searchText) // Sucht beim Eintippen im Suchfeld
                .onChange(of: searchText) { _ in
                    updateFilteredUsers() // Filtert Benutzer bei Änderung des Suchtextes
                }
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
            initializeFilteredUsers() // Initialisieren der gefilterten Benutzer
        }
    }

    // Liste mit allen Benutzern
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
            // Bei dem User, der ausgewählt ist, wird ein blauer Haken angezeigt
            if user.id == localRecordsRecord.identity.id {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                selectUser(user) // Wählt den Benutzer aus
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

    // Protokoll speichern
    private func saveRecord() {
        Task {
            let patchDTO = PatchRecordDTO(identityId: selectedUser)
            await recordManager.patchRecordMeetingLang(patchRecordDTO: patchDTO, meetingId: meetingId, lang: recordLang)
        }
    }

    // Gefilterter User initialisieren
    private func initializeFilteredUsers() {
        filteredUsers = users // Zuerst alle Benutzer setzen
        let selectedUserId = localRecordsRecord.identity.id
        if let preselectedUser = users.first(where: { $0.id == selectedUserId }) {
            selectedUser = selectedUserId
            selectedUserName = preselectedUser.name
        }
    }

    private func updateFilteredUsers() {
        if searchText.isEmpty {
            filteredUsers = users // Wenn das Suchfeld leer ist, zeige alle Benutzer
        } else {
            filteredUsers = users.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText) // Filtere nach Namen
            }
        }
    }

    // User auswählen. Binding Variablen werden gesetzt
    private func selectUser(_ user: GetIdentityDTO) {
        selectedUser = user.id
        selectedUserName = user.name
        localRecordsRecord.identity = user
    }
}


