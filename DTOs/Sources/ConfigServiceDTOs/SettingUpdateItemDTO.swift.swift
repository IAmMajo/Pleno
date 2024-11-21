//
//  SettingUpdateItemDTO.swift.swift
//  config-service
//
//  Created by Dennis Sept on 19.11.24.
//
import Foundation

public struct SettingUpdateItemDTO: Codable {
    public var id: UUID
    public var value: String
    
    public init(id: UUID, value: String) {
        self.id = id
        self.value = value
    }
}
