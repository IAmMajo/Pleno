import ConfigServiceDTOs
import Vapor

extension SettingBulkUpdateDTO: @retroactive Content, @unchecked @retroactive Sendable {}
