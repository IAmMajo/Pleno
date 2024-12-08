import Vapor
import MeetingServiceDTOs

extension PatchRecordDTO: @retroactive Content, @unchecked @retroactive Sendable { }
