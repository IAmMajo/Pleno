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

import Fluent
import Vapor
import Foundation
import Models
import VaporToOpenAPI
import PosterServiceDTOs


// MARK: - PosterController

struct PosterController: RouteCollection, Sendable {
    let adminMiddleware: Middleware
    
    /// Initialisiert den `PosterController` mit Admin-Middleware.
    init() throws {
        self.adminMiddleware = AdminMiddleware()
    }
    
    /// Registriert alle Routen des Controllers.
    func boot(routes: RoutesBuilder) throws {
        let openAPITagPoster = TagObject(name: "Poster")
        
        // GET /posters/summary
        routes.get("summary", use: getPostersSummary)
            .openAPI(
                tags: openAPITagPoster,
                summary: "Anzahl der verschiedenen PosterPosition-Status aller Poster abfragen",
                description: """
                            Diese Route gibt die Anzahl der Status _hangs_, _toHang_, _overdue_ und _takenDown_ als numerische Werte zurück.
                            """,
                body: nil,
                response: .type(PosterSummaryResponseDTO.self),
                responseContentType: .application(.json),
                auth: .bearer()
            )
        
        // GET /posters/{id}/summary
        routes.get(":id", "summary", use: getPosterSummary)
            .openAPI(
                tags: openAPITagPoster,
                summary: "Anzahl der verschiedenen PosterPosition-Status eines Posters abfragen",
                description: """
                            Diese Route gibt die Anzahl der Status _hangs_, _toHang_, _overdue_ und _takenDown_ als numerische Werte zurück.
                            """,
                body: nil,
                response: .type(PosterSummaryResponseDTO.self),
                responseContentType: .application(.json),
                auth: .bearer()
            )
        // GET /posters/:id/image
        routes.get(":id", "image", use: getImage).openAPI(
            tags: openAPITagPoster,
            summary: "Gibt das Bild zum zugehörigen Poster zurück",
            description: """
                         Gibt das Bild zum zugehörigen Poster  zurück
                         """,
            path: .type(Poster.IDValue.self),
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
                    Diese Route ermöglicht das Erstellen eines neuen Posters. Der Request`
                    sollte mindestens einen Namen (`name`) sowie ein Bild (`image`) enthalten.
                    """,
                query: [],
                body: .type(CreatePosterDTO.self),
                contentType: .application(.json),
                response: .type(PosterResponseDTO.self),
                responseContentType: .application(.json),
                auth: .bearer()
            )
        
        // PATCH /posters/:id
        routes.on(.PATCH, ":id", body: .collect(maxSize: "7000kb"), use: updatePoster)
            .openAPI(
                tags: openAPITagPoster,
                summary: "Updatet ein Poster",
                description: """
                    Aktualisiert ein vorhandenes Poster basierend auf seiner ID. Der Request
                    kann Felder wie `name`, `description` oder ein neues `image` enthalten.
                    """,
                query: [],
                path: .type(Poster.IDValue.self),
                body: .type(UpdatePosterDTO.self),
                contentType: .application(.json),
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
    
    /// Erstellt ein Poster
    @Sendable
    func createPoster(_ req: Request) async throws -> Response {
        
        guard let posterData = try? req.content.decode(CreatePosterDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected CreatePosterDTO.")
        }
        
        let poster = Poster(
            name: posterData.name,
            description: posterData.description,
            image: posterData.image
        )
        
        do {
            try await poster.create(on: req.db)
        } catch {
            throw Abort(.internalServerError)
        }
        
        return try await PosterResponseDTO(
            id: poster.requireID(),
            name: poster.name,
            description: poster.description
        ).encodeResponse(status: .created, for: req)
    }
    
    /// Einzelnes Poster anhand seiner ID abrufen.
    @Sendable
    func getPoster(_ req: Request) async throws -> PosterResponseDTO {
        guard let posterId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid Poster-ID.")
        }
        
        guard let poster = try await Poster.find(posterId, on: req.db) else {
            throw Abort(.notFound, reason: "Poster not found.")
        }
        
        return PosterResponseDTO(
            id: try poster.requireID(),
            name: poster.name,
            description: poster.description
        )
    }
    
    @Sendable
    func getPosters(_ req: Request) async throws -> Response {
        return try await PosterResponseDTO.fetchAllPostersAndBuildResponse(req)
    }
    
    /// Überblicks-Statistiken über alle PosterPositionen zurückgeben.
    @Sendable
    func getPostersSummary(_ req: Request) async throws -> PosterSummaryResponseDTO {
        try await calculatePosterSummary(for: PosterPosition.query(on: req.db))
    }
    
    /// Überblicks-Statistiken über PosterPositionen eines Poster zurückgeben.
    @Sendable
    func getPosterSummary(_ req: Request) async throws -> PosterSummaryResponseDTO {
        guard let poster = try await Poster.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await calculatePosterSummary(for: poster.$positions.query(on: req.db))
    }
    
    /// Überblicks-Statistiken über PosterPositionen zurückgeben.
    @Sendable
    func calculatePosterSummary(for queryBuilder: QueryBuilder<PosterPosition>) async throws -> PosterSummaryResponseDTO {
        let posters = try await queryBuilder
            .with(\.$responsibilities) { responsibilities in
                responsibilities.with(\.$user) { user in
                    user.with(\.$identity)
                }
            }
            .with(\.$postedBy)
            .with(\.$removedBy)
            .all()
            .toPosterPositionResponseDTOArray()
        
        let hangsCount = posters.count { position in
            position.status == .hangs
        }
        
        let toHangCount = posters.count { position in
            position.status == .toHang
        }
        
        let overdueCount = posters.count { position in
            position.status == .overdue
        }
        
        let takenDownCount = posters.count { position in
            position.status == .takenDown
        }
        
        let damagedCount = posters.count { position in
            position.status == .damaged
        }
        
        let nextTakeDownDate: Date? = try await queryBuilder
            .filter(\.$postedBy.$id != nil)
            .filter(\.$removedBy.$id == nil)
            .sort(\.$expiresAt)
            .first()?.expiresAt
        
        return PosterSummaryResponseDTO(
            hangs: hangsCount,
            toHang: toHangCount,
            overdue: overdueCount,
            takenDown: takenDownCount,
            damaged: damagedCount,
            nextTakeDown: nextTakeDownDate
        )
    }
    
    @Sendable
    func updatePoster(_ req: Request) async throws -> PosterResponseDTO {
        guard let posterId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid Poster-ID.")
        }
        
        guard let dto = try? req.content.decode(UpdatePosterDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected UpdatePosterDTO.")
        }
        
        guard let poster = try await Poster.find(posterId, on: req.db) else {
            throw Abort(.notFound, reason: "Poster not found.")
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
        
        do {
            try await poster.update(on: req.db)
        } catch {
            throw Abort(.internalServerError, reason: "Error updating poster: \(error.localizedDescription)")
        }
        
        let id = try poster.requireID()
        return PosterResponseDTO(
            id: id,
            name: poster.name,
            description: poster.description
        )
    }
    
    @Sendable
    func deletePoster(_ req: Request) async throws -> HTTPStatus {
        guard let posterID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid Poster-ID.")
        }
        
        guard let poster = try await Poster.find(posterID, on: req.db) else {
            throw Abort(.notFound, reason: "Poster with ID \(posterID) not found.")
        }
        
        do {
            try await poster.delete(on: req.db)
        } catch {
            throw Abort(.internalServerError, reason: "Error deleting poster: \(error.localizedDescription)")
        }
        
        return .noContent
    }
    
    @Sendable
    func deletePosters(_ req: Request) async throws -> HTTPStatus {
        guard let deleteDTO = try? req.content.decode(DeleteDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected DeleteDTO.")
        }
        let posterIDs = deleteDTO.ids

        guard !posterIDs.isEmpty else {
            throw Abort(.badRequest, reason: "At least one Poster-ID must be provided.")
        }
        
        let postersToDelete = try await Poster.query(on: req.db)
            .filter(\.$id ~~ posterIDs)
            .all()
        
        if postersToDelete.count != posterIDs.count {
            let foundIDs = Set(postersToDelete.compactMap { $0.id })
            let notFoundIDs = posterIDs.filter { !foundIDs.contains($0) }
            throw Abort(.notFound, reason: "Posters with IDs not found: \(notFoundIDs.map { $0.uuidString }.joined(separator: ", "))")
        }
        
        try await req.db.transaction { transaction in
            for poster in postersToDelete {
                try await poster.delete(on: transaction)
            }
        }
        
        return .noContent
    }

    
    /// Gibt das Bild zu einem Poster zurück
    @Sendable
    func getImage(_ req: Request) async throws -> Response {
        guard let posterID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid Poster-ID.")
        }
        guard let poster = try await Poster.find(posterID, on: req.db) else {
            throw Abort(.notFound, reason: "PosterPosition with ID \(posterID) not found.")
        }
        
        return Response(status: .ok, body: .init(data: poster.image))
    }
}
