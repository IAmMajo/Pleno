// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs
import AuthServiceDTOs

struct MeetingDetailAdminView: View {
    // Beim View Aufruf wird eine Sitzung übergeben
    var meeting: GetMeetingDTO
    
    @State private var isMeetingActive = false // Status für Meeting, entscheidend für die Funktion, die durch den Button ausgelöst wird
    @State private var showConfirmationAlert = false // Alert anzeigen
    @State private var actionType: ActionType = .start // Typ der Aktion (Starten oder Beenden) -> wichtig für die Alert-Anzeige
    
    // Kopie des Arrays der Protokolle erstellen, um es bearbeiten zu können, um die Protokollanten zu ändern
    @State var localRecords: [GetRecordDTO] = []
    
    // Sheet für die Auswahl der Protokollanten
    @State private var showRecorderSelectionSheet = false
    
    // ViewModels für die Anzeige der verschiedenen Informationen über eine Sitzung
    @StateObject private var meetingManager = MeetingManager()
    @StateObject private var recordManager = RecordManager()
    @StateObject private var votingManager = VotingManager()
    @StateObject private var attendanceManager = AttendanceManager()
    @ObservedObject var userManager = UserManager()
    
    // AttandanceViewModel: Wird hier anders behandelt, da es aus der iOS-Anwendung kopiert wurde
    @StateObject private var viewModel = AttendanceViewModel()
    
    // Fallunterscheidung ob eine Sitzung beendet oder gestartet werden soll
    enum ActionType {
        case start
        case end
    }
    
    // Liefert alle unterschiedlichen Protokollanten einer Sitzung
    private var uniqueRecorders: String {
        let uniqueNames = Set(localRecords.compactMap { $0.identity.name })
        return uniqueNames.sorted().joined(separator: ", ") // Namen durch Komma trennen und sortieren
    }
    
