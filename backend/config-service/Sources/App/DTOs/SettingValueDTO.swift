import ConfigServiceDTOs
import Vapor

extension SettingValueDTO: @retroactive Content, @unchecked @retroactive Sendable {}
