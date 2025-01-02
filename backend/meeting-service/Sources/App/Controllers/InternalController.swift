import Fluent
import Vapor
import Models
import MeetingServiceDTOs
import SwiftOpenAPI
import VaporToOpenAPI

struct InternalController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "Intern", description: "Nur intern erreichbar.")
        routes.group("adjust-identities") { route in
            route.put("prepare", ":oldId", ":newId", use: adjustIdentitiesPreparation)
                .openAPI(tags: openAPITag, summary: "Identitäten in veränderlichen Anwesenheiten anpassen (Schritt 1)", path: .all(of: .type(Identity.IDValue.self), .type(Identity.IDValue.self)), response: .type([Attendance].self), responseContentType: .application(.json), statusCode: .ok)
            route.put(use: adjustIdentities)
                .openAPI(tags: openAPITag, summary: "Identitäten in veränderlichen Anwesenheiten anpassen (Schritt 2)", body: .type([Attendance].self), contentType: .application(.json), statusCode: .noContent)
        }
    }
    
    /// **PUT** `/internal/adjust-identities/prepare/{oldId}/{newId}`
    @Sendable func adjustIdentitiesPreparation(req: Request) async throws -> Response {
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
            .with(\.$id.$identity)
            .join(parent: \.$id.$meeting)
            .filter(\.$id.$identity.$id == oldId)
            .group(.or, { or in
                or.filter(\.$status == .accepted)
                or.filter(Meeting.self, \.$status == .scheduled)
            })
            .all()
        let newAttendances = try attendances.map { attendance in
            Attendance(id: .init(meetingId: try attendance.requireID().$meeting.id, identityId: newId), status: attendance.status)
        }
        try await req.db.transaction { db in
            for attendance in attendances {
                try await attendance.delete(on: db)
            }
        }
        
        return try await newAttendances.encodeResponse(status: .ok, for: req)
    }
    
    /// **PUT** `/internal/adjust-identities`
    @Sendable func adjustIdentities(req: Request) async throws -> HTTPStatus {
        guard let attendances = try? req.content.decode([Attendance].self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected [Attendance].")
        }
        try await req.db.transaction { db in
            for attendance in attendances {
                try await attendance.create(on: db)
            }
        }
        
        return .noContent
    }
}

extension Attendance: @retroactive Content { }
