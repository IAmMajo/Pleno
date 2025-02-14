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

import Fluent
import Vapor
import Models
import MeetingServiceDTOs
import SwiftOpenAPI
import VaporToOpenAPI

struct AttendanceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let openAPITag = TagObject(name: "Anwesenheiten")
        
        routes.group(":id") { meetingRoutes in
            meetingRoutes.get("attendances", use: getAllAttendances)
                .openAPI(tags: openAPITag, summary: "Alle Anwesenheiten einer Sitzung abfragen", path: .type(Meeting.IDValue.self), response: .type([GetAttendanceDTO].self), responseContentType: .application(.json), statusCode: .ok, auth: AuthMiddleware.schemeObject)
            meetingRoutes.put("attend", ":code", use: attendMeeting)
                .openAPI(tags: openAPITag, summary: "An einer Sitzung teilnehmen", path: .all(of: .type(Meeting.IDValue.self), .type(String.self)), statusCode: .noContent, auth: AuthMiddleware.schemeObject)
            meetingRoutes.group("plan-attendance") { planAttendanceRoutes in
                planAttendanceRoutes.put("present", use: planAttendancePresent)
                    .openAPI(tags: openAPITag, summary: "Planen, an einer Sitzung teilzunehmen", path: .type(Meeting.IDValue.self), statusCode: .noContent, auth: AuthMiddleware.schemeObject)
                planAttendanceRoutes.put("absent", use: planAttendanceAbsent)
                    .openAPI(tags: openAPITag, summary: "Planen, an einer Sitzung nicht teilzunehmen", path: .type(Meeting.IDValue.self), statusCode: .noContent, auth: AuthMiddleware.schemeObject)
            }
        }
    }
    
    /// **GET** `/meetings/{id}/attendances`
    @Sendable func getAllAttendances(req: Request) async throws -> [GetAttendanceDTO] {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        let identityIds = try await IdentityHistory.byUserId(userId, req.db).map { identityHistory in
            try identityHistory.identity.requireID()
        }
        
        let attendances = try await meeting.$attendances.query(on: req.db)
            .with(\.$id.$identity)
            .join(parent: \.$id.$identity)
            .sort(Identity.self, \.$name)
            .all()
        var getAttendanceDTOs = try attendances.map { attendance in
            try attendance.toGetAttendanceDTO()
        }
        
        if meeting.status == .scheduled {
            getAttendanceDTOs.append(contentsOf: try await Identity.query(on: req.db)
                .join(child: \.$user)
                .filter(\.$id !~ getAttendanceDTOs.map({ getAttendanceDTO in
                    getAttendanceDTO.identity.id
                }))
                .sort(\.$name)
                .all()
                .map { identity in
                        try .init(meetingId: meeting.requireID(), identity: identity.toGetIdentityDTO())
                })
        }
        
        getAttendanceDTOs.sort { lhs, rhs in
            lhs.status < rhs.status
        }
        
        if let index = getAttendanceDTOs.firstIndex(where: { dto in
            identityIds.contains(dto.identity.id)
        }) {
            var elem = getAttendanceDTOs.remove(at: index)
            elem.itsame = true
            getAttendanceDTOs.insert(elem, at: 0)
        }
        
        return getAttendanceDTOs
    }
    
    /// **PUT** `/meetings/{id}/attend/{code}`
    @Sendable func attendMeeting(req: Request) async throws -> HTTPStatus {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let code = meeting.code, code == req.parameters.get("code") else {
            throw Abort(.forbidden, reason: "Invalid code.")
        }
        return try await updateOrCreateAttendance(req, .present, .inSession)
    }
    
    /// **PUT** `/meetings/{id}/plan-attendance/present`
    @Sendable func planAttendancePresent(req: Request) async throws -> HTTPStatus {
        return try await updateOrCreateAttendance(req, .accepted, .scheduled)
    }
    
    /// **PUT** `/meetings/{id}/plan-attendance/absent`
    @Sendable func planAttendanceAbsent(req: Request) async throws -> HTTPStatus {
        return try await updateOrCreateAttendance(req, .absent, .scheduled)
    }
    
    func updateOrCreateAttendance(_ req: Request, _ attendanceStatus: Models.AttendanceStatus, _ necessaryMeetingStatus: Models.MeetingStatus) async throws -> HTTPStatus {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard meeting.status == necessaryMeetingStatus else {
            throw Abort(.badRequest, reason: "Meeting status is not '\(necessaryMeetingStatus)'.")
        }
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        let identityId = try await Identity.byUserId(userId, req.db).requireID()
        
        if let attendance = try await Attendance.find(.init(meetingId: meeting.requireID(), identityId: identityId), on: req.db) {
            guard attendance.status != attendanceStatus else {
                throw Abort(.badRequest, reason: "Attendance as specified (status '\(attendanceStatus)') is already the case.")
            }
            attendance.status = attendanceStatus
            try await attendance.update(on: req.db)
        } else {
            let attendance = try Attendance(id: .init(meetingId: meeting.requireID(), identityId: identityId), status: attendanceStatus)
            try await attendance.create(on: req.db)
        }
        return .noContent
    }
}
