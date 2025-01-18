import Fluent
import Vapor
import Foundation
import Models
import VaporToOpenAPI
import PosterServiceDTOs

// MARK: - Fehlerdefinitionen für Poster-Erstellung und -Verwaltung
enum PosterCreationError: AbortError {
    case invalidContentType
    case invalidFormData(reason: String)
    case imageSaveFailed
    case databaseSaveFailed
    case unknownError
    case settingFetchFailed(reason: String)
    
    var status: HTTPResponseStatus {
        switch self {
        case .invalidContentType:
            return .unsupportedMediaType
        case .invalidFormData:
            return .badRequest
        case .imageSaveFailed, .databaseSaveFailed, .settingFetchFailed, .unknownError:
            return .internalServerError
        }
    }
    
    var reason: String {
        switch self {
        case .invalidContentType:
            return "Erwartet multipart/form-data"
        case .invalidFormData(let reason):
            return "Ungültige Formulardaten: \(reason)"
        case .imageSaveFailed:
            return "Fehler beim Speichern des Bildes"
        case .databaseSaveFailed:
            return "Fehler beim Speichern des Posters in der Datenbank"
        case .settingFetchFailed(let reason):
            return "Fehler beim Abrufen der 'poster_deletion_interval' Einstellung: \(reason)"
        case .unknownError:
            return "Unbekannter Fehler"
        }
    }
}

// MARK: - PosterController

/// Controller für Poster
/// Dieser Controller enthält Routen zum Erstellen, Aktualisieren, Löschen und Abrufen von Postern.
struct PosterController: RouteCollection, Sendable {
    let adminMiddleware: Middleware
    
    /// Initialisiert den `PosterController` mit Admin-Middleware.
    init() throws {
        self.adminMiddleware = AdminMiddleware()
    }
    
    /// Registriert alle Routen des Controllers.
    func boot(routes: RoutesBuilder) throws {
        let openAPITagPoster = TagObject(name: "Poster")
        
        routes.get("summary", use: getPostersSummary)
            .openAPI(
                tags: openAPITagPoster,
                summary: "Anzahl der verschiedenen PosterPositionen Staten abfragen",
                description: """
                            Diese Route gibt die Staten hangs, toHang, overdue und takenDown als numerische Werte zurück.
                            """,
                body: nil,
                response: .type(PosterSummaryResponseDTO.self),
                responseContentType: .application(.json),
                auth: .bearer()
            )
        
        // GET /posters/:id
        routes.get(":id", use: getPoster)
            .openAPI(
                tags: openAPITagPoster,
                summary: "Einzelnes Poster abfragen",
                description: "Gibt ein einzelnes Poster anhand seiner ID zurück.",
                path: .type(Poster.IDValue.self),
                body: nil,
                response: .type(PosterResponseDTO.self),
                responseContentType: .application(.json),
                auth: .bearer()
            )
        
        // GET /posters
        routes.get(use: getPosters)
            .openAPI(
                tags: openAPITagPoster,
                summary: "Alle verfügbaren Poster abfragen",
                description: """
                    Diese Route gibt eine Liste aller verfügbaren Poster zurück. Optional können über die
                    Query-Parameter `page` und `per` eine Pagination vorgenommen werden.
                    """,
                query: ["page": .integer, "per": .integer],
                body: nil,
                response: .type(PosterResponseDTO.self),
                responseContentType: .application(.json),
                auth: .bearer()
            )
        
        // POST /posters
        routes.on(.POST, body: .collect(maxSize: "7000kb"), use: createPoster)
            .openAPI(
                tags: openAPITagPoster,
                summary: "Erstellt ein neues Poster",
                description: """
                    Diese Route ermöglicht das Erstellen eines neuen Posters. Der Request muss als `multipart/form-data`
                    gesendet werden und sollte mindestens einen Namen (`name`) sowie ein Bild (`image`) enthalten.
                    """,
                query: [],
                body: .type(CreatePosterDTO.self),
                contentType: .multipart(.formData),
                response: .type(PosterResponseDTO.self),
                responseContentType: .application(.json),
                auth: .bearer()
            )
        
        // PATCH /posters/:id
        routes.on(.POST, ":id", body: .collect(maxSize: "7000kb"), use: updatePoster)
            .openAPI(
                tags: openAPITagPoster,
                summary: "Updatet ein Poster",
                description: """
                    Aktualisiert ein vorhandenes Poster basierend auf seiner ID. Der Request muss als `multipart/form-data` 
                    gesendet werden und kann Felder wie `name`, `description` oder ein neues `image` enthalten.
                    """,
                query: [],
                path: .type(Poster.IDValue.self),
                body: .type(UpdatePosterDTO.self),
                contentType: .multipart(.formData),
                response: .type(PosterResponseDTO.self),
                responseContentType: .application(.json),
                auth: .bearer()
            )
        
        // Admin-geschützte Routen
        let adminRoutesPoster = routes.grouped(adminMiddleware)
        
        // DELETE /posters/:id (admin)
        adminRoutesPoster.delete(":id", use: deletePoster)
            .openAPI(
                tags: openAPITagPoster,
                summary: "Löscht ein Poster",
                description: """
                    Löscht ein vorhandenes Poster anhand seiner ID. Das zugehörige Bild wird ebenfalls entfernt.
                    Außerdem werden die zugehörigen Poster Positionen samt Bildern gelöscht.
                    """,
                query: [],
                path: .type(Poster.IDValue.self),
                statusCode: .noContent,
                auth: .bearer()
            )
        
        // DELETE /posters/batch (admin)
        adminRoutesPoster.delete("batch", use: deletePosters)
            .openAPI(
                tags: openAPITagPoster,
                summary: "Löscht mehrere Poster",
                description: """
                    Löscht mehrere Poster anhand einer Liste von IDs. Die zugehörigen Bilder werden ebenfalls entfernt.
                    Außerdem werden die zugehörigen Poster Positionen samt Bildern gelöscht.
                    """,
                query: [],
                body: .type(DeleteDTO.self),
                contentType: .application(.json),
                statusCode: .noContent,
                auth: .bearer()
            )
    }
    
