// This file is licensed under the MIT-0 License.

import SwiftUI

struct ClubsettingsMainView: View {
    // ViewModel zur Verwaltung der Vereinseinstellungen
    @StateObject private var viewModel = ClubSettingsViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header mit Vereinsinformationen
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
                            Text("VL") // Beispiel für Initialen des Vereins
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
                
                // Titel für die Einstellungen
                Text("Einstellungen")
                    .font(.headline)
                
                // Ladeanzeige während der Daten abgerufen werden
                if viewModel.isLoading {
                    ProgressView("Lade Einstellungen...")
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Durchlaufen aller vorhandenen Einstellungen
                            ForEach(viewModel.settings) { setting in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(setting.key)
                                            .font(.body)
                                            .bold()
                                        if let description = setting.description {
                                            Button(action: {
                                                viewModel.tooltipDescription = description
                                                viewModel.showTooltip = true
                                            }) {
                                                Text("Info")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                    
                                    Spacer()

                                    // Dynamische Verarbeitung der verschiedenen Einstellungstypen
                                    switch setting.datatype.lowercased() {
                                    case "boolean":
                                        Toggle(isOn: Binding(
                                            get: { viewModel.editedValues[setting.id] == "true" || setting.value == "true" },
                                            set: { newValue in
                                                viewModel.editedValues[setting.id] = newValue ? "true" : "false"
                                                viewModel.updateSetting(setting, newValue: newValue ? "true" : "false")
                                            }
                                        )) {
                                            Text("")
                                        }
                                        .toggleStyle(SwitchToggleStyle(tint: .blue))

                                    case "integer":
                                        Picker("", selection: Binding(
                                            get: { Int(viewModel.editedValues[setting.id] ?? setting.value) ?? 0 },
                                            set: { newValue in
                                                viewModel.editedValues[setting.id] = String(newValue)
                                                viewModel.updateSetting(setting, newValue: String(newValue))
                                            }
                                        )) {
                                            ForEach(1...60, id: \.self) { value in
                                                Text("\(value)").tag(value)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .frame(width: 80)

                                    case "languagecode":
                                        Menu {
                                            ForEach(viewModel.languageOptions, id: \.0) { code, name in
                                                Button("\(name) (\(code))") {
                                                    viewModel.editedValues[setting.id] = code
                                                    viewModel.updateSetting(setting, newValue: code)
                                                }
                                            }
                                        } label: {
                                            Text(viewModel.displayLanguage(for: setting.value))
                                                .foregroundColor(.blue)
                                                .padding(8)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    
                                    default:
                                        Text("⚠️ \(setting.datatype) nicht unterstützt")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .navigationTitle("Vereinseinstellungen")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(isPresented: $viewModel.showTooltip) {
            Alert(
                title: Text("Beschreibung"),
                message: Text(viewModel.tooltipDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
