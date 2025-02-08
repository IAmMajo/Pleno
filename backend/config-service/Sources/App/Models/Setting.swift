import Fluent
import Vapor
import Models

extension Setting {
    public func validateValue(_ newValue: String) throws {
        switch self.datatype {
        case .integer:
            guard Int(newValue) != nil else {
                throw Abort(.badRequest, reason: "Value '\(newValue)' is not a valid Integer.")
            }
        case .float:
            guard Double(newValue) != nil else {
                throw Abort(.badRequest, reason: "Value '\(newValue)' is not a valid Float.")
            }
        case .boolean:
            let lower = newValue.lowercased()
            guard lower == "true" || lower == "false" else {
                throw Abort(.badRequest, reason: "Value '\(newValue)' is not a valid Boolean.")
            }
        case .date:
            // Verwende ISO8601-Format für das Datum
            let formatter = ISO8601DateFormatter()
            guard formatter.date(from: newValue) != nil else {
                throw Abort(.badRequest, reason: "Value '\(newValue)' is not a valid Date.")
            }
        case .dateTime:
            // Verwende ISO8601-Format auch für DateTime
            let formatter = ISO8601DateFormatter()
            guard formatter.date(from: newValue) != nil else {
                throw Abort(.badRequest, reason: "Value '\(newValue)' is not a valid DateTime.")
            }
        case .time:
            // Erwartetes Format: "HH:mm:ss"
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            guard formatter.date(from: newValue) != nil else {
                throw Abort(.badRequest, reason: "Value '\(newValue)' is not a valid Time (expected format HH:mm:ss).")
            }
        case .json:
            // Prüfe, ob newValue in ein JSON-Objekt umgewandelt werden kann
            guard let data = newValue.data(using: .utf8) else {
                throw Abort(.badRequest, reason: "Value cannot be converted to data.")
            }
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                throw Abort(.badRequest, reason: "Value '\(newValue)' is not valid JSON.")
            }
        case .string, .text:
            // Für Strings und Texte erfolgt in der Regel keine spezifische Validierung.
            break
        case .languageCode:
            
            guard Locale.LanguageCode(stringLiteral: newValue).isISOLanguage else {
                throw Abort(.badRequest, reason: "Value '\(newValue)' is not a valid ISO language code.")
            }

        case .binary:
            // Hier wird erwartet, dass newValue ein Base64-kodierter String ist.
            guard Data(base64Encoded: newValue) != nil else {
                throw Abort(.badRequest, reason: "Value '\(newValue)' is not valid binary (expected Base64 encoded).")
            }
        }
    }
}