    // Liefert die Überschrift der Anzeige der Protokollanten (Einzahl/Mehrzahl)
    private var recorderLabel: String {
        let recorderCount = Set(localRecords.compactMap { $0.identity.name }).count
        return recorderCount > 1 ? "Protokollanten" : "Protokollant" // Mehrzahl oder Einzahl je nach Anzahl
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                nameSection
                
                // Teilnehmer-Information
                attendanceInfoSection
                
                List {
                    // Adresse
                    locationSection
                    
                    // Sitzungsleiter und Protokollanten
                    organizationSection
                    
                    // Beschreibung
                    Section(header: Text("Beschreibung")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(meeting.description)
                        }
                    }
                    
                    // Status über eigene Teilnahme und Link zur Übersicht aller Teilnehmer
                    attendanceSection
                    
                    // Wenn das Meeting läuft oder beendet wurde, werden Protokolle und Abstimmungen angezeigt
                    if meeting.status != .scheduled {
                        // Protokolle
                        recordSection
                        // Abstimmugnen
                        votingSection
                    }
                    
                    // QR-Code anzeige
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
                        // Fallunterscheidung: Sitzung starten oder beenden?
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
                // Wenn die Sitzung noch nicht angefangen hat, kann die Sitzung bearbeitet werden
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
            // Nutzer muss das Beenden oder Starten der Sitzung bestätigen
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
            // Sheet, um den Protokollanten auszuwählen
            .sheet(isPresented: $showRecorderSelectionSheet) {
                // Link zum Übersicht aller Sprachen, dort muss eine Sprache ausgewählt werden, woraufhin der Protokollant festgelegt werden kann
                RecorderSelectionPreSheet(
                    users: attendanceManager.allParticipants(),
                    meetingId: meeting.id,
                    localRecords: $localRecords,  // Hier übergibst du das Binding
                    attendanceManager: attendanceManager
                )
            }
            .onAppear(){
                Task {
                    // Funktion, um die beim Öffnen der View aufgerufen wird
                    await loadView()
                }
            }
        }
    }
    
    private func loadView() async {
        do {
            // 1. Abrufen der Meeting-Daten für die Protokolle
            recordManager.getRecordsMeeting(meetingId: meeting.id)
            
            // 2. Abrufen der Abstimmungs-Daten für die Sitzung
            votingManager.getRecordsMeeting(meetingId: meeting.id)
            
            // 3. Abrufen der Teilnehmer-Daten für die Sitzung
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
            // Startzeit
            Text(meeting.start, style: .time)
            
            // Dauer der Sitzung
            if let duration = meeting.duration {
                Text("(ca. \(duration) min.)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            // Personenanzahl anzeigen: Bsp: "6/9"
            HStack(spacing: 4) { // kleiner Abstand zwischen dem Symbol und der Personenanzahl
                Image(systemName: "person.3.fill") // Symbol für eine Gruppe von Personen
                if attendanceManager.isLoading {
                    Text("Lädt...")
                } else if let errorMessage = attendanceManager.errorMessage {
                    Text("Error: \(errorMessage)")
                } else {
                    // Zusammenfassung wird im ViewModel erstellt
                    Text(attendanceManager.attendanceSummary())
                        .font(.headline)
                }
            }
        }.padding(.horizontal)
    }
    
    // Abschnitt für die Adresse
    private var locationSection: some View {
        Group {
            if let location = meeting.location {
                Section(header: Text("Adresse")) {
                    // Adresse wird zusammengebaut
                    let address = """
                    \(location.street) \(location.number)\(location.letter)
                    \(location.postalCode ?? "") \(location.place ?? "")
                    """
                    Text(location.name)
                    if address != "" {
                        // Adresse ist kopierbar
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
    // Sitzungsleiter und Protokollant
    private var organizationSection: some View {
        Group {
            // Wird nur angezeigt, wenn die Sitzung läuft oder beendet wurde
            if meeting.status != .scheduled {
                Section(header: Text("Organisation")) {
                    // Sitzungsleiter
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
                    
                    // Protokollanten
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
                        // bei Klick auf die Zeile wird das Sheet zum anpassen der Protokollanten angezeigt
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
                                        Text(uniqueRecorders) // unterschiedliche Protokollanten werden hier aufgelistet
                                        Text(recorderLabel) // "Protokollant" oder "Protokollanten"
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
    // Übersicht der Anwesenheiten
    private var attendanceSection: some View {
        Section(header: Text("Anwesenheit")){
            // Link zur Übersicht über alle Teilnehmer
            NavigationLink(destination: viewModel.destinationView(for: meeting)) {
                HStack{
                    Text("Anwesenheit")
                    Spacer()
                    
                    // Logik für die Symbolauswahl. Bei vergangenen Terminen gibt es kein Kalender Symbol. Wenn dort der Status noch nicht gesetzt ist, hat man am Meeting nicht teilgenommen.
                    // Statusanzeige über eigene Teilnahme
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
    
    // Übersicht über alle Protokolle
    private var recordSection: some View {
        Section(header: Text("Protokolle")) {
            if recordManager.isLoading {
                ProgressView("Lade Protokolle...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let errorMessage = recordManager.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else if recordManager.records.isEmpty {
                Text("Keine Protokolle verfügbar.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(recordManager.records, id: \.lang) { record in
                    NavigationLink(destination: MarkdownEditorView(meetingId: record.meetingId, lang: record.lang)) {
                        // Protokoll mit Sprache anzeigen
                        HStack{
                            Text("Protokoll auf ")
                            Text(LanguageManager.getLanguage(langCode: record.lang)).bold()
                        }
                    }

                }
            }

        }
    }
    
    // Übersicht über alle Abstimmungen, die in einer Sitzung durchgeführt wurden
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
                        // On Back wird von AktivView gefordet.
                        print("Zurück zur vorherigen Ansicht.")
                    })) {
                        Text("\(voting.question)")
                    }
                }
            }
        }
    }
    
    // QR Code Ansicht
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

