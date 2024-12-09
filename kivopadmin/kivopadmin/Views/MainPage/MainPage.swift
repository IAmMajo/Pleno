import SwiftUI

struct MainPage: View {
    @State private var name: String = ""
    @State private var shortName: String = "V"
    @State private var meeting: String = ""
    @State private var meetingDate: String = ""
    @State private var meetingTime: String = ""
    @State private var attendeesCount: Int = 0
    @State private var meetingExists: Bool = false
    @State private var selectedView: SidebarOption = .nutzerverwaltung
    @State private var isAdminExpanded: Bool = true
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    
    private var User: String {
        Name.components(separatedBy: " ").first ?? ""
    }
    
    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Seitenleiste
                VStack(alignment: .leading, spacing: 0) {
                    // Begrüßungsbereich
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hallo Admin, \(name.components(separatedBy: " ").first ?? "Admin")")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)

                        HStack {
                            Text("Adminbereich")
                                .font(.caption)
                                .bold()
                                .foregroundColor(Color.secondary)

                            Spacer()

                            Button(action: {
                                isAdminExpanded.toggle()
                            }) {
                                Image(systemName: isAdminExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)

                    // Einklappbarer Adminbereich
                    if isAdminExpanded {
                        // Bereich für "Vereinseinstellungen"
                        Button(action: {
                            selectedView = .vereinseinstellungen
                        }) {
                            HStack(spacing: 15) {
                                Circle()
                                    .fill(Color.gray.opacity(0.8))
                                    .frame(width: 50, height: 50)
                                    .overlay(Text(shortName).foregroundColor(.white).font(.caption))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Vereinseinstellungen")
                                        .font(.headline)
                                        .foregroundColor(Color.primary)
                                    Text("Übersicht und Verwaltung")
                                        .font(.subheadline)
                                        .lineLimit(1)
                                        .foregroundColor(Color.secondary)
                                }

                                Spacer()

                                Image(systemName: selectedView == .vereinseinstellungen ? "chevron.down" : "chevron.right")
                                    .foregroundColor(Color.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground)) // Hintergrund für Dark- und Light-Mode
                            .cornerRadius(15)
                            .padding(.bottom, 10)
                        }

                        // Optionen in der Seitenleiste
                        VStack(alignment: .leading, spacing: 15) {
                            Button(action: {
                                selectedView = .nutzerverwaltung
                            }) {
                                sidebarButton(icon: "person.3.fill", title: "Nutzerverwaltung", isSelected: selectedView == .nutzerverwaltung)
                            }

                            Button(action: {
                                selectedView = .funktionen
                            }) {
                                sidebarButton(icon: "gearshape.fill", title: "Konfiguration der Funktionen", isSelected: selectedView == .funktionen)
                            }

                            Button(action: {
                                selectedView = .umfrage
                            }) {
                                sidebarButton(icon: "chart.bar.fill", title: "Umfragen", isSelected: selectedView == .umfrage)
                            }
                            .padding(.horizontal, 24)
                            
                            Button(action: {
                                selectedView = .meetingAdmin
                            }) {
                                HStack(alignment: .center, spacing: 15) {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundColor(.accentColor)
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Sitzungen verwalten")
                                            .foregroundColor(Color.primary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    Image(systemName: selectedView == .funktionen ? "chevron.down" : "chevron.right")
                                        .foregroundColor(Color.secondary)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 10)
                    }

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
                                Text(formattedDate(currentMeeting.start))
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
                                Text(formattedTime(currentMeeting.start))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
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
                        }
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
                        }
                    }

                }
                .frame(width: 320) // Feste Breite für Seitenleiste
                .background(Color(UIColor.systemBackground)) // Dynamische Hintergrundfarbe für Dark/Light Mode

                // Hauptanzeige rechts
                VStack {
                    switch selectedView {
                    case .vereinseinstellungen:
                        Text("Vereinseinstellungen")
                            .font(.largeTitle)
                            .padding()
                    case .nutzerverwaltung:
                        NutzerverwaltungView()
                    case .umfrage:
                        VotingListView()
                    case .funktionen:
                        FunktionenView()
                    case .meetingAdmin:
                        MeetingAdminView()
                    }

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadUserProfile()
            loadCurrentMeeting()
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }


    // MARK: - Sidebar Button Helper
    private func sidebarButton(icon: String, title: String, isSelected: Bool) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(isSelected ? .blue : .accentColor)
                .frame(width: 20)

            Text(title)
                .foregroundColor(isSelected ? .blue : Color.primary)

            Spacer()

            Image(systemName: isSelected ? "chevron.down" : "chevron.right")
                .foregroundColor(isSelected ? .blue : Color.secondary)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Meeting Box
    private var meetingBox: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(meeting)
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white)
                Text(meetingDate)
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 4) {
                    Text("\(attendeesCount)")
                        .foregroundColor(.white)
                    Image(systemName: "person.3")
                        .foregroundColor(.white)
                }
            }

            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.white)
                Text(meetingTime)
                    .foregroundColor(.white)

                Spacer()
            }

            Button(action: {
                // Aktion für aktuelle Sitzung
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
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    // MARK: - API-Logik
    private func loadUserProfile() {
        MainPageAPI.fetchUserProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    name = profile.name ?? "Admin"
                    shortName = MainPageAPI.calculateShortName(from: profile.name ?? "A")
                case .failure(let error):
                    errorMessage = "Fehler beim Laden des Profils: \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadCurrentMeeting() {
        MainPageAPI.fetchCurrentMeeting { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let meeting):
                    if let meeting = meeting {
                        self.meetingExists = true
                        self.meeting = meeting.name
                        self.meetingDate = formatDate(meeting.start)
                        self.meetingTime = formatTime(meeting.start)
                        self.attendeesCount = Int(meeting.duration ?? 0)
                    } else {
                        self.meetingExists = false
                    }
                case .failure:
                    self.meetingExists = false
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum SidebarOption {
    case vereinseinstellungen
    case nutzerverwaltung
    case funktionen
    case umfrage
    case meetingAdmin
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}









// Beispielansicht für Konfiguration der Funktionen
struct FunktionenView: View {
    var body: some View {
        Text("Konfiguration der Funktionen")
            .font(.largeTitle)
    }
}

