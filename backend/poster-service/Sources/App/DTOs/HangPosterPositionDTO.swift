import PosterServiceDTOs
import Vapor
import Fluent
import Models

extension HangPosterPositionDTO: @retroactive Content, @unchecked @retroactive Sendable {
    public func hangPosterPosition(userId: UUID, positionId: UUID, on db: Database) async throws -> HangPosterPositionResponseDTO {
        
        guard let position = try await PosterPosition.find(positionId, on: db) else {
            throw Abort(.notFound, reason: "PosterPosition not found.")
        }
        
        guard (try? await position.$responsibilities.load(on: db)) != nil else {
            throw Abort(.internalServerError, reason: "Error while loading the responsibilities.")
        }
        
        guard position.responsibilities.contains(where: { $0.$user.id == userId }) else {
            throw Abort(.forbidden, reason: "You are not responsible for this PosterPosition.")
        }
        
        guard position.postedAt == nil || position.removedAt != nil || position.damaged else {
            throw Abort(.badRequest, reason: "This PosterPosition is already hung.")
        }
        
        if position.removedAt != nil || position.removedBy != nil {
            position.removedAt = nil
            position.$removedBy.id = nil
        }
        
        guard let identity = try? await Identity.byUserId(userId, db) else {
            throw Abort(.internalServerError, reason: "Error retrieving the identity for user \(userId).")
        }
        
        position.image = self.image
        position.postedAt = Date()
        position.$postedBy.id = identity.id
        
        if let latitude = self.latitude {
            position.latitude = round(latitude * 1_000_000) / 1_000_000
        }
        if let longitude = self.longitude {
            position.longitude = round(longitude * 1_000_000) / 1_000_000
        }
        
        position.damaged = false
        
        guard (try? await position.update(on: db)) != nil else {
            throw Abort(.internalServerError, reason: "Error while updating the PosterPosition.")
        }
        
        
        guard  let postedAt = position.postedAt
        else {
            throw Abort(.internalServerError, reason: "Required fields (postedAt, image) are missing.")
        }
        
        return HangPosterPositionResponseDTO(
            posterPosition: try position.requireID(),
            postedAt: postedAt,
            postedBy: try identity.requireID(),
            latitude: position.latitude,
            longitude: position.longitude
        )
    }
}
