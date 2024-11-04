//
//  services.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//

import Fluent
import Vapor
import Models

public struct ServicesDTO: Content {
    public var name: String?
    
    
    public func toModel() -> Service {
        let model = Service()
        
        if let name = self.name{
            model.name = self.name!
        }
        

        return model
    }
}
