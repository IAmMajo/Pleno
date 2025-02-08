import PosterServiceDTOs
import Vapor
import Fluent
import Models

extension TakeDownPosterPositionDTO: @retroactive Content, @unchecked @retroactive Sendable {
    public func takeDownPosterPosition(userId: UUID, positionId: UUID, on db: Database) async throws -> TakeDownPosterPositionResponseDTO {
        
        guard let position = try await PosterPosition.find(positionId, on: db) else {
            throw Abort(.notFound, reason: "PosterPosition not found.")
        }
        
        try await position.$responsibilities.load(on: db)
        
        guard position.responsibilities.contains(where: { $0.$user.id == userId }) else {
            throw Abort(.forbidden, reason: "You are not responsible for this PosterPosition.")
        }
        
        guard position.removedAt == nil && position.removedBy == nil else {
            throw Abort(.badRequest, reason: "This PosterPosition has already been taken down.")
        }
        
        guard let identity = try? await Identity.byUserId(userId, db) else {
            throw Abort(.internalServerError, reason: "Error retrieving the identity for user \(userId).")
        }
        
        position.image = self.image
        position.removedAt = Date()
        position.$removedBy.id = identity.id
        
        guard (try? await position.update(on: db)) != nil else {
            throw Abort(.internalServerError, reason: "Error while updating the PosterPosition.")
        }
        
        guard let removedAt = position.removedAt, let image = position.image else {
            throw Abort(.internalServerError, reason: "Required fields are missing after update.")
        }
        
        let posID = try position.requireID()
        let identityID = try identity.requireID()
        
        return TakeDownPosterPositionResponseDTO(
            posterPosition: posID,
            removedAt: removedAt,
            removedBy: identityID,
            image: image
        )
    }
}
