public struct RegisterNotificationDeviceDTO: Codable {
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
