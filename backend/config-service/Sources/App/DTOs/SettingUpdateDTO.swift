//
//  services.swift
//  config-service
//
//  Created by Dennis Sept on 02.11.24.
//
import Foundation

public struct SettingUpdateDTO: Codable{
    public var value: String
    
    
    public init(value: String) {
        self.value = value
    }
}

