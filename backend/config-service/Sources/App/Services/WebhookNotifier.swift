import Vapor
import Fluent
import Models
import ConfigServiceDTOs
/// Sends a webhook notification to all active services associated with a specific setting,
/// using parallel tasks to send the requests concurrently.
public func sendWebhookNotification(
    req: Request,
    event: String,
    setting: Setting,
    oldValue: String
) async throws {
    // Stelle sicher, dass das Setting eine ID besitzt.
    let settingID = try setting.requireID()
    
    // Abfrage aller aktiven Services, die mit dem Setting verknüpft sind.
    let services = try await Service.query(on: req.db)
        .join(ServiceSetting.self, on: \Service.$id == \ServiceSetting.$service.$id)
        .filter(ServiceSetting.self, \ServiceSetting.$setting.$id == settingID)
        .filter(\Service.$webhook_url != nil)
        .filter(\Service.$active == true)
        .all()
    
    // Einen gemeinsamen JSONEncoder erstellen, um wiederholte Instanziierungen zu vermeiden.
    let encoder = JSONEncoder()
    
    // Versand der Webhook-Anfragen parallel.
    try await withThrowingTaskGroup(of: Void.self) { group in
        for service in services {
            // Falls kein Webhook-URL gesetzt ist, überspringe diesen Service.
            guard let webhookURL = service.webhook_url else {
                continue
            }
            
            group.addTask {
                // Erstelle den Payload für die Webhook-Anfrage.
                let payload = WebhookPayloadDTO(
                    event: event,
                    settings_id: settingID,
                    new_value: SettingValueDTO(
                        key: setting.key,
                        datatype: setting.datatype.rawValue,
                        value: setting.value
                    ),
                    old_value: SettingValueDTO(
                        key: setting.key,
                        datatype: setting.datatype.rawValue,
                        value: oldValue
                    )
                )
                
                // Encodiere den Payload in JSON-Daten.
                let payloadData = try encoder.encode(payload)
                
                // Erstelle die ClientRequest.
                var webhookRequest = ClientRequest()
                webhookRequest.method = .POST
                webhookRequest.url = URI(string: webhookURL)
                webhookRequest.headers.contentType = .json
                webhookRequest.body = .init(data: payloadData)
                
                // Sende die Anfrage.
                _ = try await req.client.send(webhookRequest)
            }
        }
        // Warte darauf, dass alle Tasks abgeschlossen sind.
        try await group.waitForAll()
    }
    
}

public func sendWebhookNotificationWithRetry(
    req: Request,
    event: String,
    setting: Setting,
    oldValue: String,
    maxRetries: Int = 3,
    delay: UInt64 = 4_000_000_000  // 4 Sekunden (in Nanosekunden)
) async {
    var attempts = 0
    while attempts < maxRetries {
        do {
            try await sendWebhookNotification(
                req: req,
                event: event,
                setting: setting,
                oldValue: oldValue
            )
            // Erfolg: Verlasse die Funktion.
            return
        } catch {
            attempts += 1
            req.logger.error("Webhook send attempt \(attempts) failed: \(error.localizedDescription)")
            if attempts < maxRetries {
                try? await Task.sleep(nanoseconds: delay)
            }
        }
    }
    req.logger.error("All webhook send attempts failed for setting \(setting.id?.uuidString ?? "unknown").")
}
