import SwiftUI
import MeetingServiceDTOs

struct MeetingDetailView: View {
    var meeting: GetMeetingDTO
    
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    @StateObject private var recordManager = RecordManager() // RecordManager als StateObject
    @StateObject private var votingManager = VotingManager() // RecordManager als StateObject
    @StateObject private var attendanceManager = AttendanceManager() // RecordManager als StateObject
    
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
                            \(location.name)
                            \(location.street) \(location.number)\(location.letter)
                            \(location.postalCode ?? "") \(location.place ?? "")
                            """
                            Text(address)
                                .fixedSize(horizontal: false, vertical: true) // Ermöglicht Zeilenumbruch
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
                    }
                    
                    // Beschreibung
                    Section(header: Text("Beschreibung")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(meeting.description)
                        }
                    }
                    
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
//                            ForEach(votingManager.votings, id: \.id) { voting in
//                                NavigationLink(destination: AktivView(voting: voting, votingResults: nil, onBack: {
//                                    // Hier können Sie Aktionen definieren, die ausgeführt werden, wenn der Nutzer zurückgeht.
//                                    print("Zurück zur vorherigen Ansicht.")
//                                })) {
//                                    Text("\(voting.question)")
//                                }
//                            }
                            Text("Test")
                        }
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
        }

    }
}

struct PlaceholderView: View {
    var body: some View {
        Text("Hallo")
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
