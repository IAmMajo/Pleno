import Fluent
import Vapor
import Models
import MeetingServiceDTOs
import AIServiceDTOs
import SwiftOpenAPI

struct RecordController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "Protokolle")
        let adminMiddleware = AdminMiddleware()
        
        routes.group(":id", "records") { recordRoutes in
            recordRoutes.get(use: getAllRecords)
                .openAPI(tags: openAPITag, summary: "Alle Protokolle einer Sitzung abfragen", response: .type([GetRecordDTO].self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
            
            recordRoutes.group(":lang") { singleRecordRoutes in
                let adminRoutes = singleRecordRoutes.grouped(adminMiddleware)
                singleRecordRoutes.get(use: getSingleRecord)
                    .openAPI(tags: openAPITag, summary: "Ein Protokoll einer Sprache einer Sitzung abfragen", path: .all(of: .type(Meeting.IDValue.self), .type(String.self)), response: .type(GetRecordDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
                
                singleRecordRoutes.patch(use: updateRecord)
                    .openAPI(tags: openAPITag, summary: "Ein Protokoll einer Sprache einer Sitzung updaten", description: "Nur gestattet, wenn Status noch underway ist und der Bearbeiter der im Protokoll eingetragene oder ein Admin ist. Wenn PatchRecordDTO.identity gesetzt ist, wird der Status automatisch auf underway gesetzt.", path: .all(of: .type(Meeting.IDValue.self), .type(String.self)), body: .type(PatchRecordDTO.self), contentType: .application(.json), response: .type(GetRecordDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
                
                adminRoutes.delete(use: deleteRecord)
                    .openAPI(tags: openAPITag, summary: "Ein Protokoll einer Sprache einer Sitzung löschen", description: "Nur gestattet, wenn Status noch underway ist und der Bearbeiter der im Protokoll eingetragene oder ein Admin ist. Das Protokoll der Standardsprache des Vereins kann nicht gelöscht werden.", path: .all(of: .type(Meeting.IDValue.self), .type(String.self)), statusCode: .noContent, auth: AdminMiddleware.schemeObject)
                
                singleRecordRoutes.put("submit", use: submitRecord)
                    .openAPI(tags: openAPITag, summary: "Ein Protokoll einer Sprache einer Sitzung einreichen", path: .all(of: .type(Meeting.IDValue.self), .type(String.self)), response: .type(GetRecordDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
                
                adminRoutes.put("approve", use: approveRecord)
                    .openAPI(tags: openAPITag, summary: "Ein Protokoll einer Sprache einer Sitzung genehmigen", path: .all(of: .type(Meeting.IDValue.self), .type(String.self)), response: .type(GetRecordDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AdminMiddleware.schemeObject)
                
                adminRoutes.put("translate", ":lang2", use: translateRecord)
                    .openAPI(tags: openAPITag, summary: "Ein Protokoll einer Sprache einer Sitzung in eine neue Sprache übersetzen", path: .all(of: .type(Meeting.IDValue.self), .type(String.self), .type(String.self)), response: .type(GetRecordDTO.self), responseContentType: .application(.json), statusCode: .ok, auth: AdminMiddleware.schemeObject)
            }
        }
    }
    
    /// **GET** `/meetings/{id}/records`
    @Sendable func getAllRecords(req: Request) async throws -> [GetRecordDTO] {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        return try await meeting.$records.query(on: req.db)
            .with(\.$identity)
            .all()
            .map { record in
                try await record.toGetRecordDTO(db: req.db)
        }
    }
    
    /// **GET** `/meetings/{id}/records/{lang}`
    @Sendable func getSingleRecord(req: Request) async throws -> GetRecordDTO {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let lang = req.parameters.get("lang")?.lowercased(), !lang.isEmpty else {
            throw Abort(.badRequest)
        }
        guard let record =  try await Record.find(.init(meeting: meeting, lang: lang), on: req.db) else {
            throw Abort(.notFound)
        }
        try await record.$identity.load(on: req.db)
        return try await record.toGetRecordDTO(db: req.db)
    }
    
    /// **PATCH** `/meetings/{id}/records/{lang}`
    @Sendable func updateRecord(req: Request) async throws -> GetRecordDTO {
        guard let userId = req.jwtPayload?.userID, let isAdmin = req.jwtPayload?.isAdmin else {
            throw Abort(.unauthorized)
        }
        let identityId = try await Identity.byUserId(userId, req.db).requireID()
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let lang = req.parameters.get("lang")?.lowercased(), !lang.isEmpty else {
            throw Abort(.badRequest)
        }
        guard let patchRecordDTO = try? req.content.decode(PatchRecordDTO.self) else {
            throw Abort(.badRequest, reason: "Invalid request body! Expected PatchRecordDTO.")
        }
        guard let record = try await Record.find(.init(meeting: meeting, lang: lang), on: req.db) else {
            throw Abort(.notFound)
        }
        guard isAdmin || (identityId == record.$identity.id && patchRecordDTO.identityId == nil ) else {
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
        try await record.$identity.load(on: req.db)
        return try await record.toGetRecordDTO(db: req.db)
    }
    
    /// **DELETE** `/meetings/{id}/records/{lang}`
    @Sendable func deleteRecord(req: Request) async throws -> HTTPStatus {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let lang = req.parameters.get("lang")?.lowercased(), !lang.isEmpty else {
            throw Abort(.badRequest)
        }
        guard lang != "de" else {
            throw Abort(.badRequest, reason: "The record for the club's default language cannot be deleted.")
        }
        guard let record =  try await Record.find(.init(meeting: meeting, lang: lang), on: req.db) else {
            throw Abort(.notFound)
        }
        try await record.delete(on: req.db)
        return .noContent
    }
    
    /// **PUT** `/meetings/{id}/records/{lang}/submit`
    @Sendable func submitRecord(req: Request) async throws -> GetRecordDTO {
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        let identityId = try await Identity.byUserId(userId, req.db).requireID()
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let lang = req.parameters.get("lang")?.lowercased(), !lang.isEmpty else {
            throw Abort(.badRequest)
        }
        guard let record = try await Record.find(.init(meeting: meeting, lang: lang), on: req.db) else {
            throw Abort(.notFound)
        }
        guard identityId == record.$identity.id else {
            throw Abort(.forbidden, reason: "You are not allowed to submit this record.")
        }
        guard record.status == .underway else {
            throw Abort(.badRequest, reason: "Record status is not 'underway' (status is '\(record.status)').")
        }
        
        record.status = .submitted
        
        try await record.update(on: req.db)
        try await record.$identity.load(on: req.db)
        return try await record.toGetRecordDTO(db: req.db)
    }
    
    /// **PUT** `/meetings/{id}/records/{lang}/approve`
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
        guard let lang = req.parameters.get("lang")?.lowercased(), !lang.isEmpty else {
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
        try await record.$identity.load(on: req.db)
        return try await record.toGetRecordDTO(db: req.db)
    }
    
    /// **PUT** `/meetings/{id}/records/{lang}/translate/{lang2}`
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
        guard let lang = req.parameters.get("lang")?.lowercased(), !lang.isEmpty, let lang2 = req.parameters.get("lang2")?.lowercased(), !lang2.isEmpty, lang != lang2 else {
            throw Abort(.badRequest)
        }
        guard Locale.LanguageCode(stringLiteral: lang2).isISOLanguage else {
            throw Abort(.badRequest, reason: "Invalid language '\(lang2)' (expected a two-letter ISO 639-1 or three-letter ISO 639-2 code, e.g. 'en').")
        }
        guard let record = try await Record.find(.init(meeting: meeting, lang: lang), on: req.db) else {
            throw Abort(.notFound)
        }
        guard (try await Record.find(.init(meeting: meeting, lang: lang2), on: req.db)) == nil else {
            throw Abort(.conflict, reason: "Cannot create a new, translated record, since there is already one for the language '\(lang2)'.")
        }
        
        guard let aiServiceResponse: AISendMessageDTO = try? await req.client.post("http://ai-service/internal/translate-record/\(lang)/\(lang2)", content: AISendMessageDTO(content: record.content)).content.decode(AISendMessageDTO.self) else {
            throw Abort(.serviceUnavailable, reason: "Failed to contact the AI service.")
        }
        
        let translatedRecord = Record(id: try .init(meeting: meeting, lang: lang2), identityId: identityId, status: .underway, content: aiServiceResponse.content)
        
        try await translatedRecord.create(on: req.db)
        try await translatedRecord.$identity.load(on: req.db)
        return try await translatedRecord.toGetRecordDTO(db: req.db)
    }
}
