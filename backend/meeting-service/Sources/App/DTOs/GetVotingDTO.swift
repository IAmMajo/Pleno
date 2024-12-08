import Vapor
import MeetingServiceDTOs

extension GetVotingDTO: @retroactive Content, @unchecked @retroactive Sendable { }
