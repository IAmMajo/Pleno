import Vapor
import MeetingServiceDTOs

extension GetVotingResultsDTO: @retroactive Content, @unchecked @retroactive Sendable { }
