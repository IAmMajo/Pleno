import Vapor
import MeetingServiceDTOs

extension PatchMeetingDTO: @retroactive Content, @unchecked @retroactive Sendable { }
