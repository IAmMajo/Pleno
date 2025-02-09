import ConfigServiceDTOs
import Vapor

extension SettingResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}
