import Vapor
import MeetingServiceDTOs

extension GetLocationDTO: @retroactive Content, @unchecked @retroactive Sendable { }
