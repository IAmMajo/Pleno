import SwiftUI
import AuthServiceDTOs

enum Pages: Hashable {
    case vereinseinstellungen, nutzerverwaltung, abstimmungen, sitzungen, protokolle, plakatpositionen, umfragen//, events
}

struct MainPage: View {
    @State private var name: String = ""
    @State private var shortName: String = "V"
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
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
                    MeetingAdminView().environmentObject(meetingManager)
                }
                Tab("Protokolle", systemImage: "doc.text", value: .protokolle) {
                    RecordsMainView()
                }
                Tab("Plakatpositionen", systemImage: "mappin.and.ellipse", value: .plakatpositionen) {
                    PostersMainView()
                }
//                Tab("Events", systemImage: "star", value: .events) {
//                    EventsMainView()
//                }
                Tab("Umfragen", systemImage: "bubble.left.and.bubble.right.fill", value: .umfragen) {
                    PollListView()
                }


            }.tabViewStyle(.sidebarAdaptable)
            .tabViewSidebarBottomBar{
                CurrentMeetingBottomView().environmentObject(meetingManager)
                    .padding(.vertical, 70).refreshable{
                        meetingManager.fetchAllMeetings()
                    }
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}










