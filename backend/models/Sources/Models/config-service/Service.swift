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
import struct Foundation.UUID


public final class Service: Model, @unchecked Sendable {
    public static let schema = "services"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    @Field(key: "webhook_url")
    public var webhook_url: String?

    @OptionalField(key: "description")
    public var description: String?

    @Field(key: "active")
    public var active: Bool
    
    @Siblings(through: ServiceSetting.self, from: \.$service, to: \.$setting)
    public var settings: [Setting]

    
    public init() { }

    public init(id: UUID? = nil, name: String, webhook_url: String?, description: String?, active: Bool = true) {
        self.id = id
        self.name = name
        self.webhook_url = webhook_url
        self.description = description
        self.active = active
    }
    
}

