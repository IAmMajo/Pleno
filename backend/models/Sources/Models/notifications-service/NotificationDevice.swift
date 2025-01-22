import Fluent
import Foundation

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class NotificationDevice: Model, @unchecked Sendable {
    public static let schema = "notification_devices"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "device_id")
    public var deviceID: String
    
    @Field(key: "token")
    public var token: String
    
    @Enum(key: "platform")
    public var platform: NotificationPlatform

    @Parent(key: "user_id")
    public var user: User

    public init() { }

    public init(
        id: UUID? = nil,
        deviceID: String,
        token: String,
        platform: NotificationPlatform,
        userID: UUID
    ) {
        self.id = id
        self.deviceID = deviceID
        self.token = token
        self.platform = platform
        self.$user.id = userID
    }
}

public enum NotificationPlatform: String, Codable, Sendable {
    case android
    case ios
}
