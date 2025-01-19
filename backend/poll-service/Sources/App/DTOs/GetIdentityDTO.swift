import Vapor
import PollServiceDTOs

extension GetIdentityDTO: @retroactive Content, @unchecked @retroactive Sendable { }
