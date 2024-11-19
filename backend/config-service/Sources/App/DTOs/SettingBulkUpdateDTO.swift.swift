//
//  SettingBulkUpdateDTO.swift.swift
//  config-service
//
//  Created by Dennis Sept on 19.11.24.
//

public struct SettingBulkUpdateDTO: Codable {
    public var updates: [SettingUpdateItemDTO]
    
    public init(updates: [SettingUpdateItemDTO]) {
        self.updates = updates
    }
}
