import SwiftUI

// Neue Ansicht, in der der Benutzer bearbeitet werden kann
struct UserEditView: View {
    @Binding var user: String
    @Binding var selectedRole: String
    @Binding var wip: String
    
    let roles = ["Nutzer", "Protokollant", "Admin", "Prüfer"]

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 110, height: 110)
                    .overlay(
                        Text(user.prefix(2))
                            .font(.system(size: 50, weight: .bold)) // Schriftgröße festlegen
                            .foregroundColor(.white)
                    )
                
                Text("Bild löschen")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            HStack {
                Text("Name")
                Spacer()
                TextField("Name bearbeiten", text: $user)
                    .foregroundColor(.blue)
                    .cornerRadius(5)
                    .multilineTextAlignment(.trailing) // Text im TextField rechtsbündig ausrichten
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
                .pickerStyle(MenuPickerStyle()) // Der Picker erscheint als Dropdown
            }

            Divider()

            // WIP bearbeiten (TextField)
            HStack {
                Text("WIP")
                Spacer()
                TextField("WIP bearbeiten", text: $wip)
                    .foregroundColor(.blue)
                    .cornerRadius(5)
                    .multilineTextAlignment(.trailing) // Text im TextField rechtsbündig ausrichten
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
            Text("Änderungen speichern")
                .foregroundStyle(.blue)
        }
        .padding()
    
    }
}
