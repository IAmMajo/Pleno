import Fluent
import SwiftOpenAPI
import Models
import Vapor
import ConfigServiceDTOs

@preconcurrency import JWTKit

struct ConfigController: RouteCollection{
    func boot(routes: RoutesBuilder) throws {
        let authMiddleware = AuthMiddleware(payloadType: JWTPayloadDTO.self)
        let adminMiddleware = AdminMiddleware()
        
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
    
    return try await dto.performUpdate(req: req, settingID: id)
}

/// PATCH /config
@Sendable
func bulkUpdate(req: Request) async throws -> Response {
   
    guard let dto: SettingBulkUpdateDTO = try? req.content.decode(SettingBulkUpdateDTO.self)
    else {
        throw Abort(.badRequest, reason: "Invalid request body! Expected SettingBulkUpdateDTO.")
    }
    
    let responseDTO = try await dto.performBulkUpdate(req: req)
    
    return try await responseDTO.encodeResponse(status: .multiStatus, for: req)
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



