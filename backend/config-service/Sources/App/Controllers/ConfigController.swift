import Fluent
import SwiftOpenAPI
import Models
import Vapor
@preconcurrency import JWTKit

/// Controller zum Verwalten von Konfigurationseinstellungen.
/// Beinhaltet Routen zum Anzeigen, Aktualisieren und Abrufen von Einstellungen,
/// sowie zum Versenden von Webhook-Benachrichtigungen an verbundene Services.
struct ConfigController: RouteCollection{
    let jwtSigner: JWTSigner
    let authMiddleware: Middleware
    let adminMiddleware: Middleware
    
    /// Initialisiert den ConfigController mit JWT-basiertem Auth und Admin-Middleware.
    init() throws {
        //guard let jwtSecret = Environment.get("JWT_SECRET"),
        //      let keyData = jwtSecret.data(using: .utf8) else {
        //    throw Abort(.internalServerError, reason: "JWT_SECRET Umgebungsvariable nicht gesetzt oder ungültig.")
        guard let keyData = "Ganzgeheimespasswort".data(using: .utf8) else {
                throw Abort(.internalServerError, reason: "Fehler beim Erstellen des JWT-Signers")
        }
        self.jwtSigner = JWTSigner.hs256(key: keyData)
        self.authMiddleware = AuthMiddleware(jwtSigner: jwtSigner, payloadType: JWTPayloadDTO.self)
        self.adminMiddleware = AdminMiddleware()
    }
    
