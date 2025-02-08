import ConfigServiceDTOs
import Fluent
import Vapor
import Models


extension SettingBulkUpdateDTO: @retroactive Content, @unchecked @retroactive Sendable {
    public func performBulkUpdate(req: Request) async throws -> BulkUpdateResponseDTO {
    // Führe den Datenbank-Update-Prozess in einer Transaktion durch.
    let (updatedIDs, failedIDs, notifications) = try await req.db.transaction { transaction -> ([UUID], [UUID: String], [(setting: Setting, oldValue: String)]) in
        var updated = [UUID]()
        var failed = [UUID: String]()
        var notifications = [(setting: Setting, oldValue: String)]()
        
        // Für jedes Update-Item im DTO
        for updateItem in self.updates {
            do {
                // Versuche, das Setting zu finden
                if let setting = try await Setting.find(updateItem.id, on: transaction) {
                    try setting.validateValue(updateItem.value)
                    
                    let oldValue = setting.value
                    setting.value = updateItem.value
                    try await setting.update(on: transaction)
                    
                    if let id = setting.id {
                        updated.append(id)
                    } else {
                        failed[updateItem.id] = "Updated setting has no ID."
                    }
                    
                    // Sammle die notwendigen Daten für die spätere Webhook-Nachricht
                    notifications.append((setting: setting, oldValue: oldValue))
                } else {
                    failed[updateItem.id] = "Setting not found."
                }
            } catch {
                failed[updateItem.id] = error.localizedDescription
            }
        }
        
        return (updated, failed, notifications)
    }
    
    // Sende Webhook-Nachrichten asynchron im Hintergrund, nachdem die Transaktion abgeschlossen ist.
    for (setting, oldValue) in notifications {
        Task.detached {
                 await sendWebhookNotificationWithRetry(
                    req: req,
                    event: "updated",
                    setting: setting,
                    oldValue: oldValue
                )
        }
    }
    
    return BulkUpdateResponseDTO(updated: updatedIDs, failed: failedIDs)
}
}
