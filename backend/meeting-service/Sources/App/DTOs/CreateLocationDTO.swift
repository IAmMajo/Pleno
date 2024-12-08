import Vapor
import MeetingServiceDTOs

extension CreateLocationDTO: @retroactive Content, @unchecked @retroactive Sendable { }
