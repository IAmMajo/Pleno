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
    /// **Concurrent!** Might change the array's order
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
