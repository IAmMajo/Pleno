import Foundation

actor LocalizableManager {
    static let shared = LocalizableManager()
    private let localizableData: LocalizableData
    
    private init () {
        guard let url = Bundle.module.url(forResource: "Localizable.xcstrings", withExtension: "json") else {
            fatalError("Localizable.xcstrings could not be loaded!")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Contents of Localizable.xcstrings could not be loaded!")
        }
        guard let localizableData = try? JSONDecoder().decode(LocalizableData.self, from: data) else {
            fatalError("Contents of Localizable.xcstrings could not be decoded!")
        }
        self.localizableData = localizableData
    }
    
    func translate(key: String, into lang: String) -> String {
        self.localizableData.strings[key]?.localizations[lang.lowercased()]?.stringUnit.value ?? key
    }
}

fileprivate struct LocalizableData: Codable {
    var sourceLanguage: String
    var version: String
    var strings: [String : LocalizableString]
}

fileprivate struct LocalizableString: Codable {
    var extractionState: String
    var localizations: [String : LocalizableStringTranslation]
}

fileprivate struct LocalizableStringTranslation: Codable {
    var stringUnit: LocalizableStringTranslationUnit
}

fileprivate struct LocalizableStringTranslationUnit: Codable {
    var state: String
    var value: String
}
