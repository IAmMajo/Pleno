import Fluent
import Vapor
import Models
import SwiftOpenAPI
import VaporToOpenAPI

struct InternalController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "Intern", description: "Nur intern erreichbar.")
        routes.put("adjust-identities", ":oldId", ":newId", use: adjustIdentities)
            .openAPI(tags: openAPITag, summary: "Identitäten in veränderlichen Anwesenheiten anpassen", path: .all(of: .type(Meeting.IDValue.self), .type(String.self)), statusCode: .noContent)
    }
    
    /// **PUT** `/internal/meetings/adjust-identities/{oldId}/{newId}`
    @Sendable func adjustIdentities(req: Request) async throws -> HTTPStatus {
        guard let oldId = req.parameters.get("oldId", as: UUID.self), let newId = req.parameters.get("newId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid IDs.")
        }
        guard try await Attendance.query(on: req.db)
            .join(parent: \.$id.$meeting)
            .filter(\.$id.$identity.$id == oldId)
            .filter(\.$status == .present)
            .filter(Meeting.self, \.$status == .inSession)
            .first() == nil else {
            throw Abort(.locked, reason: "Cannot change identity (profile) while attending a meeting.")
        }
        
        let attendances = try await Attendance.query(on: req.db)
            .join(parent: \.$id.$meeting)
            .filter(\.$id.$identity.$id == oldId)
            .group(.or, { or in
                or.filter(\.$status == .accepted)
                or.filter(Meeting.self, \.$status == .scheduled)
            })
            .all()
        try await req.db.transaction { db in
            for attendance in attendances {
                try attendance.requireID().$identity.id = newId
                try await attendance.update(on: db)
            }
        }
        
        return .noContent
    }
}
