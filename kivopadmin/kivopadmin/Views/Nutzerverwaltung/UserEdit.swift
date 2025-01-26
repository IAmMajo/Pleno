import SwiftUI
import AuthServiceDTOs

struct UserEditView: View {
    @Binding var user: UserProfileDTO // Benutzer-Objekt als Binding
    @Binding var selectedRole: String
    @Binding var wip: String

    @State private var name: String = "" // Initial leer
    
    let roles = ["Nutzer", "Protokollant", "Admin", "Prüfer"]

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 110, height: 110)
                    .overlay(
                        Text(user.name.prefix(2)) // Sicherstellen, dass kein nil verwendet wird
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Text("Bild löschen")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            // Name bearbeiten
            HStack {
                Text("Name")
                Spacer()
                TextField("Name bearbeiten", text: $name)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.trailing)
            }

            Divider()

            // Rolle bearbeiten (Picker)
            HStack {
                Text("Rolle")
                Spacer()
                Picker("Rolle", selection: $selectedRole) {
                    ForEach(roles, id: \.self) { role in
                        Text(role)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Divider()

            // WIP bearbeiten
            HStack {
                Text("WIP")
                Spacer()
                TextField("WIP bearbeiten", text: $wip)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.trailing)
            }
            
            Spacer()
            
            // Löschen-Button
            Button("Account löschen") {
                // Account löschen (Aktion hinzufügen)
            }
            .padding()
            .frame(width: 400)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            // Speichern
            Button("Änderungen speichern") {
                user.name = name // Aktualisiert den gebundenen Wert
            }
            .foregroundColor(.blue)
        }
        .padding()
        .onAppear {
            // Initialisiere name mit dem aktuellen Wert von user.name
            name = user.name ?? ""
        }
    }
}
