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
final class Service_setting: Model, @unchecked Sendable {
    static let schema = "service_settings"
    @ID(key: .id)
    var id: UUID? // Primärschlüssel der Tabelle
    
    @Field(key: "service_id")
    var service_id: UUID
    
    @Field(key: "settings_id")
    var setting_id: UUID
    
    @Timestamp(key: "created", on: .create)
    var created: Date?
    
    @Timestamp(key: "updated", on: .update)
    var updated: Date?
    
    init() {}
    
    init(id: UUID? = nil, serviceId: UUID, settingId: UUID) {
        self.id = id
        self.service_id = serviceId
        self.setting_id = settingId
    }
}
    
  //  func toDTO() -> TodoDTO {
  //      .init(
  //          id: self.id,
  //          title: self.$title.value
  //      )
  //  }


