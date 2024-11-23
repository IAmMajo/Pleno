import Vapor
import MeetingServiceDTOs

extension GetMeetingDTO: @retroactive Content, @unchecked @retroactive Sendable { }

extension MeetingStatus: @unchecked @retroactive Sendable { }
