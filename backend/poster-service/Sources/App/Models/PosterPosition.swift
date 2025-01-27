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
            postedBy: self.posted_by?.name,
            postedAt: self.posted_at,
            expiresAt: self.expires_at,
            removedBy: self.removed_by?.name,
            removedAt: self.removed_at,
            image: self.image,
            responsibleUsers: responsibleUsers,
            status: self.status
        )
        
    }
    var status: PosterPositionStatus {
        if self.removed_at != nil {
            return .takenDown
        }
        if self.posted_at == nil {
            return .toHang
        }
        if self.expires_at < .now {
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
