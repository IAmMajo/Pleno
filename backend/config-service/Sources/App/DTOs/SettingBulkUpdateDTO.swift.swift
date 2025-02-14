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
