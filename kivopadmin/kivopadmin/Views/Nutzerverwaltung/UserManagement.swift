import SwiftUI
import AuthServiceDTOs

// Beispiel für Hauptanzeige der Nutzerverwaltung
struct NutzerverwaltungView: View {
    @State private var isUserPopupPresented = false
    @State private var isPendingRequestPopupPresented = false
    @State private var selectedUser = ""
    
    @ObservedObject var controller = BackendController()
    
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
                    
                    Text("\(controller.pendingRequestsCount)")
                        .foregroundColor(.orange)
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 30)
                .onTapGesture {
                    isPendingRequestPopupPresented = true // Öffne Pop-up
                }
                .sheet(isPresented: $isPendingRequestPopupPresented) {
                    PendingRequestsNavigationView(isPresented: $isPendingRequestPopupPresented)
                }
            }
            
            // Einladungslink row
            HStack {
                Text("Einladungslink")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 30)
            
            // Nutzerübersicht Section
            VStack(alignment: .leading, spacing: 10) {
                Text("NUTZERÜBERSICHT")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
                
                // Search bar
                HStack {
                    TextField("Search", text: .constant(""))
                        .padding(.leading, 30) // Adds padding to the left for the icon
                        .padding(10)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(8)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                        )
                }
                .padding(.horizontal, 30)
                
                // User Avatars
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        // Dummy User Data
                        let users = ["Max Mustermann", "Maxine Musterfrau", "Maximilian Musterkind"]
                        
                        ForEach(users, id: \.self) { user in
                            VStack {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 50)
                                    .overlay(Text(user.prefix(2)).foregroundColor(.white))
                                    .onTapGesture {
                                        selectedUser = user
                                        isUserPopupPresented = true
                                    }
                                
                                Text(user)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                }
                // Sheet for Popup
                .sheet(isPresented: $isUserPopupPresented) {
                    UserPopupView(isPresented: $isUserPopupPresented, user: $selectedUser)
                }
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground)) // Adapt to Dark/Light Mode
    }
}

#Preview {
    NutzerverwaltungView()
}

