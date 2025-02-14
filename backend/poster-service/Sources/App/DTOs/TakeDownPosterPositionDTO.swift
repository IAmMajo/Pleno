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
        
        guard let removedAt = position.removedAt else {
            throw Abort(.internalServerError, reason: "Required fields are missing after update.")
        }
        
        let posID = try position.requireID()
        let identityID = try identity.requireID()
        
        return TakeDownPosterPositionResponseDTO(
            posterPosition: posID,
            removedAt: removedAt,
            removedBy: identityID
        )
    }
}
