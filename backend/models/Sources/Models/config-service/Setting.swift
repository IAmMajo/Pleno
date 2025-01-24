import Fluent
import Foundation

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Setting: Model, @unchecked Sendable {
    public static let schema = "settings"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "key")
    public var key: String
    
    @Enum(key: "datatype")
    public var datatype: DataType

    @Field(key: "value")
    public var value: String

    @OptionalField(key: "description")
    public var description: String?

    
    public init() { }

    
    public init(id: UUID? = nil, key: String, datatype: DataType, value: String, description: String? = nil) {
        self.id = id
        self.key = key
        self.datatype = datatype
        self.value = value
        self.description = description
    }

    public enum DataType: String, Codable, CaseIterable, Sendable {
        case integer = "Integer"
        case string = "String"
        case languageCode = "languageCode"
        case float = "Float"
        case boolean = "Boolean"
        case date = "Date"
        case dateTime = "DateTime"
        case time = "Time"
        case binary = "Binary"
        case text = "Text"
        case json = "JSON"
    }

}

