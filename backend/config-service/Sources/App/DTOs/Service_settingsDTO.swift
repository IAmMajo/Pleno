//
//  service_settings.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//

import Fluent
import Vapor
import Models

public struct Service_settingsDTO: Content {
    public var service_id: UUID?
    public var setting_id: UUID?
    
    public func toModel() -> Service_setting? {
        guard let serviceId = service_id, let settingId = setting_id else {
                return nil
            }
        let model = Service_setting()
        
        model.service_id=self.service_id!
        model.setting_id=self.setting_id!
        

        return model
    }
}
