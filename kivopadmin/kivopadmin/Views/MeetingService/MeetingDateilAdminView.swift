import SwiftUI
import MeetingServiceDTOs
import AuthServiceDTOs

struct MeetingDetailAdminView: View {
    var meeting: GetMeetingDTO
    
    @State private var isMeetingActive = false // Status für Meeting
    @State private var showConfirmationAlert = false // Alert anzeigen
    @State private var actionType: ActionType = .start // Typ der Aktion (Starten oder Beenden)
    @State private var selectedUser: UUID?
    @State private var selectedUserName: String?
    @State private var showRecorderSelectionSheet = false
    
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    @StateObject private var recordManager = RecordManager() // RecordManager als StateObject
    @StateObject private var votingManager = VotingManager() // RecordManager als StateObject
    @StateObject private var attendanceManager = AttendanceManager() // RecordManager als StateObject
    @ObservedObject var userManager = UserManager()
    
    enum ActionType {
        case start
        case end
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack {
                    Text(meeting.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding()
                }
                
                HStack {
                    Text(meeting.start, style: .time)
                    if let duration = meeting.duration {
                        Text("(ca. \(duration) min.)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    HStack(spacing: 4) { // kleiner Abstand zwischen dem Symbol und der Personenanzahl
                        Image(systemName: "person.3.fill") // Symbol für eine Gruppe von Personen
                        if attendanceManager.isLoading {
                            Text("Loading...")
                        } else if let errorMessage = attendanceManager.errorMessage {
                            Text("Error: \(errorMessage)")
                        } else {
                            Text(attendanceManager.attendanceSummary())
                                .font(.headline)
                        }
                    }
                }.padding(.horizontal)
                
                List {
                    // Adresse
                    if let location = meeting.location {
                        Section(header: Text("Adresse")) {
                            let address = """
                            \(location.name)
                            \(location.street) \(location.number)\(location.letter)
                            \(location.postalCode ?? "") \(location.place ?? "")
                            """
                            Text(address)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    // Organisation
                    Section(header: Text("Organisation")) {
                        if let chair = meeting.chair {
                            HStack {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                                VStack(alignment: .leading) {
                                    Text(chair.name)
                                    Text("Sitzungsleiter")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    // Beschreibung
                    Section(header: Text("Beschreibung")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(meeting.description)
                        }
                    }
                    if meeting.status != .scheduled {
                        // Protokolle
                        Section(header: Text("Protokolle")) {
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
                                Button(action: {
                                    showRecorderSelectionSheet.toggle()
                                }) {
                                    if userManager.user == nil {
                                        HStack {
                                            Image(systemName: "person.circle")
                                            Text(selectedUserName ?? "Protokollanten auswählen")
                                                .cornerRadius(8)
                                        }
                                    } else {
                                        HStack {
                                            Image(systemName: "person.circle")
                                            Text(userManager.user?.name ?? "Protokollanten auswählen")
                                                .cornerRadius(8)
                                        }
                                    }

                                }
                            }

                        }
                    }

                    
                    
                    // Abstimmugnen
                    Section(header: Text("Abstimmungen")) {
                        if votingManager.isLoading {
                            ProgressView("Lade Abstimmungen...")
                                .progressViewStyle(CircularProgressViewStyle())
                        } else if let errorMessage = votingManager.errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        } else if votingManager.votings.isEmpty {
                            Text("Keine Abstimmungen gefunden.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(votingManager.votings, id: \.id) { voting in
                                NavigationLink(destination: AktivView(voting: voting, onBack: {
                                    // Hier können Sie Aktionen definieren, die ausgeführt werden, wenn der Nutzer zurückgeht.
                                    print("Zurück zur vorherigen Ansicht.")
                                })) {
                                    Text("\(voting.question)")
                                }
                            }
                        }
                    }

                    

                    
                    if let meetingCode = meeting.code {
                        // QR-Code
                        Section("Meeting-Code") {
                            HStack {
                                Spacer()
                                QRCodeImage(dataString: meetingCode)
                                    .frame(width: 400, height: 400)
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                Text(meetingCode)
                                Spacer()
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Button nur anzeigen, wenn das Meeting nicht "completed" ist
                if meeting.status != .completed {
                    Button(action: {
                        // Aktion basierend auf dem Status setzen
                        if meeting.status == .inSession {
                            actionType = .end
                        } else if meeting.status == .scheduled {
                            actionType = .start
                        }
                        showConfirmationAlert = true
                    }) {
                        Text(meeting.status == .inSession ? "Sitzung beenden" : "Sitzung starten")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(meeting.status == .inSession ? Color.red : Color.green)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // Bearbeitungsbutton
                        NavigationLink(destination: EditMeetingView(meeting: meeting)) {
                            Text("Bearbeiten")
                                .foregroundColor(.blue)
                        }
                        Text(DateTimeFormatter.formatDate(meeting.start))
                    }
                }
            }
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text(actionType == .start ? "Sitzung starten" : "Sitzung beenden"),
                    message: Text(actionType == .start ? "Möchten Sie die Sitzung wirklich starten?" : "Möchten Sie die Sitzung wirklich beenden?"),
                    primaryButton: .destructive(Text("Ja")) {
                        if actionType == .start {
                            startMeeting()
                        } else {
                            stopMeeting()
                        }
                        dismiss() // Schließt die View nach der Bestätigung
                    },
                    secondaryButton: .cancel(Text("Abbrechen"))
                )
            }
            .sheet(isPresented: $showRecorderSelectionSheet) {
                RecorderSelectionSheet(users: userManager.users, recordLang: recordManager.records.first?.lang, meetingId: meeting.id, selectedUser: $selectedUser, selectedUserName: $selectedUserName)
            }
            .onAppear(){
                recordManager.getRecordsMeeting(meetingId: meeting.id)
                votingManager.getRecordsMeeting(meetingId: meeting.id)
                attendanceManager.fetchAttendances(meetingId: meeting.id)
                userManager.fetchUsers()
                if let userId = recordManager.records.first?.identity.id {
                    userManager.getUser(userId: userId)
                }

                
            }
        }
    }
    
    // Funktion zum Starten des Meetings
    func startMeeting() {
        meetingManager.startMeeting(meetingId: meeting.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    isMeetingActive = true
                    print("Meeting erfolgreich gestartet!")
                case .failure(let error):
                    print("Fehler beim Starten des Meetings: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Funktion zum Beenden des Meetings
    func stopMeeting() {
        meetingManager.endMeeting(meetingId: meeting.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    isMeetingActive = false
                    print("Meeting erfolgreich beendet!")
                case .failure(let error):
                    print("Fehler beim Starten des Meetings: \(error.localizedDescription)")
                }
            }
        }
    }
}
struct RecorderSelectionSheet: View {
    var users: [UserProfileDTO]
    var recordLang: String?
    var meetingId: UUID
    @Binding var selectedUser: UUID? // Speichert die Benutzer-ID
    @Binding var selectedUserName: String? // Speichert den Benutzernamen
    @State private var searchText: String = ""
    
    @ObservedObject var userManager = UserManager()
    @StateObject private var recordManager = RecordManager()

    var body: some View {
        NavigationStack { // NavigationStack hier außen
            VStack {
                List {
                    ForEach(filteredUsers, id: \.email) { user in
                        HStack {
                            Text(user.name ?? "Unbekannter Name") // Fallback, falls name nil ist
                            Spacer()
                            if let uid = user.uid, uid == selectedUser { // Prüfen, ob dieser Benutzer ausgewählt ist
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectUser(user)
                        }
                    }
                }
                .navigationTitle("Benutzer auswählen")
                .searchable(text: $searchText)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Fertig") {
                            print("Ausgewählter Benutzer: \(selectedUserName ?? "Keiner")")
                            saveRecord()
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            userManager.fetchUsers()
        }
    }
    private func saveRecord() {
        Task {
            let patchDTO = PatchRecordDTO(identityId: selectedUser)
            await recordManager.patchRecordMeetingLang(patchRecordDTO: patchDTO, meetingId: meetingId, lang: recordLang ?? "DE")
        }
    }
    

    private var filteredUsers: [UserProfileDTO] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { user in
                if let name = user.name {
                    return name.localizedCaseInsensitiveContains(searchText)
                }
                return false
            }
        }
    }

    private func selectUser(_ user: UserProfileDTO) {
        if let uid = user.uid {
            // Wenn derselbe Benutzer ausgewählt ist, entfernen; ansonsten neu setzen
            if selectedUser == uid {
                selectedUser = nil
                selectedUserName = nil
            } else {
                selectedUser = uid
                selectedUserName = user.name
            }
        }
    }

    private func dismiss() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.dismiss(animated: true, completion: nil)
        }
    }
}



#Preview {
    let exampleLocation = GetLocationDTO(
        id: UUID(),
        name: "Alte Turnhalle",
        street: "Altes Grab",
        number: "5",
        letter: "b",
        postalCode: "42069",
        place: "Hölle"
    )
    
    let exampleChair = GetIdentityDTO(
        id: UUID(),
        name: "Heinz-Peters"
    )
    
    let exampleMeeting = GetMeetingDTO(
        id: UUID(),
        name: "Jahreshauptversammlung",
        description: "Ein wichtiges Treffen für alle Mitglieder.",
        status: .scheduled,
        start: Date(),
        duration: 160,
        location: exampleLocation,
        chair: exampleChair,
        code: "MTG123"
    )
    MeetingDetailAdminView(meeting: exampleMeeting)
}
