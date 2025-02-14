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

