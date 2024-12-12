import Foundation

public struct SettingValueDTO: Codable {
    public var key: String
    public var datatype: String
    public var value: String
    
    public init(key: String, datatype: String, value: String) {
        self.key = key
        self.datatype = datatype
        self.value = value
    }
}
