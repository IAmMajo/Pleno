import SwiftUI
import MeetingServiceDTOs
import AuthServiceDTOs

struct MeetingDetailAdminView: View {
    var meeting: GetMeetingDTO
    
    @State private var isMeetingActive = false // Status für Meeting
    @State private var showConfirmationAlert = false // Alert anzeigen
    @State private var actionType: ActionType = .start // Typ der Aktion (Starten oder Beenden)
    @State var localRecords: [GetRecordDTO] = []
    @State private var showRecorderSelectionSheet = false
    @State private var recordLanguages: [String] = []
    
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    @StateObject private var recordManager = RecordManager() // RecordManager als StateObject
    @StateObject private var votingManager = VotingManager() // RecordManager als StateObject
    @StateObject private var attendanceManager = AttendanceManager() // RecordManager als StateObject
    @ObservedObject var userManager = UserManager()
    @StateObject private var viewModel = AttendanceViewModel()
    
    enum ActionType {
        case start
        case end
    }
    
    private var uniqueRecorders: String {
        let uniqueNames = Set(localRecords.compactMap { $0.identity.name })
        return uniqueNames.sorted().joined(separator: ", ") // Namen durch Komma trennen und sortieren
    }
    
    private var recorderLabel: String {
        let recorderCount = Set(localRecords.compactMap { $0.identity.name }).count
        return recorderCount > 1 ? "Protokollanten" : "Protokollant" // Mehrzahl oder Einzahl je nach Anzahl
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                nameSection
                
                attendanceInfoSection
                
                List {
                    // Adresse
                    locationSection
                    
                    organizationSection
                    
                    // Beschreibung
                    Section(header: Text("Beschreibung")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(meeting.description)
                        }
                    }
                    attendanceSection
                    if meeting.status != .scheduled {
                        // Protokolle
                        recordSection
                        // Abstimmugnen
                        votingSection
                    }
                    qrCodeSection

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
                if meeting.status == .scheduled {
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
                RecorderSelectionPreSheet(
                    users: attendanceManager.allParticipants(),
                    meetingId: meeting.id,
                    localRecords: $localRecords,  // Hier übergibst du das Binding
                    attendanceManager: attendanceManager
                )
            }
            .onAppear(){
                updateMeeting { result in
                    switch result {
                    case .success(let meetingData):
                        print("Meeting erfolgreich aktualisiert: \(meetingData)")
                    case .failure(let error):
                        print("Fehler beim Aktualisieren des Meetings: \(error.localizedDescription)")
                    }
                }
                Task {
                    await loadView()
                    // Array mit allen verügbaren Sprachen, um allen Sprachen den gleichen Protokollanten zuzuordnen
                    recordLanguages = recordManager.records.map { $0.lang }
                    recordLanguages = Array(Set(recordLanguages)) // Entfernt Duplikate, falls nötig
                }
            }
        }
    }
    private func getLanguage(langCode: String) -> String {
        let languages: [(name: String, code: String)] = [
            ("Arabisch", "ar"),
            ("Chinesisch", "zh"),
            ("Dänisch", "da"),
            ("Deutsch", "de"),
            ("Englisch", "en"),
            ("Französisch", "fr"),
            ("Griechisch", "el"),
            ("Hindi", "hi"),
            ("Italienisch", "it"),
            ("Japanisch", "ja"),
            ("Koreanisch", "ko"),
            ("Niederländisch", "nl"),
            ("Norwegisch", "no"),
            ("Polnisch", "pl"),
            ("Portugiesisch", "pt"),
            ("Rumänisch", "ro"), // Hinzugefügt
            ("Russisch", "ru"),
            ("Schwedisch", "sv"),
            ("Spanisch", "es"),
            ("Thai", "th"), // Hinzugefügt
            ("Türkisch", "tr"),
            ("Ungarisch", "hu")
        ]


        // Suche nach dem Kürzel und gib den Namen zurück
        if let language = languages.first(where: { $0.code == langCode }) {
            return language.name
        }

        // Standardwert, falls das Kürzel nicht gefunden wird
        return langCode
    }
    
    private func loadView() async {
        do {
            // 1. Abrufen der Meeting-Daten für die Records
            recordManager.getRecordsMeeting(meetingId: meeting.id)
            
            // 2. Abrufen der Voting-Daten für das Meeting
            votingManager.getRecordsMeeting(meetingId: meeting.id)
            
            // 3. Abrufen der Teilnehmer-Daten für das Meeting
            attendanceManager.fetchAttendances(meetingId: meeting.id)
            
            // 4. Abrufen der Benutzer
            userManager.fetchUsers()
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
    
    func updateMeeting(completion: @escaping (Result<GetMeetingDTO, Error>) -> Void) {
        meetingManager.getSingleMeeting(meetingId: meeting.id) { result in
            switch result {
            case .success(let meetingData):
                // Übergib die empfangenen Daten an den Completion-Handler
                completion(.success(meetingData))
            case .failure(let error):
                // Übergib den Fehler an den Completion-Handler
                completion(.failure(error))
            }
        }
    }
}

extension MeetingDetailAdminView {
    private var nameSection: some View {
        VStack {
            Text(meeting.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding()
        }
    }
    
    private var attendanceInfoSection: some View {
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
    }
    
    private var locationSection: some View {
        Group {
            if let location = meeting.location {
                Section(header: Text("Adresse")) {
                    let address = """
                    \(location.street) \(location.number)\(location.letter)
                    \(location.postalCode ?? "") \(location.place ?? "")
                    """
                    Text(location.name)
                    if address != "" {
                        Button(action: {
                            UIPasteboard.general.string = address
                        }) {
                            HStack {
                                Text(address)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                Image(systemName: "doc.on.doc").foregroundColor(.blue)
                            }
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    private var organizationSection: some View {
        Group {
            if meeting.status != .scheduled {
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
                    
                    if recordManager.isLoading {
                        ProgressView("Lade Protokolle...")
                            .progressViewStyle(CircularProgressViewStyle())
                    } else if let errorMessage = recordManager.errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else if recordManager.records.isEmpty {
                        Text("Keine Protokolle verfügbar")
                            .foregroundColor(.secondary)
                    } else {
                        Button(action: {
                            showRecorderSelectionSheet.toggle()
                        }) {
                            HStack {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.gray)
                                    VStack(alignment: .leading) {
                                        Text(uniqueRecorders)
                                        Text(recorderLabel)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                                Text("Ändern").foregroundStyle(.blue)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            localRecords = recordManager.records
                        }
                    }
                }
            }
        }
    }
    private var attendanceSection: some View {
        Section(header: Text("Anwesenheit")){
            NavigationLink(destination: viewModel.destinationView(for: meeting)) {
                HStack{
                    Text("Anwesenheit")
                    Spacer()
                    
                    // Logik für die Symbolauswahl. Bei vergangenen Terminen gibt es kein Kalender Symbol. Wenn dort der Status noch nicht gesetzt ist, hat man am Meeting nicht teilgenommen.
                    Image(systemName: {
                        switch meeting.myAttendanceStatus {
                        case .accepted, .present:
                            return "checkmark.circle"
                        case .absent:
                            return "xmark.circle"
                        default:
                            return viewModel.selectedTab == 0 ? "xmark.circle" : "calendar"
                        }
                    }())
                    .foregroundColor({
                        switch meeting.myAttendanceStatus {
                        case .accepted, .present:
                            return .blue
                        case .absent:
                            return .red
                        default:
                            return viewModel.selectedTab == 0 ? .red : .orange
                        }
                    }())
                    .font(.system(size: 18))
                }
            }
        }
    }
    
    private var recordSection: some View {
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
                        HStack{
                            Text("Protokoll auf ")
                            Text(getLanguage(langCode: record.lang)).bold()
                        }
                    }

                }
            }

        }
    }
    
    private var votingSection: some View {
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
    }
    
    private var qrCodeSection: some View {
        Group {
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
    }

}

