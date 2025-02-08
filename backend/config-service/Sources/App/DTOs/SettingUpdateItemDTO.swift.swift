import ConfigServiceDTOs
import Vapor

extension SettingUpdateItemDTO: @retroactive Content, @unchecked @retroactive Sendable {}
