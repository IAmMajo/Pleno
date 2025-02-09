import Models
import Vapor
import Fluent

extension Identity {
    public static func byUserId(_ userId: User.IDValue, _ db: Database) async throws -> Identity {
        guard let user = try await User.find(userId, on: db) else {
            throw Abort(.notFound, reason: "User not found.")
        }
        return try await user.$identity.get(on: db)
    }
    
    public static func getUser(from identityId: Identity.IDValue, on db: Database) async throws -> User {
        guard let history = try await IdentityHistory.query(on: db)
            .filter(\.$identity.$id == identityId) 
            .first() else {
            throw Abort(.notFound, reason: "No history found for the given identity.")
        }

        return history.user!
    }
}
