import Vapor
import MeetingServiceDTOs

extension GetRecordDTO: @retroactive Content, @unchecked @retroactive Sendable { }
