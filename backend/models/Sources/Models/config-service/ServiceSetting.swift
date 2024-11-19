//
//  service_settings.swift
//  config-service
//
//  Created by Dennis Sept on 30.10.24.
//
import Fluent
import Foundation
/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class ServiceSetting: Model, @unchecked Sendable {
    public static let schema = "service_settings"
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "service_id")
    public var service: Service
    
    @Parent(key: "settings_id")
    public var setting: Setting
    
    @Timestamp(key: "created", on: .create)
    public var created: Date
    
    @Timestamp(key: "updated", on: .update)
    public var updated: Date
    
    public init() {}
    
    public init(id: UUID? = nil, serviceID: UUID, settingID: UUID) {
        self.id = id
        self.$service.id = serviceID
        self.$setting.id = settingID
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
    
