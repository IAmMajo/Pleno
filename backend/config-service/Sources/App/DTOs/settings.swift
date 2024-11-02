//
//  settings.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//

import Fluent
import Vapor

struct SettingsDTO: Content {
    var key: String?
    var value: String?
    
    func toModel() -> Setting {
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
