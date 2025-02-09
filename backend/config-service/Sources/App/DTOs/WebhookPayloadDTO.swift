import ConfigServiceDTOs
import Vapor

extension WebhookPayloadDTO: @retroactive Content, @unchecked @retroactive Sendable {}
