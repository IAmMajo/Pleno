import SwiftUI
import AuthServiceDTOs

enum Pages: Hashable {
    case vereinseinstellungen, nutzerverwaltung, abstimmungen, sitzungen
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
        //NavigationStack {
            // Optionen in der Seitenleiste

            TabView(selection: $page){
                Tab("Vereinseinstellungen", systemImage: "gearshape.fill", value: .vereinseinstellungen){
                    Text("Vereinseinstellungen")
                }
                Tab("Nutzerverwaltung", systemImage: "person.3.fill", value: .nutzerverwaltung){
                    NutzerverwaltungView()
                }
                Tab("Abstimmungen", systemImage: "chart.bar.fill", value: .abstimmungen){
                    VotingListView()
                }
                Tab("Sitzungen", systemImage: "calendar.badge.clock", value: .sitzungen) {
                    MeetingAdminView()
                }


            }.tabViewStyle(.sidebarAdaptable)
            .tabViewSidebarBottomBar{
                CurrentMeetingBottomView()
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
        //}
        //.navigationBarBackButtonHidden(true)
        .onAppear {
            loadUserProfile()
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
                    name = profile.name ?? "Admin"
                    shortName = MainPageAPI.calculateShortName(from: profile.name ?? "A")
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









// Beispielansicht für Konfiguration der Funktionen
struct FunktionenView: View {
    var body: some View {
        Text("Konfiguration der Funktionen")
            .font(.largeTitle)
    }
}

