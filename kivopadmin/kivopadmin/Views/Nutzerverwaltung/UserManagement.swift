import SwiftUI
import AuthServiceDTOs

struct NutzerverwaltungView: View {
    @State private var isUserPopupPresented = false
    @State private var isPendingRequestPopupPresented = false
    @State private var selectedUser: UserProfileDTO? = nil
    @State private var pendingRequestsCount: Int = 0

    @ObservedObject var userManager = UserManager()

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
                .sheet(isPresented: $isPendingRequestPopupPresented) {
                    PendingRequestsNavigationView(isPresented: $isPendingRequestPopupPresented)
                }
            }
            
            // Nutzerübersicht Section
            VStack(alignment: .leading, spacing: 10) {
                Text("NUTZERÜBERSICHT")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
                
                // User Avatars
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(userManager.users, id: \.email) { user in
                            VStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 50)
                                    .overlay(Text(user.name?.prefix(2) ?? "--").foregroundColor(.white))
                                    .onTapGesture {
                                        selectedUser = user
                                        isUserPopupPresented = true
                                    }
                                
                                Text(user.name ?? "Unbekannt")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                }
                // Sheet for Popup
                .sheet(isPresented: $isUserPopupPresented) {
                    if let userBinding = Binding($selectedUser) {
                        UserPopupView(user: userBinding, isPresented: $isUserPopupPresented)
                    } else {
                        Text("Kein Benutzer ausgewählt")
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
        }
        .onAppear {
            // Benutzer laden, wenn die View erscheint
            userManager.fetchUsers()
            fetchPendingRequestsCount() // Anzahl der ausstehenden Anfragen abrufen
        }
        .background(Color(UIColor.systemBackground)) // Adapt to Dark/Light Mode
    }

    private func fetchPendingRequestsCount() {
        MainPageAPI.fetchPendingUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    pendingRequestsCount = users.filter { $0.isActive == false }.count
                case .failure(let error):
                    print("Fehler beim Abrufen der Anzahl ausstehender Anfragen: \(error.localizedDescription)")
                    pendingRequestsCount = 0
                }
            }
        }
    }
}

#Preview {
    NutzerverwaltungView()
}
