import SwiftUI
import MeetingServiceDTOs

struct MeetingDetailAdminView: View {
    var meeting: GetMeetingDTO
    
    @State private var isMeetingActive = false // Status für Meeting
    @State private var showConfirmationAlert = false // Alert anzeigen
    @State private var actionType: ActionType = .start // Typ der Aktion (Starten oder Beenden)
    
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    
    enum ActionType {
        case start
        case end
    }
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading){
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
                    HStack(spacing: 4) {
                        Image(systemName: "person.3.fill")
                        Text("8/12")
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
                    
                    // Sitzung
                    Section(header: Text("Sitzung")) {
                        NavigationLink(destination: PlaceholderView()) {
                            Text("Protokoll")
                        }
                        NavigationLink(destination: PlaceholderView()) {
                            Text("Anwesenheit")
                        }
                    }
                    
                    // Abstimmungen
                    Section(header: Text("Abstimmungen")) {
                        NavigationLink(destination: PlaceholderView()) {
                            HStack {
                                Text("Vereinsfarbe")
                                Spacer()
                                Image(systemName: "checkmark").foregroundColor(.blue)
                            }
                        }
                        NavigationLink(destination: PlaceholderView()) {
                            HStack {
                                Text("Abstimmung")
                                Spacer()
                                Image(systemName: "exclamationmark.arrow.circlepath").foregroundColor(.orange)
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
                        Text("21.01.2024")
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
                    },
                    secondaryButton: .cancel(Text("Abbrechen"))
                )
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
        print("Meeting gestartet!")
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
        print("Meeting beendet!")
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
    MeetingDetailAdminView(meeting: exampleMeeting)
}
