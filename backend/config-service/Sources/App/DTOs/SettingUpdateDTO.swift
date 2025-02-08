import ConfigServiceDTOs
import Vapor
import Models

extension SettingUpdateDTO: @retroactive Content, @unchecked @retroactive Sendable {
    public func performUpdate(req: Request, settingID: UUID) async throws -> SettingResponseDTO {
    // Suche das Setting anhand der ID.
    guard let setting = try await Setting.find(settingID, on: req.db) else {
        throw Abort(.notFound, reason: "Setting not found")
    }
    
    // Validierung des neuen Wertes gemäß dem definierten Datentyp.
    try setting.validateValue(self.value)
    
    let oldValue = setting.value
    setting.value = self.value
    
    // Aktualisiere das Setting in der Datenbank.
    do {
        try await setting.update(on: req.db)
    } catch {
        throw Abort(.internalServerError, reason: "Error updating Setting: \(error.localizedDescription)")
    }
    
    // Sende die Webhook-Benachrichtigung asynchron im Hintergrund.
    // Wir nutzen Task.detached, damit die Benachrichtigung unabhängig von der Response gesendet wird.
    Task.detached {
        await sendWebhookNotificationWithRetry(
            req: req,
            event: "updated",
            setting: setting,
            oldValue: oldValue
        )
    }
    
    // Erzeuge und gebe das Response DTO zurück.
    return SettingResponseDTO(
        id: setting.id,
        key: setting.key,
        datatype: setting.datatype.rawValue,
        value: setting.value,
        description: setting.description
    )
}
}

