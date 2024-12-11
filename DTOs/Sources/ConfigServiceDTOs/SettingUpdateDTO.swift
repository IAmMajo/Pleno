import Foundation

public struct SettingUpdateDTO: Codable{
    public var value: String
    
    
    public init(value: String) {
        self.value = value
    }
}

