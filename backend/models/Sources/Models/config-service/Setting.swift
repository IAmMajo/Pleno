// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Fluent
import Foundation

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

