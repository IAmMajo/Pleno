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
        
        let positions = routes.grouped("positions")
        
        // PUT /posters/positions/:positionid/hang
        positions.on(.PUT, ":positionid", "hang", body: .collect(maxSize: "7000kb"), use: hangPosterPosition).openAPI(
            tags: openAPITagPosterPosition,
            summary: "Hängt eine Poster-Position auf",
            description: """
                         Markiert eine bestimmte Poster-Position als aufgehängt.
                         """,
            path: .type(PosterPosition.IDValue.self),
            body: .type(HangPosterPositionDTO.self),
            contentType: .application(.json),
            response: .type(HangPosterPositionResponseDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        
        // PUT /posters/positions/:positionid/take-down
        positions.on(.PUT, ":positionid", "take-down", body: .collect(maxSize: "7000kb"), use: takeDownPosterPosition).openAPI(
            tags: openAPITagPosterPosition,
            summary: "Hängt eine Poster-Position ab",
            description: """
                         Markiert eine bestimmte Poster-Position als abgehängt.
                         """,
            path: .type(PosterPosition.IDValue.self),
            body: .type(TakeDownPosterPositionDTO.self),
            contentType: .application(.json),
            response: .type(TakeDownPosterPositionResponseDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        
        let adminRoutes = positions.grouped(adminMiddleware)
        
        // DELETE /posters/positions/:positionid (admin)
        adminRoutes.delete(":positionid", use: deletePosterPosition).openAPI(
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
        
        // DELETE /posters/positions/batch (admin)
        adminRoutes.delete("batch", use: deletePosterPositions).openAPI(
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
                                 """,
                    body: nil,
                    response: .type(PosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
                    auth: .bearer()
                )
                
                // Admin-geschützte Routen
                let adminRoutesPosterPositions = positions.grouped(adminMiddleware)
                
                // POST /posters/:id/positions (admin)
                adminRoutesPosterPositions.on(.POST, body: .collect(maxSize: "7000kb"), use: self.createPosterPosition).openAPI(
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
                                 """,
                    query: [],
                    path: .type(PosterPosition.IDValue.self),
                    body: .type(UpdatePosterPositionDTO.self),
                    contentType: .application(.json),
                    response: .type(PosterPositionResponseDTO.self),
                    responseContentType: .application(.json),
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
        let responsibleUserIDs = try await dto.responsibleUsers.uniqued().map { uuid in
            guard let user = try await User.find(uuid, on: req.db) else {
                throw Abort(.badRequest, reason: "Invalid user id '\(uuid)'.")
            }
            return try user.requireID()
        }
        
        // Neue PosterPosition erstellen
        let posterPosition = PosterPosition(
            posterId: posterId,
            latitude: dto.latitude,
            longitude: dto.longitude,
            expiresAt: dto.expiresAt
        )
        
        
        try await req.db.transaction { db in
            try await posterPosition.create(on: db)
            
            try await responsibleUserIDs.map { userID in
                try PosterPositionResponsibilities(userID: userID, posterPositionID: posterPosition.requireID())
            }.create(on: db)
        }
        
        // Verantwortlichkeiten neu laden
        try await posterPosition.$responsibilities.load(on: req.db)
        for responsibility in posterPosition.responsibilities {
            try await responsibility.$user.load(on: req.db)
            try await responsibility.user.$identity.load(on: req.db)
        }
        
        // DTO zurückgeben
        return try await posterPosition.toPosterPositionResponseDTO().encodeResponse(status: .created, for: req)
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
        
        return try position.toPosterPositionResponseDTO()
    }
    
    /// Gibt alle Positionen zu einem Poster zurück.
    @Sendable
    func getPostersPositions(_ req: Request) async throws -> [PosterPositionResponseDTO] {
        guard let poster = try await Poster.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await poster.$positions.query(on: req.db)
            .with(\.$responsibilities) { responsibilities in
                responsibilities.with(\.$user) { user in
                    user.with(\.$identity)
                }
            }
            .with(\.$posted_by)
            .with(\.$removed_by)
            .sort(\.$expires_at, .ascending)
            .all()
            .toPosterPositionResponseDTOArray()
    }
    
    /// Aktualisiert eine vorhandene PosterPosition (Location, Ablaufdatum, Verantwortlicher etc.).
    @Sendable
    func updatePosterPosition(_ req: Request) async throws -> PosterPositionResponseDTO {
        guard let positionId = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Ungültige Position-ID.")
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
        try await position.$responsibilities.load(on: req.db)
        for responsibility in position.responsibilities {
            try await responsibility.$user.load(on: req.db)
            try await responsibility.user.$identity.load(on: req.db)
        }
        
        
        // DTO zurückgeben
        return try position.toPosterPositionResponseDTO()
    }
    
    /// Markiert eine Poster-Position als aufgehängt (hängt Poster auf).
    @Sendable
    func hangPosterPosition(_ req: Request) async throws -> HangPosterPositionResponseDTO {
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
            posterPosition: try position.requireID(),
            postedAt: position.posted_at!,
            postedBy: try identity.requireID(),
            image: position.image!
        )
    }
    
    /// Markiert eine Poster-Position als abgehängt.
    @Sendable
    func takeDownPosterPosition(_ req: Request) async throws -> TakeDownPosterPositionResponseDTO {
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
        
        return try TakeDownPosterPositionResponseDTO(
            posterPosition: position.requireID(),
            removedAt: position.removed_at!,
            removedBy: try identity.requireID(),
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

