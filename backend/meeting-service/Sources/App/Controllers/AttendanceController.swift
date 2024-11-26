import Fluent
import Vapor
import Models
import MeetingServiceDTOs

struct AttendanceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group(":id") { meetingRoutes in
            meetingRoutes.get("attendances", use: getAllAttendances)
            meetingRoutes.put("attend", ":code", use: attendMeeting)
            meetingRoutes.group("plan-attendance") { planAttendanceRoutes in
                planAttendanceRoutes.put("present", use: planAttendancePresent)
                planAttendanceRoutes.put("absent", use: planAttendanceAbsent)
            }
        }
    }
    
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
        if let index = getAttendanceDTOs.firstIndex(where: { dto in
            identityIds.contains(dto.identity.id)
        }) {
            let elem = getAttendanceDTOs.remove(at: index)
            getAttendanceDTOs.insert(elem, at: 0)
        }
        return getAttendanceDTOs
    }
    
    @Sendable func attendMeeting(req: Request) async throws -> HTTPStatus {
        guard let meeting = try await Meeting.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        guard let code = meeting.code, code == req.parameters.get("code") else {
            throw Abort(.forbidden, reason: "Invalid code.")
        }
        return try await updateOrCreateAttendance(req, .present, .inSession)
    }
    
    @Sendable func planAttendancePresent(req: Request) async throws -> HTTPStatus {
        return try await updateOrCreateAttendance(req, .accepted, .scheduled)
    }
    
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
