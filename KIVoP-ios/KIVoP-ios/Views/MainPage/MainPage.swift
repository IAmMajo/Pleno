import SwiftUI
import MeetingServiceDTOs

struct MainPage: View {
    @State private var Name: String = "Max Mustermann"
    @State private var ShortName: String = "MM"
    @State private var Meeting: String = "Jahreshauptversammlung"
    private var User: String {
        Name.components(separatedBy: " ").first ?? ""
    }

    var body: some View {
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

            // Beispielmeetings erstellen
            let exampleMeetings = [
                GetMeetingDTO(
                    id: UUID(),
                    name: "Vorstandsitzung Januar",
                    description: "Eröffnung des Jahres.",
                    status: .scheduled,
                    start: Date().addingTimeInterval(86400 * 30), // In 30 Tagen
                    duration: 120,
                    location: exampleLocation,
                    chair: exampleChair,
                    code: "MTG001"
                ),
                GetMeetingDTO(
                    id: UUID(),
                    name: "Strategiemeeting",
                    description: "Langfristige Planung.",
                    status: .scheduled,
                    start: Date().addingTimeInterval(86400 * 60), // In 60 Tagen
                    duration: 90,
                    location: exampleLocation,
                    chair: exampleChair,
                    code: "MTG002"
                ),
                GetMeetingDTO(
                    id: UUID(),
                    name: "Finanzreview",
                    description: "Rückblick auf das Budget.",
                    status: .completed,
                    start: Date().addingTimeInterval(-86400 * 10), // Vor 10 Tagen
                    duration: 90,
                    location: exampleLocation,
                    chair: exampleChair,
                    code: "MTG003"
                ),
                GetMeetingDTO(
                    id: UUID(),
                    name: "Abschlussmeeting Q4",
                    description: "Evaluation des Quartals.",
                    status: .completed,
                    start: Date().addingTimeInterval(-86400 * 20), // Vor 20 Tagen
                    duration: 120,
                    location: exampleLocation,
                    chair: exampleChair,
                    code: "MTG004"
                ),
                GetMeetingDTO(
                    id: UUID(),
                    name: "Jahreshauptversammlung",
                    description: "Alle Mitglieder treffen sich.",
                    status: .inSession,
                    start: Date(), // Heute
                    duration: 240,
                    location: exampleLocation,
                    chair: exampleChair,
                    code: "MTG005"
                ),
                GetMeetingDTO(
                    id: UUID(),
                    name: "Kickoff 2024",
                    description: "Start ins neue Jahr.",
                    status: .scheduled,
                    start: Date().addingTimeInterval(86400 * 5), // In 5 Tagen
                    duration: 180,
                    location: exampleLocation,
                    chair: exampleChair,
                    code: "MTG006"
                ),
                GetMeetingDTO(
                    id: UUID(),
                    name: "Marketingmeeting",
                    description: "Planung der Kampagnen.",
                    status: .completed,
                    start: Date().addingTimeInterval(-86400 * 40), // Vor 40 Tagen
                    duration: 150,
                    location: exampleLocation,
                    chair: exampleChair,
                    code: "MTG007"
                ),
                GetMeetingDTO(
                    id: UUID(),
                    name: "Krisenbesprechung",
                    description: "Schnelle Reaktion erforderlich.",
                    status: .inSession,
                    start: Date(), // Heute
                    duration: 60,
                    location: exampleLocation,
                    chair: exampleChair,
                    code: "MTG008"
                ),
                GetMeetingDTO(
                    id: UUID(),
                    name: "Treffen mit Partnern",
                    description: "Austausch und Networking.",
                    status: .scheduled,
                    start: Date().addingTimeInterval(86400 * 15), // In 15 Tagen
                    duration: 180,
                    location: exampleLocation,
                    chair: exampleChair,
                    code: "MTG009"
                ),
                GetMeetingDTO(
                    id: UUID(),
                    name: "Jubiläumssitzung",
                    description: "Feier des 10-jährigen Bestehens.",
                    status: .completed,
                    start: Date().addingTimeInterval(-86400 * 70), // Vor 70 Tagen
                    duration: 200,
                    location: exampleLocation,
                    chair: exampleChair,
                    code: "MTG010"
                ),
                // Das zusätzliche Meeting
                GetMeetingDTO(
                    id: UUID(),
                    name: "Team-Besprechung",
                    description: "Wöchentliche Besprechung des Teams.",
                    status: .inSession,
                    start: Date(), // Heute
                    duration: 90,
                    location: exampleLocation,
                    chair: exampleChair,
                    code: "MTG011"
                )
            ]
        
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Greeting
                Text("Hallo, \(User)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                    .padding([.top, .leading], 20)
                
                // Profile Information
                NavigationLink(destination: MainPage_ProfilView()) {
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 50, height: 50)
                            .overlay(Text(ShortName).foregroundColor(.white))
                        
                        VStack(alignment: .leading) {
                            Text(Name)
                                .font(.headline)
                                .foregroundColor(Color.primary)
                            Text("Profil und Vereinsinformationen")
                                .font(.subheadline)
                                .foregroundColor(Color.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(15)
                    .padding(.horizontal,10)
                    .padding(10)
                }
                
                // Options in einer Liste
                List {
                    // Einzeloption Sitzungen
                    Section {
                       NavigationLink(destination: MeetingView(meetings: exampleMeetings)) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.accentColor)
                                Text("Sitzungen")
                                    .foregroundColor(Color.primary)
                            }
                        }
                    }
                    
                    // Zusätzliche Optionen
                    Section {
                        NavigationLink(destination: VotingsView()) {
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(.accentColor)
                                Text("Abstimmungen")
                                    .foregroundColor(Color.primary)
                            }
                        }
                        
                        NavigationLink(destination: ProtokolleView()) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.accentColor)
                                Text("Protokolle")
                                    .foregroundColor(Color.primary)
                            }
                        }
                        
                        NavigationLink(destination: AnwesenheitView()) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                                    .foregroundColor(.accentColor)
                                Text("Anwesenheit")
                                    .foregroundColor(Color.primary)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color.clear)
                .padding(.top, -10)
                
                Spacer()
                
                // Meeting Box
                VStack(alignment: .leading, spacing: 10) {
                    Text(Meeting)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.white)
                        Text("21.01.2024")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("10")
                                .foregroundColor(.white)
                            Image(systemName: "person.3")
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 10)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.white)
                        Text("18:06")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    
                    Button(action: {
                        // Aktion für aktuelles Meeting
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
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }.navigationBarHidden(true) // Verstecken von navigation bar und back button

    }
}

// Sample Views für die anderen Punkte nach hinzufügen bitte löschen!!!

struct ProtokolleView: View {
    var body: some View {
        Text("Protokolle")
            .font(.largeTitle)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
