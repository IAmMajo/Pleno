import Fluent
import SwiftOpenAPI
import Models
import Vapor
import ConfigServiceDTOs

@preconcurrency import JWTKit

struct ConfigController: RouteCollection{
    let jwtSigner: JWTSigner
    let authMiddleware: Middleware
    let adminMiddleware: Middleware
    
    
    init() throws {
        guard let keyData = "Ganzgeheimespasswort".data(using: .utf8) else {
            throw Abort(.internalServerError, reason: "Fehler beim Erstellen des JWT-Signers")
        }
        self.jwtSigner = JWTSigner.hs256(key: keyData)
        self.authMiddleware = AuthMiddleware(jwtSigner: jwtSigner, payloadType: JWTPayloadDTO.self)
        self.adminMiddleware = AdminMiddleware()
    }
    
    
    func boot(routes: RoutesBuilder) throws {
        
        let authProtected = routes.grouped(authMiddleware)
        let adminProtected = authProtected.grouped(adminMiddleware)
        let openAPITagConfig = TagObject(name: "Konfigurations Einstellungen")
        
        
        let settings = adminProtected.grouped("config")
        settings.get(use: getSettings).openAPI(
            tags: openAPITagConfig,
            summary: "Alle aktiven Einstellungen abrufen",
            description: "Gibt eine Liste aller Einstellungen zurück, die mit aktiven Services verknüpft sind.",
            query: [],
            body: nil,
            response: .type([SettingResponseDTO].self),
            responseContentType: .application(.json)
        )
        settings.get(":id", use: getSetting).openAPI(
            tags: openAPITagConfig,
            summary: "Eine bestimmte Einstellung abrufen",
            description: "Gibt eine Einstellung anhand ihrer ID zurück.",
            path: .type(Setting.IDValue.self),
            body: nil,
            response: .type(SettingResponseDTO.self),
            responseContentType: .application(.json)
        )
        settings.patch(":id", use: update).openAPI(
            tags: openAPITagConfig,
            summary: "Eine Einstellung aktualisieren",
            description: "Aktualisiert den Wert einer einzelnen Einstellung anhand ihrer ID.",
            path: .type(Setting.IDValue.self),
            body: .type(SettingUpdateDTO.self),
            contentType: .application(.json),
            response: .type(SettingResponseDTO.self),
            responseContentType: .application(.json)
        )
        settings.patch(use: bulkUpdate).openAPI(
            tags: openAPITagConfig,
            summary: "Mehrere Einstellungen gleichzeitig aktualisieren",
            description: """
                    Aktualisiert mehrere Einstellungen in einem Batch.
                    Gibt 207 (Multi-Status) zurück, um anzuzeigen, welche Updates erfolgreich und welche fehlgeschlagen sind.
                """,
            query: [],
            body: .type(SettingBulkUpdateDTO.self),
            contentType: .application(.json),
            response: .type(BulkUpdateResponseDTO.self),
            responseContentType: .application(.json)
        )
        let openAPITagIntern = TagObject(name: "Intern")
        
        let services = routes.grouped("service")
        services.get(":id", use: settingsForService).openAPI(
            tags: openAPITagIntern,
            summary: "Einstellungen für einen bestimmten Service abrufen",
            description: "Gibt alle Einstellungen zurück, die einem bestimmten Service zugeordnet sind.",
            path: .type(Service.IDValue.self),                body: nil,
            response: .type([SettingResponseDTO].self),
            responseContentType: .application(.json)
        )
    }
}

// MARK: - Routen

/// GET /config
@Sendable
func getSettings(req: Request) async throws -> [SettingResponseDTO] {
    guard let settings = try? await Setting.query(on: req.db)
        .join(ServiceSetting.self, on: \Setting.$id == \ServiceSetting.$setting.$id)
        .join(Service.self, on: \Service.$id == \ServiceSetting.$service.$id)
        .filter(Service.self, \.$active == true)
        .unique()
        .all()
    else {
        throw Abort(.notFound)
    }
    
    let responseDTOs = settings.map {
        SettingResponseDTO(
            id: $0.id,
            key: $0.key,
            datatype: $0.datatype.rawValue,
            value: $0.value,
            description: $0.description
        )
    }
    
    return responseDTOs
}

/// GET /config/:id
@Sendable
func getSetting(req: Request) async throws -> SettingResponseDTO {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw Abort(.badRequest, reason: "Invalid Settings ID")
    }
    
    guard let setting = try await Setting.find(id, on: req.db) else {
        throw Abort(.notFound, reason: "Setting not found")
    }
    
    let responseDTO = SettingResponseDTO(
        id: setting.id,
        key: setting.key,
        datatype: setting.datatype.rawValue,
        value: setting.value,
        description: setting.description
    )
    return responseDTO
}

