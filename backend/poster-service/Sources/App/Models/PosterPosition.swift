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
