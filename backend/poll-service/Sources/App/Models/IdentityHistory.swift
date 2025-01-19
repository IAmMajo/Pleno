import Models
import Vapor
import Fluent

extension IdentityHistory {
    public static func byUserId(_ userId: User.IDValue, _ db: Database) async throws -> [IdentityHistory] {
        guard let user = try await User.find(userId, on: db) else {
            throw Abort(.notFound, reason: "User not found.")
        }
        return try await self.query(on: db)
            .filter(\.$user.$id == user.requireID())
            .with(\.$identity)
            .all()
    }
}
