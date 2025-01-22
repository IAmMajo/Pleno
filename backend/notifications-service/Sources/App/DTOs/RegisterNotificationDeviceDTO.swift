import Vapor

// TODO: Replace with DTO from DTOs package
public struct RegisterNotificationDeviceDTO: Codable, Content {
    public var deviceID: String
    public var token: String
    public var platform: NotificationPlatform

    public init(
        deviceID: String,
        token: String,
        platform: NotificationPlatform
    ) {
        self.deviceID = deviceID
        self.token = token
        self.platform = platform
    }
}

public enum NotificationPlatform: String, Codable, CaseIterable {
    case android
    case ios
}

// extension RegisterNotificationDeviceDTO: @retroactive Content { }