/// PATCH /config/:id
@Sendable
func update(req: Request) async throws -> SettingResponseDTO {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw Abort(.badRequest, reason: "Invalid Settings ID")
    }
    
    guard let dto = try? req.content.decode(SettingUpdateDTO.self.self) else {
        throw Abort(.badRequest, reason: "Invalid request body! Expected SettingUpdateDTO.")
    }
    
    guard let setting = try await Setting.find(id, on: req.db) else {
        throw Abort(.notFound, reason: "Setting not found")
    }
    
    let oldValue = setting.value
    setting.value = dto.value
    
    do {
        try await setting.update(on: req.db)
        
    } catch {
        throw Abort(.internalServerError, reason: "Error updating Setting: \(error.localizedDescription)")
    }
    
    do{
        try await sendWebhookNotification(req: req, event: "updated", setting: setting, oldValue: oldValue)
    }
    catch{
        throw Abort(.internalServerError)
    }
    
    let responseDTO = SettingResponseDTO(
        id: setting.id,
        key: setting.key,
        datatype: setting.datatype.rawValue,
        value: setting.value,
        description: setting.description
    )
    return responseDTO
}

/// PATCH /config
@Sendable
func bulkUpdate(req: Request) async throws -> Response {
    let dto: SettingBulkUpdateDTO
    do {
        dto = try req.content.decode(SettingBulkUpdateDTO.self)
    } catch {
        throw Abort(.badRequest, reason: "Invalid request body! Expected SettingBulkUpdateDTO.")
    }
    
    let (updatedIDs, failedIDs) = try await req.db.transaction { transaction -> ([UUID], [UUID: String]) in
        var updated = [UUID]()
        var failed = [UUID: String]()
        
        for updateItem in dto.updates {
            do {
                
                if let setting = try await Setting.find(updateItem.id, on: transaction) {
                    let oldValue = setting.value
                    setting.value = updateItem.value
                    try await setting.update(on: transaction)
                    
                    if let id = setting.id {
                        updated.append(id)
                    } else {
                        failed[updateItem.id] = "Updated setting has no ID."
                    }
                    
                    try await sendWebhookNotification(
                        req: req,
                        event: "updated",
                        setting: setting,
                        oldValue: oldValue
                    )
                } else {
                    failed[updateItem.id] = "Setting not found."
                }
            } catch {
                failed[updateItem.id] = error.localizedDescription
            }
        }
        
        return (updated, failed)
    }
    
    return try await BulkUpdateResponseDTO(updated: updatedIDs, failed: failedIDs).encodeResponse(status: .multiStatus, for: req)
}


/// GET /service/:serviceID
@Sendable
func settingsForService(req: Request) async throws -> [SettingResponseDTO] {
    guard let serviceID = req.parameters.get("id", as: UUID.self) else {
        throw Abort(.badRequest, reason: "Invalid Service ID")
    }
    
    guard let service = try await Service.find(serviceID, on: req.db) else {
        throw Abort(.notFound, reason: "Service not found")
    }
    
    try await service.$settings.load(on: req.db)
    let settings = service.settings
    
    let responseDTOs = settings.map {
        SettingResponseDTO(
            id: $0.id,
            key: $0.key,
            datatype: $0.datatype.rawValue,
            value: $0.value,
            description: $0.description
        )
    }
    
    return responseDTOs
}

/// Sendet eine Webhook-Benachrichtigung an alle aktiven Services, die mit einer bestimmten Einstellung verknüpft sind.
private func sendWebhookNotification(req: Request, event: String, setting: Setting, oldValue: String) async throws {
    let services = try await Service.query(on: req.db)
        .join(ServiceSetting.self, on: \Service.$id == \ServiceSetting.$service.$id)
        .filter(ServiceSetting.self, \ServiceSetting.$setting.$id == setting.id!)
        .filter(\Service.$webhook_url != nil)
        .filter(\Service.$active == true)
        .all()
    
    for service in services {
        guard let webhookURL = service.webhook_url else {
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
        
        let payloadData = try JSONEncoder().encode(payload)
        
        var webhookRequest = ClientRequest()
        webhookRequest.method = .POST
        webhookRequest.url = URI(string: webhookURL)
        webhookRequest.headers.contentType = .json
        webhookRequest.body = .init(data: payloadData)
        
        do {
            _ = try await req.client.send(webhookRequest)
        } catch {
            throw Abort(.internalServerError, reason: "Could not send Webhook request")
        }
    }
}

