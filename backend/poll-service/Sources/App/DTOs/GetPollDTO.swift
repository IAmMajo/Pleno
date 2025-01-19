import Vapor
import PollServiceDTOs

extension GetPollDTO: @retroactive Content, @unchecked @retroactive Sendable { }
