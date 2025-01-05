import ConfigServiceDTOs
import Vapor

struct WebhookController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let webhook = routes.grouped("webhook")
        webhook.post(use: receiveWebhook)
    }
    
    @Sendable
    func receiveWebhook(req: Request) async throws -> HTTPStatus {
        let payload = try req.content.decode(WebhookPayloadDTO.self)
        
        guard let newValue = payload.new_value else {
            req.logger.error("Ungültiger Payload: Keine neuen Werte vorhanden.")
            throw Abort(.badRequest, reason: "Ungültiger Payload")
        }
        
        // Werte extrahieren
        let key = newValue.key
        let value = newValue.value
        
        // Direkter Aufruf der Methode mit await
        await SettingsManager.shared.updateSetting(key: key, value: value)
        
        req.logger.info("Einstellung '\(key)' wurde aktualisiert.")
        return .ok
    }
}

