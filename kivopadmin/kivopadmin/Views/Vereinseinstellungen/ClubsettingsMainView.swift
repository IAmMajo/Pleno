import SwiftUI

struct ClubsettingsMainView: View {
    @State private var settings: [Setting] = [
        Setting(datatype: "languageCode", id: "1", value: "de", description: "Sprache der Benutzeroberfläche", key: "Standardsprache"),
        Setting(datatype: "boolean", id: "2", value: "false", description: "Registrierungen aktivieren oder deaktivieren", key: "Registrierung aktivieren"),
        Setting(datatype: "integer", id: "3", value: "30", description: "Intervall für das automatische Löschen von Postern (in Tagen)", key: "Poster Löschintervall"),
        Setting(datatype: "integer", id: "4", value: "14", description: "Intervall, um Poster vor dem Abbau zu markieren (in Tagen)", key: "Poster Vorwarnintervall"),
        Setting(datatype: "integer", id: "5", value: "1", description: "Erinnerungsintervall für Posteraktionen (in Tagen)", key: "Poster Erinnerungsintervall")
    ]
    @State private var editedValues: [String: String] = [:]
    @State private var showTooltip: Bool = false
    @State private var tooltipDescription: String = ""
    
    // Sprachcodes mit Beschreibung
    private let languageOptions = [
        ("de", "Deutsch"),
        ("en", "Englisch"),
        ("fr", "Französisch"),
        ("es", "Spanisch"),
        ("it", "Italienisch")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 20) {
                    // Vereinsinformationen
                    HStack {
                        if let clubImage = UIImage(named: "ClubImage") {
                            Image(uiImage: clubImage)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                Text("VL")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Mein Verein")
                                .font(.title2)
                                .bold()
                            Text("info@meinverein.de")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Einstellungen
                    Text("Einstellungen")
                        .font(.headline)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(settings) { setting in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(setting.key)
                                            .font(.body)
                                            .bold()
                                        if setting.description != nil {
                                            Button(action: {
                                                tooltipDescription = setting.description ?? "Keine Beschreibung verfügbar."
                                                showTooltip = true
                                            }) {
                                                Text("Info")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                    
                                    Spacer()

                                    // Dynamische Eingabe
                                    if setting.datatype == "boolean" {
                                        Toggle(isOn: Binding(
                                            get: { editedValues[setting.id] == "true" || setting.value == "true" },
                                            set: { newValue in
                                                editedValues[setting.id] = newValue ? "true" : "false"
                                            }
                                        )) {
                                            Text("")
                                        }
                                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                                    } else if setting.datatype == "integer" {
                                        Picker("", selection: Binding(
                                            get: { Int(editedValues[setting.id] ?? setting.value) ?? 0 },
                                            set: { newValue in
                                                editedValues[setting.id] = String(newValue)
                                            }
                                        )) {
                                            ForEach(1...60, id: \.self) { value in
                                                Text("\(value)").tag(value)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .frame(width: 80)
                                    } else if setting.datatype == "languageCode" {
                                        Menu {
                                            ForEach(languageOptions, id: \.0) { code, name in
                                                Button("\(name) (\(code))") {
                                                    editedValues[setting.id] = code
                                                }
                                            }
                                        } label: {
                                            Text(displayLanguage(for: setting.value))
                                                .foregroundColor(.blue)
                                                .padding(8)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    } else {
                                        Text("Unsupported datatype")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .navigationTitle("Vereinseinstellungen")
                .background(Color.white) // Weißer Hintergrund
                
                // Floating Save Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            saveSettings()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                Text("Speichern")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(30)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                        }
                        .padding()
                    }
                }
            }
        }
        .alert(isPresented: $showTooltip) {
            Alert(
                title: Text("Beschreibung"),
                message: Text(tooltipDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func saveSettings() {
        for (id, newValue) in editedValues {
            print("Einstellung \(id) wird gespeichert mit neuem Wert: \(newValue)")
            // API-Aufruf-Logik hier einfügen
        }
        editedValues.removeAll() // Änderungen zurücksetzen
    }
    
    private func displayLanguage(for code: String) -> String {
        languageOptions.first(where: { $0.0 == code })?.1 ?? code
    }
}

// MARK: - Setting Model
struct Setting: Identifiable, Codable, Hashable {
    var datatype: String
    var id: String
    var value: String
    var description: String?
    var key: String
}

#Preview {
    ClubsettingsMainView()
}
