import Foundation

public struct SettingResponseDTO: Codable{
    public var id: UUID?
    public var key: String
    public var datatype: String
    public var value: String
    public var description: String?
    
    
    public init(id: UUID? = nil, key: String, datatype: String, value: String, description: String? = nil) {
        self.id = id
        self.key = key
        self.datatype = datatype
        self.value = value
        self.description = description
    }
}

