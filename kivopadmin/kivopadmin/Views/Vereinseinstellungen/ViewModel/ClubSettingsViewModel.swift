// This file is licensed under the MIT-0 License.

import Foundation
import SwiftUI

class ClubSettingsViewModel: ObservableObject {
    @Published var settings: [ClubSetting] = []
    @Published var editedValues: [String: String] = [:]
    @Published var showTooltip: Bool = false
    @Published var tooltipDescription: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Sprachcodes mit Beschreibung
    let languageOptions = [
        ("de", "Deutsch"),
        ("en", "Englisch"),
        ("fr", "Französisch"),
        ("es", "Spanisch"),
        ("it", "Italienisch"),
        ("tr", "Türkisch")
    ]

    init() {
        fetchSettings()
    }

    // 🔹 Einstellungen abrufen
    func fetchSettings() {
        isLoading = true
        errorMessage = nil

        ClubSettingsAPI.shared.fetchAllSettings { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let fetchedSettings):
                    self.settings = fetchedSettings
                case .failure(let error):
                    self.errorMessage = "Fehler beim Laden der Einstellungen: \(error.localizedDescription)"
                }
            }
        }
    }

    // 🔹 Einzelne Einstellung aktualisieren
    func updateSetting(_ setting: ClubSetting, newValue: String) {
        ClubSettingsAPI.shared.updateSetting(id: setting.id, newValue: newValue) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedSetting):
                    if let index = self.settings.firstIndex(where: { $0.id == updatedSetting.id }) {
                        self.settings[index] = updatedSetting
                    }
                case .failure(let error):
                    self.errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
                }
            }
        }
    }

    // 🔹 Alle geänderten Einstellungen speichern
    func saveSettings() {
        let updates = editedValues.map { SettingUpdate(id: $0.key, value: $0.value) }

        ClubSettingsAPI.shared.bulkUpdateSettings(updates: updates) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.fetchSettings() // Einstellungen neu laden
                    self.editedValues.removeAll()
                case .failure(let error):
                    self.errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
                }
            }
        }
    }

    // 🔹 Sprache anzeigen (Name statt Code)
    func displayLanguage(for code: String) -> String {
        return languageOptions.first(where: { $0.0 == code })?.1 ?? code
    }
}
