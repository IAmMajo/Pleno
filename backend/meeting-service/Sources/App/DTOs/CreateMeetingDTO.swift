import Vapor
import MeetingServiceDTOs

extension CreateMeetingDTO: @retroactive Content, @unchecked @retroactive Sendable { }
