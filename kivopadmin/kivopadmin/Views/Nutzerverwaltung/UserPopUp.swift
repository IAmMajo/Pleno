import SwiftUI
import MeetingServiceDTOs
import AuthServiceDTOs

struct UserPopupView: View {
    @Binding var user: UserProfileDTO // Benutzer als Binding
    
    @Binding var isPresented: Bool
    @State var selectedRole = "Protokollant"
    @State var wip = "WIP"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 110, height: 110)
                        .overlay(
                            Text(user.name?.prefix(2) ?? "NN")
                                .font(.system(size: 50)) // Schriftgröße festlegen
                                .foregroundColor(.white)
                        )
                }
                HStack {
                    Text("Name")
                    Spacer()
                    Text("\(user.name ?? "Unbekannt")").foregroundColor(.gray)
                }
                Divider()
                HStack {
                    Text("Rolle")
                    Spacer()
                    Text(selectedRole).foregroundColor(.gray)
                }
                Divider()
                HStack {
                    Text("WIP")
                    Spacer()
                    Text(wip).foregroundColor(.gray)
                }
                Spacer()
                
                Button("Account löschen") {
                    // Account löschen
                }
                .padding()
                .frame(width: 400)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Divider()
                
                // Nutzer bearbeiten
                NavigationLink(destination: UserEditView(user: $user, selectedRole: $selectedRole, wip: $wip)) {
                    Text("Nutzer bearbeiten")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .navigationBarItems(leading: Button(action: {
                isPresented = false
            }) {
                Text("Schließen") // Button-Text für den Schließen-Button
                    .foregroundColor(.blue)
            })
        }
    }
}
