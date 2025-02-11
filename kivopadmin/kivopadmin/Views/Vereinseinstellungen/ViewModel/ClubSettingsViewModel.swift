import Foundation
import SwiftUI

class ClubSettingsViewModel: ObservableObject {
    @Published var settings: [ClubSetting] = []
    @Published var editedValues: [String: String] = [:]
    @Published var isLoading = false
    @Published var showTooltip = false
    @Published var tooltipDescription = ""

    private let api = ClubSettingsAPI.shared

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

    // MARK: - Einstellungen abrufen
    func fetchSettings() {
        isLoading = true
        api.fetchAllSettings { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let fetchedSettings):
                    self?.settings = fetchedSettings
                    self?.syncEditedValues()
                    print("✅ Erfolgreich abgerufen: \(fetchedSettings.count) Einstellungen")
                case .failure(let error):
                    print("❌ Fehler beim Abrufen der Einstellungen: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Änderungen zwischenspeichern
    private func syncEditedValues() {
        for setting in settings {
            editedValues[setting.id] = setting.value
        }
    }

    // MARK: - Eine einzelne Einstellung aktualisieren
    func updateSetting(_ setting: ClubSetting, newValue: String) {
        guard setting.value != newValue else { return }

        api.updateSetting(id: setting.id, newValue: newValue) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedSetting):
                    print("✅ Einstellung aktualisiert: \(updatedSetting.key) → \(updatedSetting.value)")
                    if let index = self.settings.firstIndex(where: { $0.id == updatedSetting.id }) {
                        self.settings[index] = updatedSetting
                    }
                case .failure(let error):
                    print("❌ Fehler beim Aktualisieren: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Änderungen speichern
    func saveSettings() {
        let updates = settings.compactMap { setting -> SettingUpdate? in
            guard let newValue = editedValues[setting.id], newValue != setting.value else { return nil }
            return SettingUpdate(id: setting.id, value: newValue)
        }

        guard !updates.isEmpty else {
            print("⚠️ Keine Änderungen zum Speichern")
            return
        }

        api.bulkUpdateSettings(updates: updates) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Alle Änderungen erfolgreich gespeichert")
                    self.fetchSettings() // Einstellungen neu laden
                case .failure(let error):
                    print("❌ Fehler beim Speichern: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Sprache anzeigen
    func displayLanguage(for code: String) -> String {
        return languageOptions.first(where: { $0.0 == code })?.1 ?? code
    }
}
