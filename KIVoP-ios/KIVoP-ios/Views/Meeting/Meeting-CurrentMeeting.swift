import SwiftUI
import MeetingServiceDTOs

struct CurrentMeetingView: View {
    var meeting: GetMeetingDTO
    
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
                    // ??????

//                        HStack{
//                            Image(systemName: "person.circle")
//                                .resizable()
//                                .frame(width: 30, height: 30)
//                                .foregroundColor(.gray)
//                            VStack(alignment: .leading) {
//                                Text("Franz")
//                                Text("Protokollant")
//                                    .font(.caption) // Kleiner Schriftgrad
//                                    .foregroundColor(.gray) // Graue Farbe
//                            }
//                        }
                    
                    // Beschreibung
                    Section(header: Text("Beschreibung")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(meeting.description)
                        }
                    }
                    
                    // Sitzung
//                    Section(header: Text("Sitzung")) {
//                        NavigationLink(destination: PlaceholderView()) {
//                            Text("Protokoll")
//                        }
//                        NavigationLink(destination: PlaceholderView()) {
//                            Text("Anwesenheit")
//                        }
//                    }
                }
            }.toolbar { // Toolbar hinzufügen
                ToolbarItem(placement: .navigationBarTrailing) { // Position auf der rechten Seite
                    Text("21.01.2024")
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
    CurrentMeetingView(meeting: exampleMeeting)
}
