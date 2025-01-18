import Fluent
import Vapor
import Foundation
import Models
import VaporToOpenAPI
import PosterServiceDTOs

/// Controller für Poster und PosterPositionen.
/// Dieser Controller enthält Routen zum Erstellen, Aktualisieren, Löschen und Abrufen von Postern und deren Positionen.
struct PosterPositionController: RouteCollection, Sendable {
    
    let adminMiddleware: Middleware
    
    init() throws {
        self.adminMiddleware = AdminMiddleware()
    }
    
    func boot(routes: RoutesBuilder) throws {
        let openAPITagPosterPosition = TagObject(name: "Poster Position")
        
        routes.group(":id") { poster in
            // /posters/:id/positions
            poster.group("positions") { positions in
                
                // GET /posters/:id/positions/:positionid
                positions.get(":positionid", use: getPostersPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Gibt eine einzelne Poster Position zurück",
                    description: """
                                 Diese Route gibt eine Poster-Position zurück mit dem zugehörigen Status.
                                 """,
                    path: .type(PosterPosition.IDValue.self),
                    body: nil,
                    response: .type(PosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // GET /posters/:id/positions
                positions.get(use: getPostersPositions).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Poster Positionen abfragen",
                    description: """
                                 Diese Route gibt eine Liste von Poster-Positionen zurück. 
                                 Über `page` und `per` kann paginiert, über `status` gefiltert werden.
                                 """,
                    query: ["page": .integer, "per": .integer, "status": .string],
                    body: nil,
                    response: .type(PosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // PUT /posters/:id/positions/:positionid/hang
                positions.on(.PUT,":positionid","hang",body: .collect(maxSize: "7000kb"), use: hangPosterPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Hängt eine Poster-Position auf",
                    description: """
                                 Markiert eine bestimmte Poster-Position als aufgehängt. Die Aktion wird als `multipart/form-data` gesendet ...
                                 """,
                    path: .type(PosterPosition.IDValue.self),
                    body: .type(HangPosterPositionDTO.self),
                    contentType: .multipart(.formData),
                    response: .type(HangPosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // PUT /posters/:id/positions/:positionid/take-down
                positions.on(.PUT ,":positionid" ,"takeDown",body: .collect(maxSize: "7000kb"), use: takeDownPosterPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Hängt eine Poster-Position ab",
                    description: """
                                 Markiert eine bestimmte Poster-Position als abgehängt. Die Aktion wird als `multipart/form-data` gesendet ...
                                 """,
                    path: .type(PosterPosition.IDValue.self),
                    body: .type(TakeDownPosterPositionDTO.self),
                    contentType: .application(.json),
                    response: .type(TakeDownPosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // Admin-geschützte Routen
                let adminRoutesPosterPositions = positions.grouped(adminMiddleware)
                
                // POST /posters/:id/positions (admin)
                adminRoutesPosterPositions.on(.POST,body: .collect(maxSize: "7000kb"),use: self.createPosterPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Erstellt eine neue Poster-Position",
                    description: """
                                 Erstellt eine neue Poster-Position. Die Request kann nur von einem Admin erstellt werden ...
                                 """,
                    query: [],
                    body: .type(CreatePosterPositionDTO.self),
                    contentType: .application(.json),
                    response: .type(PosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // PATCH /posters/:id/positions/:positionid (admin)
                adminRoutesPosterPositions.on(.PATCH,":positionid",body: .collect(maxSize: "7000kb"), use: updatePosterPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Aktualisiert eine bestehende Poster-Position",
                    description: """
                                 Aktualisiert eine vorhandene Poster-Position anhand ihrer ID. 
                                 Der Request muss als `multipart/form-data` gesendet werden ...
                                 """,
                    query: [],
                    path: .type(PosterPosition.IDValue.self),
                    body: .type(UpdatePosterPositionDTO.self),
                    contentType: .multipart(.formData),
                    response: .type(PosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // DELETE /posters/:id/positions/:positionid (admin)
                adminRoutesPosterPositions.delete(":positionid", use: deletePosterPosition).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Löscht eine Poster-Position",
                    description: """
                                 Löscht eine vorhandene Poster-Position anhand ihrer ID, nur für Admins ...
                                 """,
                    query: [],
                    path: .type(PosterPosition.IDValue.self),
                    statusCode: .noContent,
                    auth: .bearer()
                )
                
                // DELETE /posters/:id/positions/batch (admin)
                adminRoutesPosterPositions.delete("batch", use: deletePosterPositions).openAPI(
                    tags: openAPITagPosterPosition,
                    summary: "Löscht mehrere Poster Positionen",
                    description: """
                                 Löscht mehrere Poster-Positionen anhand einer Liste von IDs, nur für Admins ...
                                 """,
                    query: [],
                    body: .type(DeleteDTO.self),
                    contentType: .application(.json),
                    statusCode: .noContent,
                    auth: .bearer()
                )
            }
        }
    }
    
    // MARK: - PosterPosition-Routen
    
    /// Erstellt eine neue PosterPosition mit Bild und speichert sie in der Datenbank.
    /// Gibt 201 (Created) + das erstellte Objekt zurück.
    @Sendable
    func createPosterPosition(_ req: Request) async throws -> Response {
        let dto = try req.content.decode(CreatePosterPositionDTO.self)
        
        guard let posterId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Poster-ID.")
        }
        
        // Prüfen der Koordinaten
        guard (-90...90).contains(dto.latitude) else {
            throw Abort(.badRequest, reason: "Latitude muss zwischen -90 und 90 liegen.")
        }
        guard (-180...180).contains(dto.longitude) else {
            throw Abort(.badRequest, reason: "Longitude muss zwischen -180 und 180 liegen.")
        }
        
        // Neue PosterPosition erstellen
        let posterPosition = PosterPosition(
            posterId: posterId,
            latitude: dto.latitude,
            longitude: dto.longitude,
            expiresAt: dto.expiresAt
        )
        try await posterPosition.create(on: req.db)
        
        // Verantwortliche User abgleichen
        let userIDs = dto.responsibleUsers
        let existingUsers = try await User.query(on: req.db)
            .filter(\.$id ~~ userIDs)
            .all()
        let existingUserIDs = Set(existingUsers.compactMap { $0.id })
        let validUserIDs = userIDs.filter { existingUserIDs.contains($0) }
        
        for userId in validUserIDs {
            let responsibility = PosterPositionResponsibilities(
                userID: userId,
                posterPositionID: posterPosition.id!
            )
            try await responsibility.save(on: req.db)
        }
        
        // Verantwortlichkeiten laden
        let responsibilities = try await PosterPositionResponsibilities.query(on: req.db)
            .filter(\.$poster_position.$id == posterPosition.id!)
            .with(\.$user) { user in
                user.with(\.$identity) // Eager load Identity
            }
            .all()
        
        let responsibleUsers = responsibilities.compactMap { rsp -> ResponsibleUsersDTO? in
            let user = rsp.user
            // user.identity muss geladen sein
            return ResponsibleUsersDTO(
                id: user.id!,
                name: user.identity.name
            )
        }
        
        let responseDTO = PosterPositionResponseDTO(
            id: posterPosition.id!,
            posterId: posterPosition.$poster.id,
            latitude: posterPosition.latitude,
            longitude: posterPosition.longitude,
            postedBy: posterPosition.posted_by?.name,
            postedAt: posterPosition.posted_at,
            expiresAt: posterPosition.expires_at!,
            removedBy: posterPosition.removed_by?.name,
            removedAt: posterPosition.removed_at,
            image: posterPosition.image,
            responsibleUsers: responsibleUsers,
            status: "Created"
        )
        
        // Manuell eine Response mit Status .created zurückgeben
        let encoded = try JSONEncoder().encode(responseDTO)
        var headers = HTTPHeaders()
        headers.contentType = .json
        return Response(status: .created, headers: headers, body: .init(data: encoded))
    }
    
    /// Gibt eine einzelne PosterPosition als DTO zurück.
    @Sendable
    func getPostersPosition(_ req: Request) async throws -> PosterPositionResponseDTO {
        guard let positionId = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Position-ID.")
        }
        
        let position = try await PosterPosition.query(on: req.db)
            .with(\.$responsibilities) { responsibilities in
                responsibilities.with(\.$user) { user in
                    user.with(\.$identity)
                }
            }
            .with(\.$posted_by)
            .with(\.$removed_by)
            .filter(\.$id == positionId)
            .first()
        
        guard let position = position else {
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden")
        }
        
        // Status ermitteln
        let currentDate = Date()
        var status = ""
        if position.posted_by != nil && position.removed_by == nil {
            status = "hangs"
        } else if position.posted_by == nil {
            status = "toHang"
        } else if position.removed_by != nil {
            status = "takenDown"
        }
        if position.posted_by != nil && position.removed_by == nil && position.expires_at! <= currentDate {
            status = "overdue"
        }
        
        return position.posterPositionMapToDTO(status)
    }
    
    /// Gibt alle Positionen zu einem Poster zurück, gefiltert über `status` + optionale Paginierung.
    @Sendable
    func getPostersPositions(_ req: Request) async throws -> Response {
        guard let posterId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Poster-ID.")
        }
        
        let statusQuery = (try? req.query.get(String.self, at: "status"))?.lowercased()
        let page = try? req.query.get(Int.self, at: "page")
        let per = try? req.query.get(Int.self, at: "per")
        let currentDate = Date()
        
        // Kleine Hilfsfunktion für paginierte Abfragen über Fluent
        func handlePagination(
            query: QueryBuilder<PosterPosition>,
            status: String
        ) async throws -> Response {
            if let page = page, let per = per {
                let paginatedData = try await query.paginate(PageRequest(page: page, per: per))
                let dtos = paginatedData.items.map { $0.posterPositionMapToDTO(status) }
                
                // Kopfzeilen für Pagination setzen
                let metadata = paginatedData.metadata
                let totalPages = Int(ceil(Double(metadata.total) / Double(metadata.per)))
                
                var headers = HTTPHeaders()
                headers.add(name: .contentType, value: "application/json")
                headers.add(name: "Pagination-Current-Page", value: "\(metadata.page)")
                headers.add(name: "Pagination-Per-Page", value: "\(metadata.per)")
                headers.add(name: "Pagination-Total-Items", value: "\(metadata.total)")
                headers.add(name: "Pagination-Total-Pages", value: "\(totalPages)")
                
                let encoded = try JSONEncoder().encode(dtos)
                return Response(status: .ok, headers: headers, body: .init(data: encoded))
            } else {
                // Ohne Paginierung
                let positions = try await query.all()
                let dtos = positions.map { $0.posterPositionMapToDTO(status) }
                
                let encoded = try JSONEncoder().encode(dtos)
                var headers = HTTPHeaders()
                headers.add(name: .contentType, value: "application/json")
                return Response(status: .ok, headers: headers, body: .init(data: encoded))
                
            }
        }
        
        switch statusQuery {
        case "hangs":
            let query = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { $0.with(\.$user) { $0.with(\.$identity) } }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .sort(\.$expires_at, .ascending)
            return try await handlePagination(query: query, status: "hangs")
            
        case "tohang":
            let query = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { $0.with(\.$user) { $0.with(\.$identity) } }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id == nil)
                .filter(\.$expires_at > currentDate)
                .sort(\.$expires_at, .ascending)
            return try await handlePagination(query: query, status: "toHang")
            
        case "overdue":
            let query = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { $0.with(\.$user) { $0.with(\.$identity) } }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .filter(\.$expires_at <= currentDate)
                .sort(\.$expires_at, .ascending)
            return try await handlePagination(query: query, status: "overdue")
            
        case "takendown":
            let query = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { $0.with(\.$user) { $0.with(\.$identity) } }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$removed_by.$id != nil)
                .sort(\.$expires_at, .ascending)
            return try await handlePagination(query: query, status: "takenDown")
            
        default:
            // Kombiniere hangs + toHang + overdue
            let hangsQuery = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { $0.with(\.$user) { $0.with(\.$identity) } }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .sort(\.$expires_at, .ascending)
            
            let toHangQuery = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { $0.with(\.$user) { $0.with(\.$identity) } }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id == nil)
                .filter(\.$expires_at > currentDate)
                .sort(\.$expires_at, .ascending)
            
            let overdueQuery = PosterPosition.query(on: req.db)
                .filter(\.$poster.$id == posterId)
                .with(\.$responsibilities) { $0.with(\.$user) { $0.with(\.$identity) } }
                .with(\.$posted_by)
                .with(\.$removed_by)
                .filter(\.$posted_by.$id != nil)
                .filter(\.$removed_by.$id == nil)
                .filter(\.$expires_at <= currentDate)
                .sort(\.$expires_at, .ascending)
            
            let (hangs, toHang, overdue) = try await (
                hangsQuery.all(),
                toHangQuery.all(),
                overdueQuery.all()
            )
            
            let combined = hangs.map { $0.posterPositionMapToDTO("hangs") }
            + toHang.map { $0.posterPositionMapToDTO("toHang") }
            + overdue.map { $0.posterPositionMapToDTO("overdue") }
            
            // Falls page & per in der Query -> manuelle Pagination
            if let page = page, let per = per {
                let totalItems = combined.count
                let totalPages = Int((Double(totalItems) / Double(per)).rounded(.up))
                let start = (page - 1) * per
                let end = min(start + per, totalItems)
                
                // Wenn die Paginierungswerte zu keiner gültigen Teilmenge führen -> Error
                guard start < end else {
                    throw Abort(.badRequest, reason: "Ungültige Paginierungs-Parameter.")
                }
                
                let pagedItems = Array(combined[start..<end])
                
                var headers = HTTPHeaders()
                headers.contentType = .json
                headers.add(name: "Pagination-Current-Page", value: "\(page)")
                headers.add(name: "Pagination-Per-Page", value: "\(per)")
                headers.add(name: "Pagination-Total-Items", value: "\(totalItems)")
                headers.add(name: "Pagination-Total-Pages", value: "\(totalPages)")
                
                let encoded = try JSONEncoder().encode(pagedItems)
                return Response(status: .ok, headers: headers, body: .init(data: encoded))
            } else {
                let encoded = try JSONEncoder().encode(combined)
                var headers = HTTPHeaders()
                headers.add(name: .contentType, value: "application/json")
                return Response(status: .ok, headers: headers, body: .init(data: encoded))
                
            }
        }
    }
    
    /// Aktualisiert eine vorhandene PosterPosition (Location, Ablaufdatum, Verantwortlicher etc.).
    @Sendable
    func updatePosterPosition(_ req: Request) async throws -> PosterPositionResponseDTO {
        guard let positionId = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Position-ID.")
        }
        
        guard let contentType = req.headers.contentType,
              contentType.type == "multipart",
              contentType.subType == "form-data" else {
            throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
        }
        
        let dto = try req.content.decode(UpdatePosterPositionDTO.self)
        
        guard let position = try await PosterPosition.query(on: req.db)
            .with(\.$posted_by)
            .with(\.$removed_by)
            .filter(\.$id == positionId)
            .first()
        else {
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden.")
        }

        
        // Nur updaten, was im DTO vorhanden ist
        if let newLatitude = dto.latitude {
            position.latitude = round(newLatitude * 1_000_000) / 1_000_000
        }
        if let newLongitude = dto.longitude {
            position.longitude = round(newLongitude * 1_000_000) / 1_000_000
        }
        if let newExpiresAt = dto.expiresAt {
            position.expires_at = newExpiresAt
        }
        if let newPosterId = dto.posterId {
            position.$poster.id = newPosterId
        }
        
        // Verantwortlichkeiten nur aktualisieren, wenn `responsibleUsers` im DTO enthalten war
        if let newResponsibleUsers = dto.responsibleUsers {
            let currentResponsibilities = try await PosterPositionResponsibilities.query(on: req.db)
                .filter(\.$poster_position.$id == positionId)
                .all()
            let currentUserIds = Set(currentResponsibilities.map { $0.$user.id })
            let newUserIds = Set(newResponsibleUsers)
            
            // Neue hinzufügen
            let toAdd = newUserIds.subtracting(currentUserIds)
            for userId in toAdd {
                let responsibility = PosterPositionResponsibilities(userID: userId, posterPositionID: positionId)
                try await responsibility.save(on: req.db)
            }
            
            // Entfernen, was nicht mehr benötigt wird
            let toRemove = currentUserIds.subtracting(newUserIds)
            if !toRemove.isEmpty {
                try await PosterPositionResponsibilities.query(on: req.db)
                    .filter(\.$poster_position.$id == positionId)
                    .filter(\.$user.$id ~~ toRemove)
                    .delete()
            }
        }
        
        // Bild updaten
        if let newImage = dto.image {
            position.image = newImage
        }
        
        try await position.update(on: req.db)
        
        // Verantwortlichkeiten neu laden
        let updatedResponsibilities = try await PosterPositionResponsibilities.query(on: req.db)
            .filter(\.$poster_position.$id == positionId)
            .with(\.$user) { u in
                u.with(\.$identity)
            }
            .all()
        let responsibleUsers = updatedResponsibilities.compactMap { rsp -> ResponsibleUsersDTO in
            let userId = rsp.$user.id
            let identityName = rsp.user.identity.name
            return ResponsibleUsersDTO(id: userId, name: identityName)
        }
    

        // DTO zurückgeben
        return PosterPositionResponseDTO(
            id: position.id!,
            posterId: position.$poster.id,
            latitude: position.latitude,
            longitude: position.longitude,
            postedBy: position.$posted_by.value??.name,
            postedAt: position.posted_at,
            expiresAt: position.expires_at!,
            removedBy: position.$removed_by.value??.name,
            removedAt: position.removed_at,
            image: position.image,
            responsibleUsers: responsibleUsers,
            status: "Updated"
        )
    }
    
    /// Markiert eine Poster-Position als aufgehängt (hängt Poster auf).
    @Sendable
    func hangPosterPosition(_ req: Request) async throws -> HangPosterPositionResponseDTO {
        guard let contentType = req.headers.contentType,
              contentType.type == "multipart",
              contentType.subType == "form-data" else {
            throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
        }
        
        guard let positionId = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Position-ID.")
        }
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        
        let dto = try req.content.decode(HangPosterPositionDTO.self)
        
        guard let position = try await PosterPosition.query(on: req.db)
            .filter(\.$id == positionId)
            .with(\.$responsibilities)
            .first() else {
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden")
        }
        
        guard position.responsibilities.contains(where: { $0.$user.id == userId }) else {
            throw Abort(.forbidden, reason: "Sie sind nicht verantwortlich für diese PosterPosition.")
        }
        
        // Schon aufgehängt?
        if position.posted_by != nil || position.posted_at != nil {
            throw Abort(.badRequest, reason: "Diese PosterPosition ist bereits aufgehängt.")
        }
        
        // posted_by: Identity des aktuellen Users
        let identity = try await Identity.byUserId(userId, req.db)
        
        position.image = dto.image
        position.posted_at = Date()
        position.$posted_by.id = identity.id
        try await position.save(on: req.db)
        
        return HangPosterPositionResponseDTO(
            posterPosition: position.id!,
            postedAt: position.posted_at!,
            postedBy: identity.id!,
            image: position.image!
        )
    }
    
    /// Markiert eine Poster-Position als abgehängt.
    @Sendable
    func takeDownPosterPosition(_ req: Request) async throws -> TakeDownPosterPositionResponseDTO {
        guard let contentType = req.headers.contentType,
              contentType.type == "multipart",
              contentType.subType == "form-data" else {
            throw Abort(.unsupportedMediaType, reason: "Erwartet multipart/form-data")
        }
        
        guard let positionId = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Position-ID.")
        }
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        
        let dto = try req.content.decode(TakeDownPosterPositionDTO.self)
        
        guard let position = try await PosterPosition.query(on: req.db)
            .filter(\.$id == positionId)
            .with(\.$responsibilities)
            .first() else {
            throw Abort(.notFound, reason: "PosterPosition nicht gefunden")
        }
        
        guard position.responsibilities.contains(where: { $0.$user.id == userId }) else {
            throw Abort(.forbidden, reason: "Sie sind nicht verantwortlich für diese PosterPosition.")
        }
        
        if position.removed_by != nil || position.removed_at != nil {
            throw Abort(.badRequest, reason: "Diese PosterPosition ist bereits abgehängt worden.")
        }
        
        let identity = try await Identity.byUserId(userId, req.db)
        
        position.image = dto.image
        position.removed_at = Date()
        position.$removed_by.id = identity.id
        try await position.save(on: req.db)
        
        return TakeDownPosterPositionResponseDTO(
            posterPosition: position.id!,
            removedAt: position.removed_at!,
            removedBy: identity.id!,
            image: position.image!
        )
    }
    
    /// Löscht eine einzelne PosterPosition und deren zugehörige Daten.
    @Sendable
    func deletePosterPosition(_ req: Request) async throws -> HTTPStatus {
        guard let positionID = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige PosterPosition-ID.")
        }
        
        guard let position = try await PosterPosition.find(positionID, on: req.db) else {
            throw Abort(.notFound, reason: "PosterPosition mit der ID \(positionID) wurde nicht gefunden.")
        }
        
        try await position.delete(on: req.db)
        return .noContent
    }
    
    /// Löscht mehrere PosterPositionen in einem Batch.
    @Sendable
    func deletePosterPositions(_ req: Request) async throws -> HTTPStatus {
        let deleteDTO = try req.content.decode(DeleteDTO.self)
        let positionIDs = deleteDTO.ids
        
        guard !positionIDs.isEmpty else {
            throw Abort(.badRequest, reason: "Es müssen mindestens eine PosterPosition-ID übergeben werden.")
        }
        
        let positionsToDelete = try await PosterPosition.query(on: req.db)
            .filter(\.$id ~~ positionIDs)
            .all()
        
        if positionsToDelete.count != positionIDs.count {
            let foundIDs = Set(positionsToDelete.compactMap { $0.id })
            let notFoundIDs = positionIDs.filter { !foundIDs.contains($0) }
            throw Abort(.notFound, reason: "PosterPositionen mit den folgenden IDs wurden nicht gefunden: \(notFoundIDs.map { $0.uuidString }.joined(separator: ", "))")
        }
        
        for position in positionsToDelete {
            try await position.delete(on: req.db)
        }
        
        return .noContent
    }
}

