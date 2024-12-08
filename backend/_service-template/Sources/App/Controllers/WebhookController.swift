import Fluent
import Vapor

struct WebhookController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let webhook = routes.grouped("webhook")
        webhook.post(use: receiveWebhook)
    }
    
    func receiveWebhook(req: Request) async throws -> HTTPStatus {
        let payload = try req.content.decode(WebhookPayloadDTO.self)
        
        guard let newValue = payload.new_value else {
            req.logger.error("Ungültiger Payload: Keine neuen Werte vorhanden.")
            throw Abort(.badRequest, reason: "Ungültiger Payload")
        }
        
        // Cache aktualisieren
        SettingsManager.shared.updateSetting(key: newValue.key, value: newValue.value)
        req.logger.info("Einstellung '\(newValue.key)' wurde aktualisiert.")
        
        return .ok
    }
}
