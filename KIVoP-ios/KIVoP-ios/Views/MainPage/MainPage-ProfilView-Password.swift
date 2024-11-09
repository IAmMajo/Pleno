import SwiftUI

struct MainPage_ProfilView_Password: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Aktuelles Passwort Abschnitt
            VStack(alignment: .leading, spacing: 5) {
                Text("AKTUELLES PASSWORT")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                SecureField("Aktuelles Passwort", text: $currentPassword)
                    .padding(10)
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(10)
            }
            
            // Neues Passwort Abschnitt mit grauer Linie dazwischen
            VStack(alignment: .leading, spacing: 5) {
                Text("NEUES PASSWORT")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
                
                VStack(spacing: 0) {
                    SecureField("Neues Passwort", text: $newPassword)
                        .padding(10)
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                    Divider()
                        .frame(height: 0.5)
                        .background(Color.gray.opacity(0.6))
                        .padding(.horizontal, 10)
                    
                    SecureField("Passwort wiederholen", text: $confirmPassword)
                        .padding(10)
                        .background(Color(UIColor.systemBackground).opacity(0.8))
                }
                .cornerRadius(10)
            }
            
            // Speichern Button
            Button(action: {
                // Aktion zum Speichern des neuen Passworts
            }) {
                Text("Speichern")
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .foregroundColor(.accentColor)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle("Passwort", displayMode: .inline)
        .navigationBarBackButtonHidden(true) // Standard-Zurück-Button ausblenden
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Zurück zur vorherigen Ansicht
                }) {
                    HStack {
                        Image(systemName: "chevron.backward") // Pfeil-Symbol für Zurück-Button
                        Text("Profil") // Gewünschter Text
                    }
                }
            }
        }
        .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct MainPage_ProfilView_Password_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainPage_ProfilView_Password()
        }
    }
}
