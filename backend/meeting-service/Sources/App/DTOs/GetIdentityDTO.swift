import Vapor
import MeetingServiceDTOs

extension GetIdentityDTO: @retroactive Content, @unchecked @retroactive Sendable { }
