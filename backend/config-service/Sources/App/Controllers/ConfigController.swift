import Fluent
import Vapor

struct ConfigController: RouteCollection{
    func boot(routes: RoutesBuilder) throws {
        let settings = routes.grouped("config")
        settings.get(use: index)
        settings.get(":id", use: show)
        settings.patch(":id", use: update)
        settings.patch(use: bulkUpdate)     // Massenupdate
    }
    
    // GET /config
    func index(req: Request) async throws -> Response {
        let settings = try await Setting.query(on: req.db).all()
        let responseDTOs = settings.map { setting in
            SettingResponseDTO(
                id: setting.id,
                key: setting.key,
                datatype: setting.datatype.rawValue,
                value: setting.value,
                description: setting.description
            )
        }
        let data = try JSONEncoder().encode(responseDTOs)
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        return Response(status: .ok, headers: headers, body: .init(data: data))
    }
    
    // GET /config/:id
    func show(req: Request) async throws -> Response {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            let errorResponse = ErrorResponse(error: true, reason: "Ungültige Einstellungs-ID.")
            let data = try JSONEncoder().encode(errorResponse)
            var headers = HTTPHeaders()
            headers.add(name: .contentType, value: "application/json")
            return Response(status: .badRequest, headers: headers, body: .init(data: data))
        }
        let setting = try await Setting.find(id, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "Einstellung nicht gefunden."))
        
        let responseDTO = SettingResponseDTO(
            id: setting.id,
            key: setting.key,
            datatype: setting.datatype.rawValue,
            value: setting.value,
            description: setting.description
        )
        let data = try JSONEncoder().encode(responseDTO)
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        return Response(status: .ok, headers: headers, body: .init(data: data))
    }

    // PATCH /config/:id
    func update(req: Request) async throws -> Response {

        guard let body = req.body.data else {
            throw Abort(.badRequest, reason: "Leerer Anfrageinhalt.")
        }
        let input = try JSONDecoder().decode(SettingUpdateDTO.self, from: body)
        
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Einstellungs-ID.")
        }

        let setting = try await Setting.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
        let oldValue = setting.value
        setting.value = input.value
        try await setting.save(on: req.db)
        try await sendWebhookNotification(req: req, event: "updated", setting: setting, oldValue: oldValue)
        
        let responseDTO = SettingResponseDTO(
            id: setting.id,
            key: setting.key,
            datatype: setting.datatype.rawValue,
            value: setting.value,
            description: setting.description
        )
        let data = try JSONEncoder().encode(responseDTO)
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        return Response(status: .ok, headers: headers, body: .init(data: data))
    }
    
    func bulkUpdate(req: Request) async throws -> Response {
        
        guard let bodyData = req.body.data else {
            throw Abort(.badRequest, reason: "Fehlender Anfragekörper")
        }
        let decoder = JSONDecoder()
        let input = try decoder.decode(SettingBulkUpdateDTO.self, from: bodyData)
        
        var updatedIDs = [UUID]()
        var failedIDs = [UUID: String]()
        
        for updateItem in input.updates {
            do {
                if let setting = try await Setting.find(updateItem.id, on: req.db) {
                    let oldValue = setting.value
                    setting.value = updateItem.value
                    try await setting.save(on: req.db)
                    updatedIDs.append(setting.id!)
                    // Webhook-Benachrichtigung senden
                    try await sendWebhookNotification(req: req, event: "updated", setting: setting, oldValue: oldValue)
                } else {
                    failedIDs[updateItem.id] = "Einstellung nicht gefunden."
                }
            } catch {
                failedIDs[updateItem.id] = error.localizedDescription
            }
        }
        
        let responseDTO = BulkUpdateResponseDTO(updated: updatedIDs, failed: failedIDs)
        
        // Manuelles Kodieren der Antwort, da DTOs nur 'Codable' sind
        let encoder = JSONEncoder()
        let responseData = try encoder.encode(responseDTO)
        
        var response = Response(status: .multiStatus) // 207 Multi-Status
        response.headers.contentType = .json
        response.body = .init(data: responseData)
        return response
    }

    // Funktion zum Senden der Webhook-Benachrichtigung
    private func sendWebhookNotification(req: Request, event: String, setting: Setting, oldValue: String) async throws {
        // Aktive Services mit webhook_url abrufen
        let services = try await Service.query(on: req.db)
            .filter(\.$webhookURL != nil)
            .filter(\.$active == true)
            .all()
        
        for service in services {
            guard let webhookURL = service.webhookURL else {
                continue
            }

            let payload = WebhookPayloadDTO(
                event: event,
                settings_id: setting.id!,
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

            let data = try JSONEncoder().encode(payload)
            do {
                _ = try await req.client.post(URI(string: webhookURL)) { postReq in
                    postReq.headers.add(name: .contentType, value: "application/json")
                    postReq.body = .init(data: data)
                }
            } catch {
                // Optional: Fehlerbehandlung oder Logging
                req.logger.error("Webhook-Fehler bei URL \(webhookURL): \(error)")
            }
        }
    }
}

// Fehlerantwort-DTO für konsistente Fehlerbehandlung
struct ErrorResponse: Codable {
    let error: Bool
    let reason: String
}
