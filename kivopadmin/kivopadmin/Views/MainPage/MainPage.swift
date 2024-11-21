import SwiftUI

struct MainPage: View {
    @State private var Name: String = "Max Mustermann"
    @State private var ShortName: String = "V"
    @State private var Meeting: String = "Jahreshauptversammlung"
    @State private var selectedView: SidebarOption = .nutzerverwaltung
    @State private var isAdminExpanded: Bool = true

    
    private var User: String {
        Name.components(separatedBy: " ").first ?? ""
    }
    
    var body: some View {
        NavigationView {
            HStack(spacing: 0) {
                // Seitenleiste
                VStack(alignment: .leading, spacing: 0) {
                    // Begrüßungsbereich
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hallo Admin, \(User)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)
                        
                        HStack {
                            Text("Adminbereich")
                                .font(.caption)
                                .bold()
                                .foregroundColor(Color.secondary)
                            
                            Spacer()
                            
                            Button(action: {
                                isAdminExpanded.toggle()
                            }) {
                                Image(systemName: isAdminExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    
                    // Einklappbarer Adminbereich
                    if isAdminExpanded {
                        // Bereich für "Vereinseinstellungen"
                        Button(action: {
                            selectedView = .vereinseinstellungen
                        }) {
                            HStack(spacing: 15) {
                                Circle()
                                    .fill(Color.gray.opacity(0.8))
                                    .frame(width: 50, height: 50)
                                    .overlay(Text(ShortName).foregroundColor(.white).font(.caption))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Vereinseinstellungen")
                                        .font(.headline)
                                        .foregroundColor(Color.primary)
                                    Text("Übersicht und Verwaltung")
                                        .font(.subheadline)
                                        .lineLimit(1)
                                        .foregroundColor(Color.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: selectedView == .vereinseinstellungen ? "chevron.down" : "chevron.right")
                                    .foregroundColor(Color.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.systemBackground)) // Hintergrund für Dark- und Light-Mode
                            .cornerRadius(15)
                            .padding(.bottom, 10)
                        }
                        
                        // Optionen in der Seitenleiste
                        VStack(alignment: .leading, spacing: 15) {
                            Button(action: {
                                selectedView = .nutzerverwaltung
                            }) {
                                HStack(alignment: .center, spacing: 15) {
                                    Image(systemName: "person.3.fill")
                                        .foregroundColor(.accentColor)
                                        .frame(width: 20)
                                    Text("Nutzerverwaltung")
                                        .foregroundColor(Color.primary)
                                    Spacer()
                                    Image(systemName: selectedView == .nutzerverwaltung ? "chevron.down" : "chevron.right")
                                        .foregroundColor(Color.secondary)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            Button(action: {
                                selectedView = .funktionen
                            }) {
                                HStack(alignment: .center, spacing: 15) {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.accentColor)
                                        .frame(width: 20)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Konfiguration der Funktionen")
                                            .foregroundColor(Color.primary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    Image(systemName: selectedView == .funktionen ? "chevron.down" : "chevron.right")
                                        .foregroundColor(Color.secondary)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    // Box für Sitzung am unteren Rand
                    VStack(alignment: .leading, spacing: 10) {
                        Text(Meeting)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.white)
                            Text("21.01.2024")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("10")
                                    .foregroundColor(.white)
                                Image(systemName: "person.3")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.white)
                            Text("18:06")
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        Button(action: {
                            // Aktion für aktuelle Sitzung
                        }) {
                            Text("Zur aktuellen Sitzung")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(UIColor.systemBackground))
                                .foregroundColor(.accentColor)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(15)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .frame(width: 320) // Feste Breite für Seitenleiste
                .background(Color(UIColor.systemBackground)) // Dynamische Hintergrundfarbe für Dark/Light Mode
                
                // Hauptanzeige rechts
                VStack {
                    switch selectedView {
                    case .vereinseinstellungen:
                        Text("Vereinseinstellungen")
                            .font(.largeTitle)
                            .padding()
                    case .nutzerverwaltung:
                        NutzerverwaltungView()
                    case .funktionen:
                        FunktionenView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground)) // Hintergrund für Dark/Light Mode
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)

    }

}

enum SidebarOption {
    case vereinseinstellungen
    case nutzerverwaltung
    case funktionen
}

// Beispiel für Hauptanzeige der Nutzerverwaltung
struct NutzerverwaltungView: View {
    @State private var isPopupPresented = false
    @State private var selectedUser = ""
    
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
                                    
                                    Text("3")
                                        .foregroundColor(.orange)
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 30)
                                .onTapGesture {
                                    isPopupPresented = true // Öffne Pop-up
                                }
                                .sheet(isPresented: $isPopupPresented) {
                                    PendingRequestsNavigationView(
                                        isPresented: $isPopupPresented,
                                        selectedUser: $selectedUser
                                    )
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
                                        isPopupPresented = true
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
                .sheet(isPresented: $isPopupPresented) {
                    UserPopupView(isPresented: $isPopupPresented, user: $selectedUser)
                }
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemBackground)) // Adapt to Dark/Light Mode
    }
}


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

struct PendingRequestsNavigationView: View {
    @Binding var isPresented: Bool
    @Binding var selectedUser: String

    var body: some View {
        NavigationStack {
            PendingRequestsView(selectedUser: $selectedUser)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Zurück") {
                            isPresented = false // Schließe das gesamte Pop-up
                        }
                    }
                }
        }
    }
}


struct PendingRequestsView: View {
    @Binding var selectedUser: String

    let requests = [
        ("Max Mustermann", "maxmustermann@web.de"),
        ("Maxine Musterfrau", "maxinemusterfrau@gmail.com"),
        ("Maximilian Musterkind", "maximilianmusterkind@web.de")
    ]
    
    var body: some View {
        List {
            ForEach(requests, id: \.0) { request in
                NavigationLink(
                    destination: PendingRequestPopup(user: request.0, email: request.1)
                ) {
                    VStack(alignment: .leading) {
                        Text(request.0)
                            .font(.system(size: 18)) // Größere Schrift für die Namen
                            .foregroundColor(.black) // Schwarze Schriftfarbe
                        Text(request.1)
                            .font(.system(size: 14)) // Kleinere Schrift für die E-Mail
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .listStyle(PlainListStyle()) // Entfernt zusätzliche Graufärbung
        .navigationTitle("Beitrittsanfragen") // Titel nur in der Navigation Bar
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white) // Weißer Hintergrund
    }
}



struct PendingRequestPopup: View {
    var user: String
    var email: String

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(user)
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("E-Mail-Adresse")
                    Spacer()
                    Text(email) // E-Mail direkt aus dem Array
                        .foregroundColor(.gray)
                }
                HStack {
                    Text("Registrierungsdatum")
                    Spacer()
                    Text("01.01.2024")
                        .foregroundColor(.gray)
                }
                Divider()

            }
            .padding()

            Spacer()

            VStack(spacing: 10) { // Buttons vertikal anordnen
                Button(action: {
                    // Aktion zum Bestätigen
                }) {
                    Text("Bestätigen")
                        .font(.system(size: 16)) // Kleinere Schriftgröße
                        .padding(.vertical, 10) // Weniger Höhe
                        .frame(width: 352) // Reduzierte Breite
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8) // Abgerundete Ecken
                }

                Button(action: {
                    // Aktion zum Ablehnen
                }) {
                    Text("Ablehnen")
                        .font(.system(size: 16)) // Kleinere Schriftgröße
                        .padding(.vertical, 10) // Weniger Höhe
                        .frame(width: 352) // Reduzierte Breite
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8) // Abgerundete Ecken
                }
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline) // Titel in der Navigation Bar
        .background(Color.white) // Weißer Hintergrund
    }
}


// Beispielansicht für Konfiguration der Funktionen
struct FunktionenView: View {
    var body: some View {
        Text("Konfiguration der Funktionen")
            .font(.largeTitle)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
