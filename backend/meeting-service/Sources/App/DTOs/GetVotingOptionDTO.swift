import Vapor
import MeetingServiceDTOs

extension GetVotingOptionDTO: @retroactive Content, @unchecked @retroactive Sendable { }
