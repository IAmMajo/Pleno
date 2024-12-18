import Vapor
import Fluent
import MeetingServiceDTOs
import Models

extension GetMeetingDTO: @retroactive Content, @unchecked @retroactive Sendable {
    public func withMyAttendanceStatus(req: Request) async throws -> GetMeetingDTO {
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        let identityIds = try await IdentityHistory.byUserId(userId, req.db).map { identityHistory in
            try identityHistory.identity.requireID()
        }
        return try await withMyAttendanceStatus(identityIds: identityIds, db: req.db)
    }
    public func withMyAttendanceStatus(identityIds: [UUID], db: Database) async throws -> GetMeetingDTO {
        var getMeetingDTO = self
        if let myAttendance = try await Attendance.query(on: db)
            .filter(\.$id.$meeting.$id == self.id)
            .filter(\.$id.$identity.$id ~~ identityIds)
            .first() {
            getMeetingDTO.myAttendanceStatus = myAttendance.status.convert()
        }
        return getMeetingDTO
    }
}

extension [GetMeetingDTO] {
    public func withMyAttendanceStatus(req: Request) async throws -> [GetMeetingDTO] {
        guard let userId = req.jwtPayload?.userID else {
            throw Abort(.unauthorized)
        }
        let identityIds = try await IdentityHistory.byUserId(userId, req.db).map { identityHistory in
            try identityHistory.identity.requireID()
        }
        
        return try await withThrowingTaskGroup(of: GetMeetingDTO.self) { group throws in
            for getMeetingDTO in self {
                group.addTask { try await getMeetingDTO.withMyAttendanceStatus(identityIds: identityIds, db: req.db)}
            }
            
            var getMeetingDTOs: [GetMeetingDTO] = []
            for try await getMeetingDTO in group {
                getMeetingDTOs.append(getMeetingDTO)
            }
            
            return getMeetingDTOs
        }
    }
}

extension MeetingServiceDTOs.MeetingStatus: @unchecked @retroactive Sendable { }
