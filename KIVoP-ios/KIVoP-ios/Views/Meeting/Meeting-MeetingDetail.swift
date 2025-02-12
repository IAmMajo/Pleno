import SwiftUI
import MeetingServiceDTOs

struct MeetingDetailView: View {
    
    // Sitzung wird der View übergeben
    var meeting: GetMeetingDTO
    
    // gibt die eigene Teilnahme an
    @State var attendance: GetAttendanceDTO?
    
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    @StateObject private var recordManager = RecordManager() // RecordManager als StateObject
    @StateObject private var votingManager = VotingManager() // VotingManager als StateObject
    @StateObject private var attendanceManager = AttendanceManager() // AttandanceManager als StateObject
    @StateObject private var viewModel = AttendanceViewModel() // viewModel für die eigene Teilnahme
    
    // Lokale der Kopie der Protokolle
    @State var localRecords: [GetRecordDTO] = []
    
    // Unterschiedliche Namen der Protokolle filtern
    private var uniqueRecorders: String {
        var uniqueNames = Set(localRecords.compactMap { $0.identity.name })
        return uniqueNames.sorted().joined(separator: ", ") // Namen durch Komma trennen und sortieren
    }
    
    // Unterschrift unter Namen der Protokollanten -> entscheidet über Einzahl oder Mehrzahl
    private var recorderLabel: String {
        var recorderCount = Set(localRecords.compactMap { $0.identity.name }).count
        return recorderCount > 1 ? "Protokollanten" : "Protokollant" // Mehrzahl oder Einzahl je nach Anzahl
    }
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading){
                // Name der Sitzung
                meetingName(meeting: meeting)
                
                // Uhrzeit und Anwesenheit
                meetingHeader(meeting: meeting)
                
                List {
                    // Adresse
                    adresse(meeting: meeting)
                    
                    // Organiation
                    Section(header: Text("Organisation")) {
                        // Sitzungsleiter
                        chair(meeting: meeting)
                        
                        // Protokollanten
                        recorder()
                    }
                    
                    // Beschreibung
                    Section(header: Text("Beschreibung")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(meeting.description)
                        }
                    }
                    
                    Section(header: Text("Sitzung")) {
                        // Link zu den Protokollen
                        NavigationLink(destination: MeetingRecordsView(meeting: meeting)) {
                            Text("Protokolle")
                        }
                        
                        // Link zu Anwesenheiten
                        anwesenheit(meeting: meeting)
                    }
                    // Abstimmugnen
                    Section(header: Text("Abstimmungen")) {
                        VotingSectionView(votingManager: votingManager)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(DateTimeFormatter.formatDate(meeting.start))
                }
            }

                
            
        }
        .onAppear(){
            // Beim Aufruf der View werden alle nötigen Informationen geladen
            recordManager.getRecordsMeeting(meetingId: meeting.id)
            votingManager.getVotingsMeeting(meetingId: meeting.id)
            attendanceManager.fetchAttendances(meetingId: meeting.id)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let attendance = attendanceManager.attendances.first(where: { $0.itsame == true }) {
                    self.attendance = attendance
                }
            }

        }
        .refreshable {
            recordManager.getRecordsMeeting(meetingId: meeting.id)
            votingManager.getVotingsMeeting(meetingId: meeting.id)
            attendanceManager.fetchAttendances(meetingId: meeting.id)
        }
    }
}

struct VotingSectionView: View {
    @ObservedObject var votingManager: VotingManager
    
   // var voting: GetVotingDTO

    var body: some View {
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
                // Link zu dieser Abstimmung
                NavigationLink(destination: Votings_VotingResultView(voting: voting
                )) {
                    Text("\(voting.question)")
                }
            }
        }
            
        
    }
}

extension MeetingDetailView {
    private func meetingName(meeting: GetMeetingDTO) -> some View {
        VStack {
            Text(meeting.name)
                .font(.title) // Setzt die Schriftgröße auf groß
                .fontWeight(.bold) // Macht den Text fett
                .foregroundColor(.primary) // Setzt die Farbe auf die primäre Farbe des Themas
                .padding()
        } // Fügt etwas Abstand um den Text hinzu
    }
    
    private func meetingHeader(meeting: GetMeetingDTO) -> some View {
        HStack{
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
    
    private func adresse(meeting: GetMeetingDTO) -> some View {
        Group{
            if let location = meeting.location {
                Section(header: Text("Adresse")) {
                    let address = """
                    \(location.street) \(location.number)\(location.letter)
                    \(location.postalCode ?? "") \(location.place ?? "")
                    """
                    Text(location.name)
                    if address != "" {
                        // Adresse ist kopierbar
                        Button(action: {
                            UIPasteboard.general.string = address // Text in die Zwischenablage kopieren
                        }) {
                            HStack{
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
    
    // Sitzungsleiter
    private func chair(meeting: GetMeetingDTO) -> some View {
        Group{
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
    }
    
    // Protokollanten
    private func recorder() -> some View {
        Group{
            if recordManager.isLoading {
                ProgressView("Lade Protokollanten...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let errorMessage = recordManager.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else if recordManager.records.isEmpty {
                Text("Keine Protokollanten gefunden.")
                    .foregroundColor(.secondary)
            } else {
                HStack {
                    Image(systemName: "doc.text")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)
                    VStack(alignment: .leading) {
                        // Namen aller Protokollanten
                        Text(uniqueRecorders)
                        
                        // "Protokollant" oder "Protokollanten"
                        Text(recorderLabel)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .onAppear(){
                    localRecords = recordManager.records
                }
                
            }
        }
    }
    
    // Anwesenheiten
    private func anwesenheit(meeting: GetMeetingDTO) -> some View {
        NavigationLink(destination: viewModel.destinationView(for: meeting)) {
            HStack{
                Text("Anwesenheit")
                Spacer()
                // Logik für die Symbolauswahl. Bei vergangenen Terminen gibt es kein Kalender Symbol. Wenn dort der Status noch nicht gesetzt ist, hat man am Meeting nicht teilgenommen.
                Image(systemName: {
                    switch attendance?.status {
                    case .accepted, .present:
                        return "checkmark.circle"
                    case .absent:
                        return "xmark.circle"
                    default:
                        return meeting.status == .completed ? "xmark" : "calendar"
                    }
                }())
                .foregroundColor({
                    switch attendance?.status {
                    case .accepted, .present:
                        return .blue
                    case .absent:
                        return .red
                    default:
                        return meeting.status == .completed ? .red : .orange
                    }
                }())
                .font(.system(size: 18))
            }
        }
    }
}
