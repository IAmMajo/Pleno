//
//  settings.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//

import Fluent
import Vapor
import Models

public struct SettingsDTO: Content {
    public var key: String?
    public var value: String?
    
    public func toModel() -> Setting {
        let model = Setting()
        
        if let key = self.key{
            model.key = self.key!
        }
        if let value = self.value{
            model.value = self.value!
        }

        return model
    }
}
