import ConfigServiceDTOs
import Vapor

actor SettingsManager {
    static let shared = SettingsManager()
    private var settingsCache: [String: String] = [:]

    private init() {}

    func loadSettings(from configServiceURL: String, serviceID: UUID, client: Client, logger: Logger) async throws {
        let url = "\(configServiceURL)/service/\(serviceID.uuidString)"
        let response = try await client.get(URI(string: url))
        print(url)
        guard response.status == .ok else {
            logger.error("Fehler beim Abrufen der Einstellungen: \(response.status)")
            throw Abort(.internalServerError, reason: "Fehler beim Abrufen der Einstellungen")
        }
        
        guard let body = response.body else {
                    logger.error("Keine Daten im Antwort-Body.")
                    throw Abort(.internalServerError, reason: "Keine Daten im Antwort-Body.")
                }
        let data = body.getData(at: 0, length: body.readableBytes) ?? Data()
                let settings = try JSONDecoder().decode([SettingResponseDTO].self, from: data)
                
        
        settings.forEach { setting in
            settingsCache[setting.key] = setting.value
        }
        
        logger.info("Einstellungen erfolgreich geladen und zwischengespeichert.")
    }
    
    func updateSetting(key: String, value: String) {
        settingsCache[key] = value
    }
    
    func getSetting(forKey key: String) -> String? {
        return settingsCache[key]
    }
    
    // Generische Methode zum Abrufen von Einstellungen mit Typkonvertierung
    func getSetting<T: LosslessStringConvertible>(forKey key: String) -> T? {
            guard let value = settingsCache[key], let converted = T(value) else {
                return nil
            }
            return converted
        }
}
