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
}
