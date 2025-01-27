import SwiftUI
import MeetingServiceDTOs

struct MeetingDetailView: View {
    var meeting: GetMeetingDTO
    @State var attendance: GetAttendanceDTO?
    
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    @StateObject private var recordManager = RecordManager() // RecordManager als StateObject
    @StateObject private var votingManager = VotingManager() // RecordManager als StateObject
    @StateObject private var attendanceManager = AttendanceManager() // RecordManager als StateObject
    @StateObject private var viewModel = AttendanceViewModel()
    
    @State var localRecords: [GetRecordDTO] = []
    
    private var uniqueRecorders: String {
        var uniqueNames = Set(localRecords.compactMap { $0.identity.name })
        return uniqueNames.sorted().joined(separator: ", ") // Namen durch Komma trennen und sortieren
    }
    
    private var recorderLabel: String {
        var recorderCount = Set(localRecords.compactMap { $0.identity.name }).count
        return recorderCount > 1 ? "Protokollanten" : "Protokollant" // Mehrzahl oder Einzahl je nach Anzahl
    }
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading){
                VStack {
                    Text(meeting.name)
                        .font(.title) // Setzt die Schriftgröße auf groß
                        .fontWeight(.bold) // Macht den Text fett
                        .foregroundColor(.primary) // Setzt die Farbe auf die primäre Farbe des Themas
                        .padding()
                } // Fügt etwas Abstand um den Text hinzu
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
                List {
                    // Adresse
                    if let location = meeting.location {
                        Section(header: Text("Adresse")) {
                            let address = """
                            \(location.street) \(location.number)\(location.letter)
                            \(location.postalCode ?? "") \(location.place ?? "")
                            """
                            Text(location.name)
                            if address != "" {
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
                    // Organiation
                    Section(header: Text("Organisation")) {
                        if let chair = meeting.chair {
                            HStack {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                                VStack(alignment: .leading) {
                                    Text(chair.name) // Dynamischer Vorsitzender
                                    Text("Sitzungsleiter")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
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
                                    //Text(selectedUserName ?? "Kein Protokollant")
                                    Text(uniqueRecorders)
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
                    
                    // Beschreibung
                    Section(header: Text("Beschreibung")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(meeting.description)
                        }
                    }
                    
                    Section(header: Text("Sitzung")) {
                        NavigationLink(destination: MeetingRecordsView(meeting: meeting)) {
                            Text("Protokolle")
                        }
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
                    // Abstimmugnen
                    Section(header: Text("Abstimmungen")) {
                        VotingSectionView(votingManager: votingManager)
                    }
                }
            }.toolbar { // Toolbar hinzufügen
                ToolbarItem(placement: .navigationBarTrailing) { // Position auf der rechten Seite
                    Text(DateTimeFormatter.formatDate(meeting.start))
                }
            }
                
            
        }
        .onAppear(){
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
    @ObservedObject var votingManager: VotingManager // Ersetze `VotingManager` durch den tatsächlichen Typ.
    
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
                NavigationLink(destination: Votings_VotingResultView(voting: voting
                )) {
                    Text("\(voting.question)")
                }
            }
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
    MeetingDetailView(meeting: exampleMeeting)
    //MeetingDetail()
}
