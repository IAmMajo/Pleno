import Fluent
import Foundation

public final class ServiceSetting: Model, @unchecked Sendable {
    public static let schema = "service_settings"
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "service_id")
    public var service: Service
    
    @Parent(key: "setting_id")
    public var setting: Setting
    
    @Timestamp(key: "created", on: .create)
    public var created: Date?
    
    @Timestamp(key: "updated", on: .update)
    public var updated: Date?
    
    public init() {}
    
    public init(id: UUID? = nil, serviceID: UUID, settingID: UUID) {
        self.id = id
        self.$service.id = serviceID
        self.$setting.id = settingID
        self.created = Date()
        self.updated = Date()
    }
}
    
