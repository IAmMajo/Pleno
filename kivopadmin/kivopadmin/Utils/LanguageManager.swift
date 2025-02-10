import Foundation

class LanguageManager {
    let languagesDefault: [String]
    let languagesEdit: [String]
    
    init() {
        // Bevorzugte Sprachen abrufen
        languagesDefault = Locale.preferredLanguages
        
        // Großbuchstaben (Sprachenteil) extrahieren
        languagesEdit = languagesDefault.compactMap { language in
            language.split(separator: "-").first.map { String($0).uppercased() }
        }
    }
    
    private func getLanguage(langCode: String) -> String {
        let languages: [(name: String, code: String)] = [
            ("Arabisch", "ar"),
            ("Chinesisch", "zh"),
            ("Dänisch", "da"),
            ("Deutsch", "de"),
            ("Englisch", "en"),
            ("Französisch", "fr"),
            ("Griechisch", "el"),
            ("Hindi", "hi"),
            ("Italienisch", "it"),
            ("Japanisch", "ja"),
            ("Koreanisch", "ko"),
            ("Niederländisch", "nl"),
            ("Norwegisch", "no"),
            ("Polnisch", "pl"),
            ("Portugiesisch", "pt"),
            ("Rumänisch", "ro"), // Hinzugefügt
            ("Russisch", "ru"),
            ("Schwedisch", "sv"),
            ("Spanisch", "es"),
            ("Thai", "th"), // Hinzugefügt
            ("Türkisch", "tr"),
            ("Ungarisch", "hu")
        ]


        // Suche nach dem Kürzel und gib den Namen zurück
        if let language = languages.first(where: { $0.code == langCode }) {
            return language.name
        }

        // Standardwert, falls das Kürzel nicht gefunden wird
        return langCode
    }
}
