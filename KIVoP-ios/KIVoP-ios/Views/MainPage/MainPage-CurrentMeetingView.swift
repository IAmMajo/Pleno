import SwiftUI
import AuthServiceDTOs
import MeetingServiceDTOs

struct MainPageCurrentMeetingView: View {
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    
    var body: some View {
        NavigationStack {
            Spacer()
            // Box für Sitzung am unteren Rand
            if let currentMeeting = meetingManager.currentMeeting {
                VStack(alignment: .leading, spacing: 10) {
                    Text(currentMeeting.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.white)
                        Text(DateTimeFormatter.formatDate(currentMeeting.start))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("10") // Beispiel für Teilnehmeranzahl, aktualisiere je nach Daten
                                .foregroundColor(.white)
                            Image(systemName: "person.3")
                                .foregroundColor(.white)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.white)
                        Text(DateTimeFormatter.formatTime(currentMeeting.start))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    NavigationLink(destination: CurrentMeetingView(meeting: currentMeeting)) {
                        Button(action: {
                            // Aktion für aktuelle Sitzung
                            print("Navigiere zur aktuellen Sitzung \(currentMeeting.name)")
                        }) {
                            Text("Zur aktuellen Sitzung")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(UIColor.systemBackground))
                                .foregroundColor(.accentColor)
                                .cornerRadius(10)
                        }
                    }

                }
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(15)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                Button(action: {
                    meetingManager.fetchAllMeetings()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                        Text("Neu laden")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }.padding()
            } else {
                // Optionale Ansicht, wenn kein aktuelles Meeting verfügbar ist
                Text("Keine aktuelle Sitzung verfügbar")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Button(action: {
                    meetingManager.fetchAllMeetings()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)
                        Text("Neu laden")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }.padding()
            }
        }
        Spacer()
        
        
    }
}


#Preview {
    let exampleLocation1 = GetLocationDTO(
        id: UUID(),
        name: "Alte Turnhalle",
        street: "Altes Grab",
        number: "5",
        letter: "b",
        postalCode: "42069",
        place: "Hölle"
    )

    let exampleLocation2 = GetLocationDTO(
        id: UUID(),
        name: "Neues Gemeindehaus",
        street: "Hauptstraße",
        number: "10",
        letter: "a",
        postalCode: "12345",
        place: "Paradies"
    )

    let exampleChair1 = GetIdentityDTO(
        id: UUID(),
        name: "Heinz-Peters"
    )

    let exampleChair2 = GetIdentityDTO(
        id: UUID(),
        name: "Müller-Lüdenscheid"
    )

    let exampleMeeting1 = GetMeetingDTO(
        id: UUID(),
        name: "Jahreshauptversammlung",
        description: "Ein wichtiges Treffen für alle Mitglieder.",
        status: .scheduled,
        start: Date(),
        duration: 160,
        location: exampleLocation1,
        chair: exampleChair1,
        code: "MTG123"
    )

    let exampleMeeting2 = GetMeetingDTO(
        id: UUID(),
        name: "Vorstandssitzung",
        description: "Planung der nächsten Projekte.",
        status: .inSession,
        start: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        duration: 120,
        location: exampleLocation2,
        chair: exampleChair2,
        code: "MTG456"
    )

    let currentMeetings: [GetMeetingDTO] = [exampleMeeting1, exampleMeeting2]
    let currentMeeting: GetMeetingDTO = exampleMeeting1
    //MainPageCurrentMeetingView(exampleMeeting1)
}
