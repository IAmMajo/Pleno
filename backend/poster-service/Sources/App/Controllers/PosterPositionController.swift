import Fluent
import Vapor
import Foundation
import Models
import VaporToOpenAPI
import PosterServiceDTOs

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
        
        // PUT /posters/positions/:positionid/report-damage
        positions.on(.PUT, ":positionid", "report-damage", body: .collect(maxSize: "7000kb"), use: reportDamagedPosterPosition).openAPI(
            tags: openAPITagPosterPosition,
            summary: "Meldet eine Poster-Position als beschädigt",
            description: """
                         Markiert eine bestimmte Poster-Position als beschädigt.
                         """,
            path: .type(PosterPosition.IDValue.self),
            body: .type(ReportDamagedPosterPositionDTO.self),
            contentType: .application(.json),
            response: .type(PosterPositionResponseDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        // GET /posters/positions/:positionid/image
        positions.get(":positionid", "image", use: getImage).openAPI(
            tags: openAPITagPosterPosition,
            summary: "Gibt das Bild zur zugehörigen PosterPosition zurück",
            description: """
                         Gibt das Bild zur zugehörigen PosterPosition zurück
                         """,
            path: .type(PosterPosition.IDValue.self),
            response: .type(ImageDTO.self),
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
    
    /// Erstellt eine neue PosterPositionen
    @Sendable
    func createPosterPosition(_ req: Request) async throws -> Response {
        guard let dto = try? req.content.decode(CreatePosterPositionDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreatePosterPositionDTO.")
        }
        
        guard let posterId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid Poster-ID.")
        }
    
        guard let posterPosition = try? await dto.toPosterPosition(posterId: posterId, on: req.db) else {
            throw Abort(.internalServerError)
        }
        
        return try await posterPosition.toPosterPositionResponseDTO().encodeResponse(status: .created, for: req)
    }
    
    /// Gibt eine PosterPositionen eines Posters zurück
    @Sendable
    func getPostersPosition(_ req: Request) async throws -> PosterPositionResponseDTO {
        guard let positionId = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid Position-ID.")
        }
        
        let position = try await PosterPosition.query(on: req.db)
            .with(\.$responsibilities) { responsibilities in
                responsibilities.with(\.$user) { user in
                    user.with(\.$identity)
                }
            }
            .with(\.$postedBy)
            .with(\.$removedBy)
            .filter(\.$id == positionId)
            .first()
        
        guard let position = position else {
            throw Abort(.notFound, reason: "PosterPosition not Found")
        }
        
        return try position.toPosterPositionResponseDTO()
    }
    
    /// Gibt alle PosterPositionen eines Posters zurück
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
            .with(\.$postedBy)
            .with(\.$removedBy)
            .sort(\.$expiresAt, .ascending)
            .all()
            .toPosterPositionResponseDTOArray()
    }
    
    /// Updatet eine PosterPosition
    @Sendable
    func updatePosterPosition(_ req: Request) async throws -> PosterPositionResponseDTO {
        guard let positionId = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid Position-ID.")
        }
        
        guard let dto = try? req.content.decode(UpdatePosterPositionDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected UpdatePosterPositionDTO")
        }
        
        guard let position = try? await dto.updatePosterPosition(positionId: positionId, on: req.db) else {
            throw Abort(.internalServerError)
        }
        
        return try position.toPosterPositionResponseDTO()
    }
    
    /// Markiert eine Poster-Position als aufgehängt.
    @Sendable
    func hangPosterPosition(_ req: Request) async throws -> HangPosterPositionResponseDTO {
        
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        
        guard let positionId = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid Position-ID.")
        }
        
        guard let dto = try? req.content.decode(HangPosterPositionDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected HangPosterPositionDTO")
        }
        
        guard let response = try? await  dto.hangPosterPosition(userId: userId, positionId: positionId, on: req.db) else {
            throw Abort(.internalServerError)
        }
        
        return response
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
        
        guard let dto = try? req.content.decode(TakeDownPosterPositionDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected TakeDownPosterPositionDTO")
        }
        
        guard let response = try? await dto.takeDownPosterPosition(userId: userId, positionId: positionId, on: req.db) else {
            throw Abort(.internalServerError)
        }
        return response
    }
    
    /// Markiert eine Poster-Position als beschädigt.
    @Sendable
    func reportDamagedPosterPosition(_ req: Request) async throws -> PosterPositionResponseDTO {
        guard let posterPosition = try await PosterPosition.find(req.parameters.get("positionid"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let reportDamagedPosterPositionDTO = try? req.content.decode(ReportDamagedPosterPositionDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected ReportDamagedPosterPositionDTO.")
        }
        guard posterPosition.status == .hangs else {
            throw Abort(.badRequest, reason: "Only PosterPositions with a status of 'hangs' can be reported as damaged.")
        }
        
        posterPosition.image = reportDamagedPosterPositionDTO.image
        posterPosition.damaged = true
        
        try await posterPosition.update(on: req.db)
        
        try await posterPosition.$responsibilities.load(on: req.db)
        for responsibility in posterPosition.responsibilities {
            try await responsibility.$user.load(on: req.db)
            try await responsibility.user.$identity.load(on: req.db)
        }
        try await posterPosition.$postedBy.load(on: req.db)
        
        return try posterPosition.toPosterPositionResponseDTO()
    }
    
    /// Löscht eine einzelne PosterPosition und deren zugehörige Daten.
    @Sendable
    func deletePosterPosition(_ req: Request) async throws -> HTTPStatus {
        guard let positionID = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid PosterPosition-ID.")
        }
        
        guard let position = try await PosterPosition.find(positionID, on: req.db) else {
            throw Abort(.notFound, reason: "PosterPosition with ID \(positionID) not found.")
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
            throw Abort(.badRequest, reason: "There has to be at least one PosterPosition-ID.")
        }
        
        let positionsToDelete = try await PosterPosition.query(on: req.db)
            .filter(\.$id ~~ positionIDs)
            .all()
        
        if positionsToDelete.count != positionIDs.count {
            let foundIDs = Set(positionsToDelete.compactMap { $0.id })
            let notFoundIDs = positionIDs.filter { !foundIDs.contains($0) }
            throw Abort(.notFound, reason: "PosterPositions with the following IDs were not found: \(notFoundIDs.map { $0.uuidString }.joined(separator: ", "))")
        }
        
        for position in positionsToDelete {
            try await position.delete(on: req.db)
        }
        
        return .noContent
    }
    
    /// Gibt das Bild zu einer PosterPosition zurück
    @Sendable
    func getImage(_ req: Request) async throws -> ImageDTO {
        guard let positionID = req.parameters.get("positionid", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid PosterPosition-ID.")
        }
        guard let position = try await PosterPosition.find(positionID, on: req.db) else {
            throw Abort(.notFound, reason: "PosterPosition with ID \(positionID) not found.")
        }
        guard let image = position.image else {
            throw Abort(.notFound, reason: "There is not image associated with PosterPosition ID \(positionID)")
        }
        return ImageDTO(image: image)
    }
}

