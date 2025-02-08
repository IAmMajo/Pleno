import ConfigServiceDTOs
import Vapor

extension SettingUpdateDTO: @retroactive Content, @unchecked @retroactive Sendable {}

