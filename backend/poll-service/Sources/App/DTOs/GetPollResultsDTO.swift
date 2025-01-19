import Vapor
import PollServiceDTOs

extension GetPollResultsDTO: @retroactive Content, @unchecked @retroactive Sendable { }

extension GetPollResultDTO: @retroactive Content, @unchecked @retroactive Sendable { }