    /// Registriert alle Routen des Controllers.
        func boot(routes: RoutesBuilder) throws {
            // Authentifizierte Routen
            let authProtected = routes.grouped(authMiddleware)
            let adminProtected = authProtected.grouped(adminMiddleware)
            let openAPITagConfig = TagObject(name: "Konfigurations Einstellungen")

            // Routen für Konfigurationseinstellungen
            let settings = adminProtected.grouped("config")
            settings.get(use: index).openAPI(
                tags: openAPITagConfig,
                summary: "Alle aktiven Einstellungen abrufen",
                description: "Gibt eine Liste aller Einstellungen zurück, die mit aktiven Services verknüpft sind.",
                query: [],
                body: nil,
                response: .type([SettingResponseDTO].self),
                responseContentType: .application(.json)
            )
            settings.get(":id", use: show).openAPI(
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

            // Servicebezogene Routen
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
        /// Gibt eine Liste aller Einstellungen zurück, die mit aktiven Services verknüpft sind.
        @Sendable
        func index(req: Request) async throws -> Response {
            let settings = try await Setting.query(on: req.db)
                .join(ServiceSetting.self, on: \Setting.$id == \ServiceSetting.$setting.$id)
                .join(Service.self, on: \Service.$id == \ServiceSetting.$service.$id)
                .filter(Service.self, \.$active == true)
                .unique()
                .all()

            let responseDTOs = settings.map {
                SettingResponseDTO(
                    id: $0.id,
                    key: $0.key,
                    datatype: $0.datatype.rawValue,
                    value: $0.value,
                    description: $0.description
                )
            }

            return try await createJSONResponse(with: responseDTOs, status: .ok, on: req)
        }

        /// GET /config/:id
        /// Gibt eine einzelne Einstellung anhand der ID zurück.
        @Sendable
        func show(req: Request) async throws -> Response {
            guard let id = req.parameters.get("id", as: UUID.self) else {
                req.logger.warning("Ungültige Einstellungs-ID bei Anfrage /config/:id")
                return try await createJSONErrorResponse(reason: "Ungültige Einstellungs-ID.", status: .badRequest, on: req)
            }
            
            guard let setting = try await Setting.find(id, on: req.db) else {
                throw Abort(.notFound, reason: "Einstellung nicht gefunden.")
            }

            let responseDTO = SettingResponseDTO(
                id: setting.id,
                key: setting.key,
                datatype: setting.datatype.rawValue,
                value: setting.value,
                description: setting.description
            )
            return try await createJSONResponse(with: responseDTO, status: .ok, on: req)
        }

        /// PATCH /config/:id
        /// Aktualisiert den Wert einer einzelnen Einstellung.
        @Sendable
        func update(req: Request) async throws -> Response {
            guard let body = req.body.data else {
                throw Abort(.badRequest, reason: "Leerer Anfrageinhalt.")
            }
            
            let input = try JSONDecoder().decode(SettingUpdateDTO.self, from: body)
            
            guard let id = req.parameters.get("id", as: UUID.self) else {
                throw Abort(.badRequest, reason: "Ungültige Einstellungs-ID.")
            }

            guard let setting = try await Setting.find(id, on: req.db) else {
                throw Abort(.notFound, reason: "Einstellung nicht gefunden.")
            }

            let oldValue = setting.value
            setting.value = input.value
            try await setting.save(on: req.db)
            
            // Webhook-Benachrichtigung senden
            try await sendWebhookNotification(req: req, event: "updated", setting: setting, oldValue: oldValue)
            
            let responseDTO = SettingResponseDTO(
                id: setting.id,
                key: setting.key,
                datatype: setting.datatype.rawValue,
                value: setting.value,
                description: setting.description
            )
            return try await createJSONResponse(with: responseDTO, status: .ok, on: req)
        }
        
        /// PATCH /config
        /// Aktualisiert mehrere Einstellungen in einem Batch.
        /// Gibt einen 207 Multi-Status zurück, um anzuzeigen welche Updates erfolgreich und welche fehlgeschlagen sind.
        @Sendable
        func bulkUpdate(req: Request) async throws -> Response {
            guard let bodyData = req.body.data else {
                throw Abort(.badRequest, reason: "Fehlender Anfragekörper")
            }
            
            let input = try JSONDecoder().decode(SettingBulkUpdateDTO.self, from: bodyData)
            
            var updatedIDs = [UUID]()
            var failedIDs = [UUID: String]()
            
            for updateItem in input.updates {
                do {
                    if let setting = try await Setting.find(updateItem.id, on: req.db) {
                        let oldValue = setting.value
                        setting.value = updateItem.value
                        try await setting.save(on: req.db)
                        updatedIDs.append(setting.id!)
                        try await sendWebhookNotification(req: req, event: "updated", setting: setting, oldValue: oldValue)
                    } else {
                        failedIDs[updateItem.id] = "Einstellung nicht gefunden."
                        req.logger.warning("Einstellung \(updateItem.id) nicht gefunden beim Bulk-Update")
                    }
                } catch {
                    failedIDs[updateItem.id] = error.localizedDescription
                    req.logger.error("Fehler beim Aktualisieren von Einstellung \(updateItem.id): \(error.localizedDescription)")
                }
            }
            
            let responseDTO = BulkUpdateResponseDTO(updated: updatedIDs, failed: failedIDs)
            return try await createJSONResponse(with: responseDTO, status: .multiStatus, on: req)
        }
        
        /// GET /service/:serviceID
        /// Gibt alle Einstellungen für einen bestimmten Service zurück.
        @Sendable
        func settingsForService(req: Request) async throws -> Response {
            guard let serviceID = req.parameters.get("id", as: UUID.self) else {
                req.logger.warning("Ungültige Service-ID bei Anfrage /service/:sid")
                return try await createJSONErrorResponse(reason: "Ungültige Service-ID.", status: .badRequest, on: req)
            }

            guard let service = try await Service.find(serviceID, on: req.db) else {
                throw Abort(.notFound, reason: "Service nicht gefunden.")
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

            return try await createJSONResponse(with: responseDTOs, status: .ok, on: req)
        }

        // MARK: - Hilfsfunktionen

        /// Erstellt eine JSON-Antwort aus einem `Encodable` Objekt.
        private func createJSONResponse<T: Encodable>(with dto: T, status: HTTPStatus, on req: Request) async throws -> Response {
            let data = try JSONEncoder().encode(dto)
            var headers = HTTPHeaders()
            headers.contentType = .json
            return Response(status: status, headers: headers, body: .init(data: data))
        }
        
        /// Erstellt eine JSON-Fehlerantwort mit einer konsistenten Struktur.
        private func createJSONErrorResponse(reason: String, status: HTTPStatus, on req: Request) async throws -> Response {
            let errorResponse = ErrorResponse(error: true, reason: reason)
            return try await createJSONResponse(with: errorResponse, status: status, on: req)
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
                    req.logger.error("Fehler beim Senden der Webhook-Benachrichtigung an \(webhookURL): \(error.localizedDescription)")
                    // Fehler beim Senden der Webhook-Benachrichtigung werden geloggt, aber nicht geworfen.
                    // So wird vermieden, dass das eigentliche Update fehlschlägt.
                }
            }
        }

    

    // Struktur für eine konsistente Fehlerantwort
    struct ErrorResponse: Codable {
        let error: Bool
        let reason: String
    }
