// This file is licensed under the MIT-0 License.
import SwiftUI

struct ClubsettingsMainView: View {
    @StateObject private var viewModel = ClubSettingsViewModel()

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
                    
                    Text("Einstellungen")
                        .font(.headline)
                    
                    if viewModel.isLoading {
                        ProgressView("Lade Einstellungen...")
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
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

                                        // Dynamische Eingabe
                                        if setting.datatype == "boolean" {
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
                                        } else if setting.datatype == "integer" {
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
                                        } else if setting.datatype == "languageCode" {
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
                                        } else {
                                            Text("Unsupported datatype")
                                                .foregroundColor(.gray)
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
                
                // Floating Save Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.saveSettings()
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
        .alert(isPresented: $viewModel.showTooltip) {
            Alert(
                title: Text("Beschreibung"),
                message: Text(viewModel.tooltipDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
