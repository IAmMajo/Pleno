import Models
import Vapor
import Fluent


extension PosterPosition {
    public func posterPositionMapToDTO(_ status: String) -> PosterPositionResponseDTO {
        let responsibleUsers = self.responsibilities.compactMap { responsibility -> ResponsibleUsersDTO? in
            let user = responsibility.user
            let identityName = user.identity.name
            guard let userId = user.id else {
                return nil
            }
            return ResponsibleUsersDTO(
                id: userId,
                name: identityName
            )
        }
        
        return PosterPositionResponseDTO(
            id: self.id!,
            posterId: self.$poster.id,
            latitude: self.latitude,
            longitude: self.longitude,
            postedBy: self.posted_by?.name,
            postedAt: self.posted_at,
            expiresAt: self.expires_at!,
            removedBy: self.removed_by?.name,
            removedAt: self.removed_at,
            imageUrl: self.image_url,
            responsibleUsers: responsibleUsers,
            status: status
        )
    }
}
    



