import SwiftUI

struct PendingRequestsNavigationView: View {
    @Binding var isPresented: Bool
    let requests = [
        ("Max Mustermann", "maxmustermann@web.de"),
        ("Maxine Musterfrau", "maxinemusterfrau@gmail.com"),
        ("Maximilian Musterkind", "maximilianmusterkind@web.de")
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(requests, id: \.0) { request in
                    NavigationLink(
                        destination: PendingRequestPopup(user: request.0, email: request.1)
                    ) {
                        VStack(alignment: .leading) {
                            Text(request.0)
                                .font(.system(size: 18)) // Größere Schrift für die Namen
                                .foregroundColor(Color.primary) // Dynamisch: passt sich Light/Darkmode an
                            Text(request.1)
                                .font(.system(size: 14)) // Kleinere Schrift für die E-Mail
                                .foregroundColor(Color.secondary) // Dynamisch: für graue Schrift
                        }
                    }
                }
            }
            .listStyle(PlainListStyle()) // Entfernt zusätzliche Graufärbung
            .navigationTitle("Beitrittsanfragen") // Titel nur in der Navigation Bar
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemBackground)) // Dynamischer Hintergrund für Light/Darkmode
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




struct PendingRequestPopup: View {
    var user: String
    var email: String

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Name")
                        .foregroundColor(Color.primary) // Dynamisch: passt sich Light/Darkmode an
                    Spacer()
                    Text(user)
                        .foregroundColor(Color.secondary) // Dynamisch: für graue Schrift
                }
                HStack {
                    Text("E-Mail-Adresse")
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(email)
                        .foregroundColor(Color.secondary)
                }
                HStack {
                    Text("Registrierungsdatum")
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text("01.01.2024")
                        .foregroundColor(Color.secondary)
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
                        .frame(width: 352, height: 38) // Angepasste Größe
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
                        .frame(width: 352, height: 38) // Angepasste Größe
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8) // Abgerundete Ecken
                }
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .navigationTitle("Beitrittsanfrage: \(user)") // Dynamischer Header mit dem Namen
        .navigationBarTitleDisplayMode(.inline)
        .overlay( // Graue Linie unter dem Titel hinzufügen
            VStack {
                Divider() // Divider-Linie
                    .background(Color.gray.opacity(0.5)) // Transparente graue Linie
                    .frame(height: 1) // Höhe der Linie
                    .offset(y: 2) // Platzierung direkt unter der Navigation Bar
                Spacer()
            }
        )
        .background(Color(UIColor.systemBackground)) // Dynamischer Hintergrund für Light/Darkmode
    }
}

