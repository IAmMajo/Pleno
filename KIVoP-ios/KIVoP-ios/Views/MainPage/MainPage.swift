import SwiftUI
import AuthServiceDTOs
import MeetingServiceDTOs
import UIKit

struct MainPage: View {
    // Nutzer- und Meeting-Daten
    @State private var name: String = ""
    @State private var shortName: String = "??"
    @State private var profileImage: UIImage? = nil
    @State private var meeting: String? = nil
    @State private var meetingDate: String? = nil
    @State private var meetingTime: String? = nil
    @State private var attendeesCount: Int? = nil
    // UI-Zustände
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    // Meeting-Manager zur Verwaltung von Meeting-Daten
    @StateObject private var meetingManager = MeetingManager()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Begrüßung
                if isLoading {
                    ProgressView("Laden...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Hallo, \(extractFirstName(from: name))")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                        .padding([.top, .leading], 20)
                }

                // Profil-Bereich
                NavigationLink(destination: MainPage_ProfilView()) {
                    HStack {
                        if let profileImage = profileImage {
                            // Profilbild anzeigen, wenn vorhanden
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            // Shortname-Kreis als Fallback
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(shortName)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                )
                        }

                        VStack(alignment: .leading) {
                            Text(name.isEmpty ? "Name laden..." : name)
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
                    .padding(.horizontal, 10)
                    .padding(10)
                }

                // Navigationsmenü für verschiedene Funktionen
                List {
                    Section {
                        if meetingManager.isLoading {
                            ProgressView("Loading meetings...")
                                .progressViewStyle(CircularProgressViewStyle())
                        } else if !meetingManager.meetings.isEmpty {
                            NavigationLink(destination: MeetingView(meetings: meetingManager.meetings)) {
                                HStack {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundColor(.accentColor)
                                    Text("Sitzungen")
                                        .foregroundColor(Color.primary)
                                }
                            }
                        } else if let errorMessage = meetingManager.errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                        } else {
                            Text("No meetings available.")
                        }
                        
                        NavigationLink(destination: EventView()) {
                            HStack {
                               Image(systemName: "star")
                                    .foregroundColor(.accentColor)
                                Text("Events")
                                    .foregroundColor(Color.primary)
                            }
                        }
                    }

                    Section {
                        NavigationLink(destination: VotingsView()) {
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(.accentColor)
                                Text("Abstimmungen")
                                    .foregroundColor(Color.primary)
                            }
                        }

                        NavigationLink(destination: RecordsMainView()) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.accentColor)
                                Text("Protokolle")
                                    .foregroundColor(Color.primary)
                            }
                        }

                        NavigationLink(destination: AttendanceView()) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                                    .foregroundColor(.accentColor)
                                Text("Anwesenheit")
                                    .foregroundColor(Color.primary)
                            }
                        }
                       
                       NavigationLink(destination: PostersView()) {
                           HStack {
                              Image(systemName: "text.rectangle.page.fill")
                                   .foregroundColor(.accentColor)
                               Text("Plakate")
                                   .foregroundColor(Color.primary)
                           }
                       }
                        NavigationLink(destination: RideView()) {
                            HStack {
                               Image(systemName: "car.fill")
                                    .foregroundColor(.accentColor)
                                Text("Fahrgemeinschaften")
                                    .foregroundColor(Color.primary)
                            }
                        }
                        NavigationLink(destination: PollsView()) {
                           HStack {
                              Image(systemName: "bubble.left.and.bubble.right.fill")
                                   .foregroundColor(.accentColor)
                               Text("Umfragen")
                                   .foregroundColor(Color.primary)
                           }
                       }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color.clear)
                .padding(.top, -10)
                .refreshable{
                    meetingManager.fetchAllMeetings()
                }

                Spacer()
                // Anzeige des aktuellen Meetings am unteren Bildschirmrand
                CurrentMeetingBottomView()
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .onAppear {
            meetingManager.fetchAllMeetings()
            loadUserProfile()
            loadCurrentMeeting()
        }
    }

    // MARK: - Nutzerprofil laden
    func loadUserProfile(retryCount: Int = 4) {
        guard retryCount > 0 else {
            self.errorMessage = "Fehler: Profil konnte nicht geladen werden."
            return
        }

        MainPageAPI.fetchUserProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.isLoading = false
                    self.errorMessage = nil
                    self.name = profile.name
                    self.shortName = MainPageAPI.calculateShortName(from: profile.name)
                    if let imageData = profile.profileImage, let image = UIImage(data: imageData) {
                        self.profileImage = image
                    } else {
                        self.profileImage = nil
                    }
                case .failure(let error):
                    self.errorMessage = "Fehler beim Laden des Profils: \(error.localizedDescription)"
                    print("Retry \(5 - retryCount): \(error.localizedDescription)")

                    // Wiederholter Abruf nach 2 Sekunden
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.loadUserProfile(retryCount: retryCount - 1)
                    }
                }
            }
        }
    }
    
    // MARK: - Aktuelles Meeting laden
    func loadCurrentMeeting() {
        MainPageAPI.fetchCurrentMeeting { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let meeting):
                    if let meeting = meeting {
                        self.meeting = meeting.name
                        self.meetingDate = formatDate(meeting.start)
                        self.meetingTime = formatTime(meeting.start)
                        self.attendeesCount = meeting.duration.map { Int($0) }
                    }
                case .failure(let error):
                    print("Fehler beim Laden des Meetings: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Helferfunktionen
    func extractFirstName(from fullName: String) -> String {
        return fullName.split(separator: " ").first.map(String.init) ?? "Nutzer"
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
