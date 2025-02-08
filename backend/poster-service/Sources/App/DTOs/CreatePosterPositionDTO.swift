import PosterServiceDTOs
import Vapor
import Models
import Fluent

extension CreatePosterPositionDTO: @retroactive Content, @unchecked @retroactive Sendable {
    public func toPosterPosition(posterId: UUID, on db: Database) async throws -> PosterPosition {
        
        guard (-90...90).contains(self.latitude) else {
            throw Abort(.badRequest, reason: "Latitude has to be between -90 and 90.")
        }
        guard (-180...180).contains(self.longitude) else {
            throw Abort(.badRequest, reason: "Longitude has to be between -180 and 180.")
        }
        
        let posterPosition = PosterPosition(
            posterId: posterId,
            latitude: self.latitude,
            longitude: self.longitude,
            expiresAt: self.expiresAt
        )
        
        let responsibleUserIDs = try await self.responsibleUsers.uniqued().map { uuid in
            guard let user = try await User.find(uuid, on: db) else {
                throw Abort(.badRequest, reason: "Invalid user id '\(uuid)'.")
            }
            return try user.requireID()
        }
       
        try await db.transaction { transaction in
            try await posterPosition.create(on: transaction)
            
            try await responsibleUserIDs.map { userID in
                try PosterPositionResponsibilities(userID: userID, posterPositionID: posterPosition.requireID())
            }.create(on: transaction)
        }
        
        try await posterPosition.$responsibilities.load(on: db)
        
        for responsibility in posterPosition.responsibilities {
            try await responsibility.$user.load(on: db)
            try await responsibility.user.$identity.load(on: db)
        }
        
        return posterPosition
    }
}

