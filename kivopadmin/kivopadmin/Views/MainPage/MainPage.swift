import SwiftUI
import AuthServiceDTOs

// verfügbare Views für die Seitenleiste
enum Pages: Hashable {
    case vereinseinstellungen, nutzerverwaltung, abstimmungen, sitzungen, protokolle, plakatpositionen, umfragen, events, fahrgemeinschaften
}

struct MainPage: View {
    @State private var name: String = ""
    @State private var shortName: String = "V"
    @State private var errorMessage: String? = nil

    // ViewModel für die Sitzungen. Wird in der Mainpage erstellt, damit die "UnterViews" auf dem gleichen ViewModel arbeiten können
    @StateObject private var meetingManager = MeetingManager()
    @State private var page: Pages = .nutzerverwaltung
    
    private var User: String {
        name.components(separatedBy: " ").first ?? ""
    }
    
    var body: some View {
            // Optionen in der Seitenleiste

            TabView(selection: $page){
                Tab("Vereinseinstellungen", systemImage: "gearshape.fill", value: .vereinseinstellungen){
                    ClubsettingsMainView()
                }
                Tab("Nutzerverwaltung", systemImage: "person.3.fill", value: .nutzerverwaltung){
                    NutzerverwaltungView()
                }
                Tab("Abstimmungen", systemImage: "chart.bar.fill", value: .abstimmungen){
                    VotingListView()
                }
                Tab("Sitzungen", systemImage: "calendar.badge.clock", value: .sitzungen) {
                    // Tab für die Sitzungen; der meetingManager wird als EnvironmentObject mitgegeben
                    // Dann arbeiten die Sitzungs-Views auf dem gleichen ViewModel wie die Übersicht über laufende Sitzungen (blaue Boxen unten links)
                    MeetingAdminView().environmentObject(meetingManager)
                }
                Tab("Protokolle", systemImage: "doc.text", value: .protokolle) {
                    RecordsMainView()
                }
                Tab("Plakatpositionen", systemImage: "mappin.and.ellipse", value: .plakatpositionen) {
                    PostersMainView()
                }
                Tab("Umfragen", systemImage: "bubble.left.and.bubble.right.fill", value: .umfragen) {
                    PollListView()
                }
                Tab("Events", systemImage: "star", value: .events) {
                    EventsMainView()
                }
                Tab("Fahrgemeinschaften", systemImage: "car", value: .fahrgemeinschaften) {
                    RidesMainView()
                }


            }.tabViewStyle(.sidebarAdaptable) // TabView kann als Sidebar angezeigt werden
            .tabViewSidebarBottomBar{
                // Ansicht über laufende Sitzungen
                // MeetingManager wird als EnvironmentObject mitgegeben
                // Sitzungsviews und CurrentMeetingBottomView arbeiten auf dem gleichen ViewModel, somit wird CurrentMeetingBottomView sofort aktualisiert, wenn Sitzungen gestartet oder beendet werden
                CurrentMeetingBottomView().environmentObject(meetingManager)
                    .padding(.vertical, 70)
            }
            // Header mit Begrüßung
            .tabViewSidebarHeader {
                HStack{
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hallo \(name.components(separatedBy: " ").first ?? "Admin")")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)
                        Text("Administrator")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }


            }
            .onAppear{
                meetingManager.fetchAllMeetings()
            }
            .refreshable {
                meetingManager.fetchAllMeetings()
            }
            .navigationBarHidden(true)
        .onAppear {
            loadUserProfile()
            meetingManager.fetchAllMeetings()
        }
        .refreshable {
            meetingManager.fetchAllMeetings()
        }
    }

    // MARK: - API-Logik
    private func loadUserProfile() {
        MainPageAPI.fetchUserProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    name = profile.name
                    shortName = MainPageAPI.calculateShortName(from: profile.name)
                case .failure(let error):
                    errorMessage = "Fehler beim Laden des Profils: \(error.localizedDescription)"
                }
            }
        }
    }
}










