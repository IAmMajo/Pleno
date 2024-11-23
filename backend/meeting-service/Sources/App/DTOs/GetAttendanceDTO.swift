import Vapor
import MeetingServiceDTOs

extension GetAttendanceDTO: @retroactive Content, @unchecked @retroactive Sendable { }
