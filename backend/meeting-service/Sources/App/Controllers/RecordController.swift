import Fluent
import Vapor
import Models
import MeetingServiceDTOs

struct RecordController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let adminMiddleware = AdminMiddleware()
        
        routes.group(":id", "records") { recordRoutes in
            recordRoutes.get(use: getAllRecords)
            recordRoutes.group(":lang") { singleRecordRoutes in
                let adminRoutes = singleRecordRoutes.grouped(adminMiddleware)
                singleRecordRoutes.get(use: getSingleRecord)
                singleRecordRoutes.patch(use: updateRecord)
                adminRoutes.delete(use: deleteRecord)
                singleRecordRoutes.put("submit", use: submitRecord)
                adminRoutes.put("approve", use: approveRecord)
                adminRoutes.put("translate", ":lang2", use: translateRecord)
            }
        }
    }
    
    @Sendable func getAllRecords(req: Request) async throws -> [GetRecordDTO] {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        return try await Record.query(on: req.db)
            .filter(\.$id.$meeting.$id == meeting.requireID())
            .all()
            .map { record in
            try record.toGetRecordDTO()
        }
    }
    
    @Sendable func getSingleRecord(req: Request) async throws -> GetRecordDTO {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let lang = req.parameters.get("lang"), !lang.isEmpty else {
            throw Abort(.badRequest)
        }
        guard let record =  try await Record.find(.init(meeting: meeting, lang: lang), on: req.db) else {
            throw Abort(.notFound)
        }
        return try record.toGetRecordDTO()
    }
    
    @Sendable func updateRecord(req: Request) async throws -> GetRecordDTO {
        guard let userId = req.jwtPayload?.userID, let isAdmin = req.jwtPayload?.isAdmin else {
            throw Abort(.unauthorized)
        }
        let identityId = try await Identity.byUserId(userId, req.db).requireID()
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let lang = req.parameters.get("lang"), !lang.isEmpty else {
            throw Abort(.badRequest)
        }
        guard let patchRecordDTO = try? req.content.decode(PatchRecordDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchRecordDTO.")
        }
        guard let record = try await Record.find(.init(meeting: meeting, lang: lang), on: req.db) else {
            throw Abort(.notFound)
        }
        guard try isAdmin || (identityId == record.identity.requireID() && patchRecordDTO.identityId == nil ) else {
            throw Abort(.forbidden)
        }
        guard record.status == .underway || (record.status == .submitted && isAdmin) else {
            throw Abort(.badRequest, reason: "Your are not allowed to edit this record any longer.")
        }
        
        if let newIdentityId = patchRecordDTO.identityId {
            // Check if newIdentityId attends meeting
            guard let attendance = try await Attendance.find(.init(meetingId: meeting.requireID(), identityId: newIdentityId), on: req.db), attendance.status == .present else {
                throw Abort(.conflict, reason: "The new identity (user) is not attending the meeting.")
            }
            record.$identity.id = newIdentityId
            record.status = .underway
        }
        if let content = patchRecordDTO.content {
            record.content = content
        }
        
        // Check if changes were made
        guard record.hasChanges else {
            throw Abort(.conflict, reason: "No changes were made.")
        }
        
        try await record.update(on: req.db)
        return try record.toGetRecordDTO()
    }
    
    @Sendable func deleteRecord(req: Request) async throws -> HTTPStatus {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let lang = req.parameters.get("lang"), !lang.isEmpty else {
            throw Abort(.badRequest)
        }
        guard lang != "DE" else {
            throw Abort(.badRequest, reason: "The record for the club's default language cannot be deleted.")
        }
        guard let record =  try await Record.find(.init(meeting: meeting, lang: lang), on: req.db) else {
            throw Abort(.notFound)
        }
        try await record.delete(on: req.db)
        return .noContent
    }
    
    @Sendable func submitRecord(req: Request) async throws -> GetRecordDTO {
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        let identityId = try await Identity.byUserId(userId, req.db).requireID()
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let lang = req.parameters.get("lang"), !lang.isEmpty else {
            throw Abort(.badRequest)
        }
        guard let record = try await Record.find(.init(meeting: meeting, lang: lang), on: req.db) else {
            throw Abort(.notFound)
        }
        guard try identityId == record.identity.requireID() else {
            throw Abort(.forbidden, reason: "You are not allowed to submit this record.")
        }
        guard record.status == .underway else {
            throw Abort(.badRequest, reason: "Record status is not 'underway' (status is '\(record.status)').")
        }
        
        record.status = .submitted
        
        try await record.update(on: req.db)
        return try record.toGetRecordDTO()
    }
    
    @Sendable func approveRecord(req: Request) async throws -> GetRecordDTO {
        guard let isAdmin = req.jwtPayload?.isAdmin else {
            throw Abort(.unauthorized)
        }
        guard isAdmin else {
            throw Abort(.forbidden, reason: "You are not allowed to approve this record.")
        }
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let lang = req.parameters.get("lang"), !lang.isEmpty else {
            throw Abort(.badRequest)
        }
        guard let record = try await Record.find(.init(meeting: meeting, lang: lang), on: req.db) else {
            throw Abort(.notFound)
        }
        guard record.status == .submitted else {
            throw Abort(.badRequest, reason: "Record status is not 'submitted' (status is '\(record.status)').")
        }
        
        record.status = .approved
        
        try await record.update(on: req.db)
        return try record.toGetRecordDTO()
    }
    
    @Sendable func translateRecord(req: Request) async throws -> GetRecordDTO {
        guard let userId = req.jwtPayload?.userID, let isAdmin = req.jwtPayload?.isAdmin else {
            throw Abort(.unauthorized)
        }
        let identityId = try await Identity.byUserId(userId, req.db).requireID()
        guard isAdmin else {
            throw Abort(.forbidden, reason: "You are not allowed to approve this record.")
        }
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let lang = req.parameters.get("lang"), !lang.isEmpty, let lang2 = req.parameters.get("lang2"), !lang2.isEmpty, lang != lang2 else {
            throw Abort(.badRequest)
        }
        guard let record = try await Record.find(.init(meeting: meeting, lang: lang), on: req.db) else {
            throw Abort(.notFound)
        }
        guard (try await Record.find(.init(meeting: meeting, lang: lang2), on: req.db)) != nil else {
            throw Abort(.conflict, reason: "Cannot create a new, translated record, since there is already one for the language '\(lang2)'.")
        }
        
        let translatedRecord = Record(id: try .init(meeting: meeting, lang: lang2), identityId: identityId, status: .underway, content: record.content)
        
        try await translatedRecord.create(on: req.db)
        return try translatedRecord.toGetRecordDTO()
    }
}
