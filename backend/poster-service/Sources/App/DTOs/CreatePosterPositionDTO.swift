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

