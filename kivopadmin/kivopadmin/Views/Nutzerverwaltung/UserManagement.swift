import SwiftUI
import AuthServiceDTOs

struct NutzerverwaltungView: View {
    @State private var isUserPopupPresented = false
    @State private var isPendingRequestPopupPresented = false
    @State private var selectedUser: UserProfileDTO? = nil
    @State private var pendingRequestsCount: Int = 0
    @State private var users: [UserProfileDTO] = []
    @State private var loadingUserID: UUID? = nil // ID des aktuell geladenen Benutzers

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            Text("Nutzerverwaltung")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.leading, 30)
                .padding(.top, 20)

            // Beitrittsverwaltung Section
            VStack(alignment: .leading, spacing: 10) {
                Text("BEITRITTSVERWALTUNG")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)

                // Ausstehend row
                HStack {
                    Text("Ausstehend")
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(pendingRequestsCount)") // Dynamische Anzeige
                        .foregroundColor(.orange)

                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 30)
                .onTapGesture {
                    isPendingRequestPopupPresented = true
                }
                .sheet(isPresented: $isPendingRequestPopupPresented, onDismiss: {
                    fetchAllData() // Daten aktualisieren nach Verlassen der Beitrittsverwaltung
                }) {
                    PendingRequestsNavigationView(isPresented: $isPendingRequestPopupPresented, onListUpdate: {
                        fetchPendingRequestsCount() // Anzahl der ausstehenden Anfragen live aktualisieren
                    })
                }
            }

            // Nutzerübersicht Section
            VStack(alignment: .leading, spacing: 10) {
                Text("NUTZERÜBERSICHT")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(users.filter { $0.isActive == true }, id: \.uid) { user in
                            VStack {
                                if let imageData = user.profileImage, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            selectUser(user)
                                        }
                                } else {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text(MainPageAPI.calculateInitials(from: user.name))
                                                .foregroundColor(.white)
                                        )
                                        .onTapGesture {
                                            selectUser(user)
                                        }
                                }
                                Text(user.name ?? "Unbekannt")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                }
            }

            Spacer()
        }
        .sheet(isPresented: $isUserPopupPresented) {
            if let user = selectedUser {
                UserPopupView(user: .constant(user), isPresented: $isUserPopupPresented)
            } else {
                ProgressView("Benutzer wird geladen...")
            }
        }
        .onAppear {
            fetchAllData() // Alle relevanten Daten beim Start laden
        }
        .background(Color(UIColor.systemBackground))
    }

    // Benutzer auswählen
    private func selectUser(_ user: UserProfileDTO) {
        print("🔍 Benutzer ausgewählt: \(user.name ?? "Unbekannt")")
        guard loadingUserID != user.uid else {
            // Verhindere Doppelanfragen für denselben Benutzer
            print("🔄 Benutzer wird bereits geladen...")
            return
        }

        loadingUserID = user.uid // Setze die aktuell geladene Benutzer-ID
        isUserPopupPresented = true // Öffne Pop-up vor dem Laden

        MainPageAPI.fetchUserByID(userID: user.uid!) { result in
            DispatchQueue.main.async {
                loadingUserID = nil // Ladevorgang abgeschlossen
                switch result {
                case .success(let fetchedUser):
                    selectedUser = fetchedUser
                    print("✅ Benutzerdetails erfolgreich geladen: \(fetchedUser.name ?? "Unbekannt")")
                case .failure(let error):
                    print("❌ Fehler beim Abrufen der Benutzerdetails: \(error.localizedDescription)")
                    isUserPopupPresented = false // Schließe Pop-up bei Fehler
                }
            }
        }
    }

    // Funktion: Alle Daten abrufen
    private func fetchAllData() {
        print("🔄 Nutzerverwaltung gestartet. Daten werden geladen...")
        fetchAllUsers()
        fetchPendingRequestsCount()
    }

    // Funktion: Benutzerliste laden
    private func fetchAllUsers() {
        print("🔄 Benutzer werden geladen...")
        MainPageAPI.fetchAllUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUsers):
                    users = fetchedUsers.filter { $0.isActive == true } // Filtere inaktive Benutzer
                    print("✅ Benutzerliste aktualisiert. Anzahl: \(users.count)")
                case .failure(let error):
                    print("❌ Fehler beim Laden der Benutzer: \(error.localizedDescription)")
                }
            }
        }
    }

    // Funktion: Anzahl ausstehender Anfragen abrufen
    private func fetchPendingRequestsCount() {
        print("🔄 Beitrittsanfragen werden geladen...")
        MainPageAPI.fetchPendingUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    pendingRequestsCount = users.filter { $0.isActive == false }.count
                    print("✅ Anzahl ausstehender Anfragen: \(pendingRequestsCount)")
                case .failure(let error):
                    print("❌ Fehler beim Abrufen der Anzahl ausstehender Anfragen: \(error.localizedDescription)")
                    pendingRequestsCount = 0
                }
            }
        }
    }
}


#Preview {
    NutzerverwaltungView()
}
