import SwiftUI

struct UserPopupView: View {
    @Binding var isPresented: Bool
    @Binding var user: String
    @State private var selectedRole = "Protokollant"
    @State private var wip = "WIP"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 110, height: 110)
                        .overlay(
                            Text(user.prefix(2))
                                .font(.system(size: 50)) // Schriftgröße festlegen
                                .foregroundColor(.white)
                        )
                }
                HStack{
                    Text("Name")
                    Spacer()
                    Text("\(user)").foregroundColor(.gray)
                }
                Divider()
                HStack{
                    Text("Rolle")
                    Spacer()
                    Text("Protokollant").foregroundColor(.gray)
                }
                Divider()
                HStack{
                    Text("WIP")
                    Spacer()
                    Text("WIP").foregroundColor(.gray)
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
                NavigationLink(destination: UserEditView(user: $user, selectedRole: $selectedRole, wip: $wip)) {
                    Text("Nutzer bearbeiten")
                        .foregroundStyle(.blue)
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