    // MARK: - Poster-Routen
    
    /// Erstellt ein neues Poster aus multipart/form-data.
    /// Erwartet mindestens `name` und `image` im Request Body.
    @Sendable
    func createPoster(_ req: Request) async throws -> PosterResponseDTO {
        // Überprüfen des Content-Types
        guard let contentType = req.headers.contentType,
              contentType.type == "multipart",
              contentType.subType == "form-data" else {
            throw PosterCreationError.invalidContentType
        }
        
        let posterData: CreatePosterDTO
        do {
            posterData = try req.content.decode(CreatePosterDTO.self)
        } catch {
            throw PosterCreationError.invalidFormData(reason: "Fehler beim Dekodieren der Formulardaten.")
        }
        
        guard !posterData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PosterCreationError.invalidFormData(reason: "Name darf nicht leer sein.")
        }
        
        // Neuen Poster-Datensatz anlegen und speichern
        let poster = Poster(
            name: posterData.name,
            description: posterData.description,
            image: posterData.image
        )
        
        do {
            try await poster.create(on: req.db)
        } catch {
            req.logger.error("Datenbankspeicherung fehlgeschlagen: \(error.localizedDescription)")
            throw PosterCreationError.databaseSaveFailed
        }
        
        // Antwort-DTO zurückgeben (Vapor encodiert es automatisch als JSON)
        return PosterResponseDTO(
            id: poster.id!,
            name: poster.name,
            description: poster.description,
            image: poster.image
        )
    }
    
    /// Einzelnes Poster anhand seiner ID abrufen.
    @Sendable
    func getPoster(_ req: Request) async throws -> PosterResponseDTO {
        guard let posterId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Poster-ID.")
        }
        
        guard let poster = try await Poster.find(posterId, on: req.db) else {
            throw Abort(.notFound, reason: "Poster nicht gefunden.")
        }
        
        return PosterResponseDTO(
            id: poster.id!,
            name: poster.name,
            description: poster.description,
            image: poster.image
        )
    }
    
    /// Liste von Postern zurückgeben (mit optionaler Paginierung).
    @Sendable
    func getPosters(_ req: Request) async throws -> Response {
        let page = try? req.query.get(Int.self, at: "page")
        let per = try? req.query.get(Int.self, at: "per")
        
        if let page = page, let per = per {
            // Falls gewünscht: Paginierung mit Fluent
            let paginatedData = try await Poster.query(on: req.db)
                .paginate(PageRequest(page: page, per: per))
            
            let responseDTOs = paginatedData.items.map { poster in
                PosterResponseDTO(
                    id: poster.id!,
                    name: poster.name,
                    description: poster.description,
                    image: poster.image
                )
            }
            
            // Manuelle Header setzen
            let currentPage = paginatedData.metadata.page
            let perPage = paginatedData.metadata.per
            let totalItems = paginatedData.metadata.total
            let totalPages = Int((Double(totalItems) / Double(perPage)).rounded(.up))
            
            // Result als Response encodieren, Headers hinzufügen
            var headers = HTTPHeaders()
            headers.add(name: "Pagination-Current-Page", value: "\(currentPage)")
            headers.add(name: "Pagination-Per-Page", value: "\(perPage)")
            headers.add(name: "Pagination-Total-Items", value: "\(totalItems)")
            headers.add(name: "Pagination-Total-Pages", value: "\(totalPages)")
            
            // Encoden als JSON:
            let encodedBody = try Response.Body(data: JSONEncoder().encode(responseDTOs))
            return Response(status: .ok, headers: headers, body: encodedBody)
            
        } else {
            // Keine Pagination
            let posters = try await Poster.query(on: req.db).all()
            let responseDTOs = posters.map { poster in
                PosterResponseDTO(
                    id: poster.id!,
                    name: poster.name,
                    description: poster.description,
                    image: poster.image
                )
            }
            // Direkt als JSON zurückgeben
            return try Response(status: .ok,
                                headers: ["Content-Type": "application/json"],
                                body: .init(data: JSONEncoder().encode(responseDTOs)))
        }
    }
    
    /// Überblicks-Statistiken über PosterPositionen zurückgeben.
    @Sendable
    func getPostersSummary(_ req: Request) async throws -> PosterSummaryResponseDTO {
        let currentDate = Date()
        
        // 1. "hangs": posted_by != nil && removed_by == nil
        let hangsCount = try await PosterPosition.query(on: req.db)
            .filter(\.$posted_by.$id != nil)
            .filter(\.$removed_by.$id == nil)
            .count()
        
        // 2. "toHang": posted_by == nil && expires_at > currentDate
        let toHangCount = try await PosterPosition.query(on: req.db)
            .filter(\.$posted_by.$id == nil)
            .filter(\.$expires_at > currentDate)
            .count()
        
        // 3. "overdue": posted_by != nil && removed_by == nil && expires_at <= currentDate
        let overdueCount = try await PosterPosition.query(on: req.db)
            .filter(\.$posted_by.$id != nil)
            .filter(\.$removed_by.$id == nil)
            .filter(\.$expires_at <= currentDate)
            .count()
        
        // 4. "takenDown": removed_by != nil
        let takenDownCount = try await PosterPosition.query(on: req.db)
            .filter(\.$removed_by.$id != nil)
            .count()
        
        // Zusammenbauen des DTO
        return PosterSummaryResponseDTO(
            hangs: hangsCount,
            toHang: toHangCount,
            overdue: overdueCount,
            takenDown: takenDownCount
        )
    }
    
    /// Aktualisiert ein bestehendes Poster (Name, Beschreibung und/oder Bild).
    @Sendable
    func updatePoster(_ req: Request) async throws -> PosterResponseDTO {
        guard let posterId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Poster-ID.")
        }
        
        guard let contentType = req.headers.contentType,
              contentType.type == "multipart",
              contentType.subType == "form-data" else {
            throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
        }
        
        let dto = try req.content.decode(UpdatePosterDTO.self)
        
        guard let poster = try await Poster.find(posterId, on: req.db) else {
            throw Abort(.notFound, reason: "Poster nicht gefunden.")
        }
        
        if let name = dto.name {
            poster.name = name
        }
        if let description = dto.description {
            poster.description = description
        }
        if let image = dto.image {
            poster.image = image
        }
        
        try await poster.save(on: req.db)
        
        return PosterResponseDTO(
            id: poster.id!,
            name: poster.name,
            description: poster.description,
            image: poster.image
        )
    }
    
    /// Löscht ein einzelnes Poster sowie zugehörige PosterPositionen inkl. Bilder.
    @Sendable
    func deletePoster(_ req: Request) async throws -> HTTPStatus {
        guard let posterID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Poster-ID.")
        }
        
        guard let poster = try await Poster.find(posterID, on: req.db) else {
            throw Abort(.notFound, reason: "Poster mit der ID \(posterID) wurde nicht gefunden.")
        }
        
        // Poster löschen
        try await poster.delete(on: req.db)
        
        return .noContent
    }
    
    /// Löscht mehrere Poster und deren zugehörige Positionen in einem Batch.
    @Sendable
    func deletePosters(_ req: Request) async throws -> HTTPStatus {
        let deleteDTO = try req.content.decode(DeleteDTO.self)
        let posterIDs = deleteDTO.ids
        
        guard !posterIDs.isEmpty else {
            throw Abort(.badRequest, reason: "Es müssen mindestens eine Poster-ID übergeben werden.")
        }
        
        // Alle Poster laden, die gelöscht werden sollen
        let postersToDelete = try await Poster.query(on: req.db)
            .filter(\.$id ~~ posterIDs)
            .all()
        
        // Prüfen, ob alle IDs existieren
        if postersToDelete.count != posterIDs.count {
            let foundIDs = Set(postersToDelete.compactMap { $0.id })
            let notFoundIDs = posterIDs.filter { !foundIDs.contains($0) }
            throw Abort(.notFound, reason: "Poster mit diesen IDs wurden nicht gefunden: \(notFoundIDs.map { $0.uuidString }.joined(separator: ", "))")
        }
        
        // Alle gefundene Poster löschen
        for poster in postersToDelete {
            try await poster.delete(on: req.db)
        }
        
        return .noContent
    }
}
