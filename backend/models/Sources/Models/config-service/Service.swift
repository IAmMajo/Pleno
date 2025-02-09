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

