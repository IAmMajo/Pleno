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

import Models
import PosterServiceDTOs
import Vapor
import Fluent


extension PosterPosition {
    public func toPosterPositionResponseDTO() throws -> PosterPositionResponseDTO {
        let responsibleUsers = try self.responsibilities.map { responsibility in
            let user = responsibility.user
            let identityName = user.identity.name
            return try ResponsibleUsersDTO(
                id: user.requireID(),
                name: identityName
            )
        }
        
        return try PosterPositionResponseDTO(
            id: self.requireID(),
            posterId: self.$poster.id,
            latitude: self.latitude,
            longitude: self.longitude,
            postedBy: self.postedBy?.name,
            postedAt: self.postedAt,
            expiresAt: self.expiresAt,
            removedBy: self.removedBy?.name,
            removedAt: self.removedAt,
            responsibleUsers: responsibleUsers,
            status: self.status
        )
        
    }
    var status: PosterPositionStatus {
        if self.removedAt != nil {
            return .takenDown
        }
        if self.postedAt == nil {
            return .toHang
        }
        if self.expiresAt < .now {
            return .overdue
        }
        if self.damaged {
            return .damaged
        }
        return .hangs
    }
}

extension [PosterPosition] {
    func toPosterPositionResponseDTOArray() throws -> [PosterPositionResponseDTO] {
        try self.map { position in
            try position.toPosterPositionResponseDTO()
        }
    }
}
