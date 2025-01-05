import ConfigServiceDTOs
import Vapor

final class SettingsManager {
    static let shared = SettingsManager()
    private var settingsCache: [String: String] = [:]

    private init() {}

    func loadSettings(from configServiceURL: String, serviceID: UUID, client: Client, logger: Logger) async throws {
        let url = "\(configServiceURL)/config/service/\(serviceID.uuidString)"
        let response = try await client.get(URI(string: url))
        
        guard response.status == .ok else {
            logger.error("Fehler beim Abrufen der Einstellungen: \(response.status)")
            throw Abort(.internalServerError, reason: "Fehler beim Abrufen der Einstellungen")
        }
        
        let data = response.body ?? ByteBuffer()
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
}
