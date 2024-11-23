import Models
import MeetingServiceDTOs
import Vapor
import Fluent

extension Identity {
    public func toGetIdentityDTO() throws -> GetIdentityDTO {
        .init(id: try self.requireID(), name: self.name)
    }
    
    public static func byUserId(_ userId: User.IDValue, _ db: Database) async throws -> Identity {
        guard let user = try await User.find(userId, on: db) else {
            throw Abort(.notFound, reason: "User not found.")
        }
        return try await user.$identity.get(on: db)
    }
}
