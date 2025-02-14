// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
        self.localizableData.strings[key]?.localizations[lang.lowercased()]?.stringUnit.value ??
        self.localizableData.strings[key]?.localizations["en"]?.stringUnit.value ??
        key
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
