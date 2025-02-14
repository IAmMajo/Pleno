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

extension UpdatePosterPositionDTO: @retroactive Content, @unchecked @retroactive Sendable {
    public func updatePosterPosition(positionId: UUID, on db: Database) async throws -> PosterPosition {
        return try await db.transaction { transaction -> PosterPosition in
            guard let position = try await PosterPosition.query(on: transaction)
                .with(\.$postedBy)
                .with(\.$removedBy)
                .filter(\.$id == positionId)
                .first() else {
                throw Abort(.notFound, reason: "PosterPosition not found.")
            }
            
            if let newLatitude = self.latitude {
                position.latitude = round(newLatitude * 1_000_000) / 1_000_000
            }
            if let newLongitude = self.longitude {
                position.longitude = round(newLongitude * 1_000_000) / 1_000_000
            }
            if let newExpiresAt = self.expiresAt {
                position.expiresAt = newExpiresAt
            }
            if let newPosterId = self.posterId {
                position.$poster.id = newPosterId
            }
            
            if let newResponsibleUsers = self.responsibleUsers {
                guard let currentResponsibilities = try? await PosterPositionResponsibilities.query(on: transaction)
                    .filter(\.$poster_position.$id == positionId)
                    .all() else {
                    throw Abort(.internalServerError, reason: "Error fetching current responsibilities.")
                }
                
                let currentUserIds = Set(currentResponsibilities.compactMap { $0.$user.id })
                let newUserIds = Set(newResponsibleUsers)
                
                let toAdd = newUserIds.subtracting(currentUserIds)
                for userId in toAdd {
                    let responsibility = PosterPositionResponsibilities(userID: userId, posterPositionID: positionId)
                    guard (try? await responsibility.create(on: transaction)) != nil else {
                        throw Abort(.internalServerError, reason: "Error saving responsibility for user \(userId).")
                    }
                }
                
                let toRemove = currentUserIds.subtracting(newUserIds)
                if !toRemove.isEmpty {
                    guard (try? await PosterPositionResponsibilities.query(on: transaction)
                        .filter(\.$poster_position.$id == positionId)
                        .filter(\.$user.$id ~~ toRemove)
                        .delete()) != nil else {
                        throw Abort(.internalServerError, reason: "Error deleting responsibilities.")
                    }
                }
            }
            
            if let newImage = self.image {
                position.image = newImage
            }
            
            guard (try? await position.update(on: transaction)) != nil else {
                throw Abort(.internalServerError, reason: "Error updating PosterPosition.")
            }
            
            guard (try? await position.$responsibilities.load(on: transaction)) != nil else {
                throw Abort(.internalServerError, reason: "Error loading responsibilities.")
            }
            for responsibility in position.responsibilities {
                guard (try? await responsibility.$user.load(on: transaction)) != nil else {
                    throw Abort(.internalServerError, reason: "Error loading user for a responsibility.")
                }
                guard (try? await responsibility.user.$identity.load(on: transaction)) != nil else {
                    throw Abort(.internalServerError, reason: "Error loading identity for a responsibility.")
                }
            }
            
            return position
        }
    }
}
