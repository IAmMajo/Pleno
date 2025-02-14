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
