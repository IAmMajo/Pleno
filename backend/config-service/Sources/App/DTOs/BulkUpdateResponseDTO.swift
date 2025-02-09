import ConfigServiceDTOs
import Vapor

extension BulkUpdateResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}
